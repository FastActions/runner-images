packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}

variable "DOCKER_USERNAME" {
  type = string
}

variable "DOCKER_ACCESS_TOKEN" {
  type = string
}

variable "DOCKER_IMAGE" {
  type = string
}

variable "DOCKER_TAG" {
  type = string
}

variable "dockerhub_login" {
  type    = string
  default = "${env("DOCKER_USERNAME")}"
}

variable "dockerhub_password" {
  type    = string
  default = "${env("DOCKER_ACCESS_TOKEN")}"
}

variable "helper_script_folder" {
  type    = string
  default = "/blacksmith/helpers"
}

variable "installer_script_folder" {
  type    = string
  default = "/blacksmith/installers"
}

variable "systemd_script_folder" {
  type    = string
  default = "/blacksmith/systemd"
}

variable "misc_script_folder" {
  type    = string
  default = "/blacksmith/misc"
}

source "docker" "blacksmith" {
  image  = "blacksmithcihello/rootfs-packer:130224-3"
  commit = true
  privileged = true
}

build {
  sources = ["source.docker.blacksmith"]

  post-processors {
    post-processor "docker-tag" {
      repository = var.DOCKER_IMAGE
      tags       = [var.DOCKER_TAG]
    }

    post-processor "docker-push" {
      login = true
      login_username = var.DOCKER_USERNAME
      login_password = var.DOCKER_ACCESS_TOKEN
    }

    provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = [
      "${path.root}/../scripts/build/configure-apt-sources.sh",
    ]
  }
  }
}
