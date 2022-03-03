data "g42cloud_availability_zones" "myaz" {}

resource "g42cloud_networking_secgroup" "rdssecgroup" {
  name        = "rds_security_group"
  description = "security group for RDS"
}

# allow MySQL Port
resource "g42cloud_networking_secgroup_rule" "rds_allow_mysql" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = var.vpc_cidr
  security_group_id = g42cloud_networking_secgroup.rdssecgroup.id
}

resource "g42cloud_rds_instance" "rds_instance" {
  name              = "mysql_instance"
  flavor            = var.rds_flavor
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = g42cloud_networking_secgroup.rdssecgroup.id
  availability_zone = [data.g42cloud_availability_zones.myaz.names[0]]

  # For High Availibility
  # ha_replication_mode = "async"

  # availability_zone = [
  #   data.g42cloud_availability_zones.myaz.names[0],
  #   data.g42cloud_availability_zones.myaz.names[1]
  # ]

  db {
    type     = "MySQL"
    version  = var.rds_mysql_version
    password = var.rds_password
    port     = var.rds_port
  }
  volume {
    type = "ULTRAHIGH"
    size = 40
  }
  backup_strategy {
    start_time = "08:00-09:00"
    keep_days  = 3
  }
}