env_name           = "sandbox"
region             = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
dns_suffix         = "fionathebluepittie.com"
hosted_zone        = "sandbox.fionathebluepittie.com"
vpc_cidr           = "10.0.0.0/16"
rds_instance_count = 1

tags = {
    Team = "sam"
    Project = "pks"
}

