variable "availability_zones" {
  description = "Availability zones"
  type = list(string)
  default = [ "ap-southeast-2a", "ap-southeast-2b"]
}

variable "public_subnet_cidrs" {
  description = "List public subnet CIDR values"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.4.0/24"]
}

variable "private_data_subnet_cidrs" {
  description = "List private backend subnet CIDR values"
  type = list(string)
  default = ["10.0.2.0/24", "10.0.5.0/24"]
}


variable "private_data_subnet_cidrs" {
  description = "List public data subnet CIDR values"
  type = list(string)
  default = ["10.0.3.0/24", "10.0.6.0/24"]
}

variable "database_master_password" {
  description = "Database Master password"
  type = string
  default = "password123456"
}