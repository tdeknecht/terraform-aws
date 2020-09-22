package main

import (
	"context"
	"fmt"
	"strings"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
)

//MyEvent struct for Lambda Go handler
type MyEvent struct {
	Name string `json:"name"`
}

func main() {
	lambda.Start(HandleRequest)
}

//HandleRequest Lambda Go handler
func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	removeDefaultVpcEverywhere()
	return fmt.Sprintf("Hello %s", name.Name), nil
}

func sessionManager(profile string, region string) *session.Session {
	sess, err := session.NewSessionWithOptions(session.Options{
		Profile: profile,
		Config: aws.Config{
			Region: aws.String(region),
		},
	})
	if err != nil {
		fmt.Println(err.Error())
	}
	return sess
}

func removeDefaultVpcEverywhere() {
	sess := sessionManager("default", "us-east-1")
	ec2svc := ec2.New(sess)

	fmt.Println("Collecting available AWS Regions")
	describeRegionsResult, err := ec2svc.DescribeRegions(
		&ec2.DescribeRegionsInput{
			AllRegions: aws.Bool(true),
		},
	)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			fmt.Println(err.Error())
		}
		return
	}

	for _, region := range describeRegionsResult.Regions {
		fmt.Printf("Checking %s...\n", *region.RegionName)
		sess := sessionManager("default", *region.RegionName)
		ec2svc := ec2.New(sess)

		describeVpcsResult, err := ec2svc.DescribeVpcs(
			&ec2.DescribeVpcsInput{
				Filters: []*ec2.Filter{
					{
						Name:   aws.String("isDefault"),
						Values: []*string{aws.String("true")},
					},
				},
			},
		)
		if err != nil {
			if strings.Contains(err.Error(), "AuthFailure") { // some regions throw an AuthFailure for some reason
				continue
			} else if aerr, ok := err.(awserr.Error); ok {
				switch aerr.Code() {
				default:
					fmt.Println(aerr.Error())
				}
			} else {
				fmt.Println(err.Error())
			}
			return
		}

		// only do this stuff if there is a default VPC in this region
		if describeVpcsResult.Vpcs != nil {
			fmt.Printf("Deleting Default %s in %s \n", *describeVpcsResult.Vpcs[0].VpcId, *region.RegionName)
			describeDefaultVpcAttachedInternetGatewaysResult, err := ec2svc.DescribeInternetGateways(
				&ec2.DescribeInternetGatewaysInput{
					Filters: []*ec2.Filter{
						{
							Name:   aws.String("attachment.vpc-id"),
							Values: []*string{aws.String(*describeVpcsResult.Vpcs[0].VpcId)},
						},
					},
				},
			)
			if err != nil {
				if aerr, ok := err.(awserr.Error); ok {
					switch aerr.Code() {
					default:
						fmt.Println(aerr.Error())
					}
				} else {
					fmt.Println(err.Error())
				}
				return
			}

			// detach any IGWs attached to a Default VPC
			if describeDefaultVpcAttachedInternetGatewaysResult.InternetGateways != nil {
				_, err := ec2svc.DetachInternetGateway(
					&ec2.DetachInternetGatewayInput{
						InternetGatewayId: aws.String(*describeDefaultVpcAttachedInternetGatewaysResult.InternetGateways[0].InternetGatewayId),
						VpcId:             aws.String(*describeVpcsResult.Vpcs[0].VpcId),
					},
				)
				if err != nil {
					if aerr, ok := err.(awserr.Error); ok {
						switch aerr.Code() {
						default:
							fmt.Println(aerr.Error())
						}
					} else {
						fmt.Println(err.Error())
					}
					return
				}
			}

			// destroy any un-attached IGWs
			describeDetachedInternetGatewaysResult, err := ec2svc.DescribeInternetGateways(
				&ec2.DescribeInternetGatewaysInput{},
			)
			if err != nil {
				if aerr, ok := err.(awserr.Error); ok {
					switch aerr.Code() {
					default:
						fmt.Println(aerr.Error())
					}
				} else {
					fmt.Println(err.Error())
				}
				return
			}
			if describeDetachedInternetGatewaysResult.InternetGateways != nil {
				for _, igw := range describeDetachedInternetGatewaysResult.InternetGateways {
					if igw.Attachments == nil {
						fmt.Printf("\t Deleting %s \n", *igw.InternetGatewayId)
						_, err := ec2svc.DeleteInternetGateway(
							&ec2.DeleteInternetGatewayInput{
								InternetGatewayId: aws.String(*igw.InternetGatewayId),
							},
						)
						if err != nil {
							if aerr, ok := err.(awserr.Error); ok {
								switch aerr.Code() {
								default:
									fmt.Println(aerr.Error())
								}
							} else {
								fmt.Println(err.Error())
							}
							return
						}
					}
				}
			}

			// destroy Subnets (loop through and remove them)
			describeSubnetsResult, err := ec2svc.DescribeSubnets(
				&ec2.DescribeSubnetsInput{
					Filters: []*ec2.Filter{
						{
							Name:   aws.String("vpc-id"),
							Values: []*string{aws.String(*describeVpcsResult.Vpcs[0].VpcId)},
						},
					},
				},
			)
			if err != nil {
				if aerr, ok := err.(awserr.Error); ok {
					switch aerr.Code() {
					default:
						fmt.Println(aerr.Error())
					}
				} else {
					fmt.Println(err.Error())
				}
				return
			}
			for _, subnet := range describeSubnetsResult.Subnets {
				fmt.Printf("\t Deleting %s \n", *subnet.SubnetId)
				_, err := ec2svc.DeleteSubnet(
					&ec2.DeleteSubnetInput{
						SubnetId: aws.String(*subnet.SubnetId),
					},
				)
				if err != nil {
					if aerr, ok := err.(awserr.Error); ok {
						switch aerr.Code() {
						default:
							fmt.Println(aerr.Error())
						}
					} else {
						fmt.Println(err.Error())
					}
					return
				}
			}

			// destroy VPC
			_, err = ec2svc.DeleteVpc(
				&ec2.DeleteVpcInput{
					VpcId: aws.String(*describeVpcsResult.Vpcs[0].VpcId),
				},
			)
			if err != nil {
				if aerr, ok := err.(awserr.Error); ok {
					switch aerr.Code() {
					default:
						fmt.Println(aerr.Error())
					}
				} else {
					fmt.Println(err.Error())
				}
				return
			}
			fmt.Printf("\t VPC %s Deleted\n", *describeVpcsResult.Vpcs[0].VpcId)
		}
	}
}
