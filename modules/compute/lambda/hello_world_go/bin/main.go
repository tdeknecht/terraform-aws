package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
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
	return fmt.Sprintf("Hello %s", name.Name), nil
}
