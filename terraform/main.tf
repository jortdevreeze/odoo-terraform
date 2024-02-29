terraform {
    required_version = "~> 1.7.3"

    required_providers {
        digitalocean = {
            source  = "digitalocean/digitalocean"
            version = "~> 2.0"
        }
    }
}

variable "DO_TOKEN" {
    description = "Digital Ocean API token"
    type = string
    sensitive = true
}

variable "NAME" {
    description = "Droplet Name"
    default = "droplet-odoo-s-2vcpu-4gb"
    type = string
}

provider "digitalocean" {
    token = "${var.DO_TOKEN}"
}

data "digitalocean_image" "docker-snapshot" {
    name = "packer-odoo-s-2vcpu-4gb"
}

resource "digitalocean_droplet" "odoo" {
    image     = data.digitalocean_image.docker-snapshot.image
    name      = "${var.NAME}"
    region    = "fra1"
    size      = "s-2vcpu-4gb"
}

output "ip" {
    value = "${digitalocean_droplet.odoo.ipv4_address}"
    description = "The public IP address of your Odoo Droplet."
}