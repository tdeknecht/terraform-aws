# ------------------------------------------------------------------------------
# Required inputs
# ------------------------------------------------------------------------------

variable "ou" {
  description = "(Required) A logical identifier for the Organizational Unit."
  type        = string
}

variable "use_case" {
  description = "(Required) A friendly identifier of the use case."
  type        = string
}

variable "tags" {
  description = "(Required) A map of tags to assign to the resource."
  type        = map(string)
}

# ------------------------------------------------------------------------------
# Optional inputs
# ------------------------------------------------------------------------------

variable "subnet_id" {
  description = "(Optional) The VPC Subnet ID to launch in."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "(Optional) A list of security group IDs to associate with."
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "(Optional) The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance."
  type        = string
  default     = "t3.micro"
}

variable "user_data" {
  description = "(Optional) The user data to provide when launching the instance."
  type        = string
  default     = null
}

variable "public_ip" {
  description = "(Optional) Determine whether an EIP will be created and associated to the instance."
  type        = bool
  default     = false
}

variable "ssh_from_my_ip" {
  description = "(Optional) Create a Security Group allowing SSH from requesters public IP"
  type        = bool
  default     = false
}

variable "ami" {
  description = "(Optional) The AMI to use for the instance. Defaults to latest AWS Linux 2"
  type        = string
  default     = "" # handled via data lookup
}
