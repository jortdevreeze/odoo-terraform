packer {
    required_plugins {
        digitalocean = {
            version = ">= 1.0.4"
            source  = "github.com/digitalocean/digitalocean"
        }        
    }
}

variable "DO_TOKEN" {
    type    = string
    default = false
    sensitive = true
}

variable "ODOO_USER" {
    type    = string
    default = "odoo"
    sensitive = true
}

variable "ODOO_PASSWORD" {
    type    = string
    default = "secret"
    sensitive = true
}

source "digitalocean" "odoo" {
    api_token    = "${var.DO_TOKEN}"
    image        = "ubuntu-22-04-x64"
    region       = "fra1"
    size         = "s-2vcpu-4gb"
    ssh_username = "root"
    droplet_name = "packer-odoo-s-2vcpu-4gb"
    snapshot_name = "packer-odoo-s-2vcpu-4gb"
}

build {

    name = "odoo"
    sources = [
        "source.digitalocean.odoo"
    ]

    provisioner "shell" {
        inline = [
            "mkdir -p /home/docker",
        ]
    }
    provisioner "file" {
        source = "odoo/docker-compose.yml"
        destination = "/home/docker/docker-compose.yml"
    }
    provisioner "shell" {
        script = "docker/docker.sh"
    }
    provisioner "shell" {
        inline = [
            "docker version",
            "docker info",
            "docker compose version"
        ]
    }
    provisioner "shell" {
        inline = [
            "echo ${var.ODOO_USER} > /home/docker/odoo_user.txt",
            "echo ${var.ODOO_PASSWORD} > /home/docker/odoo_password.txt",
            "docker network create web",
            "docker compose -f /home/docker/docker-compose.yml up -d"
        ]
    }
}
