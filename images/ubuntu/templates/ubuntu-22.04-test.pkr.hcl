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
  image  = "cruizba/ubuntu-dind:jammy-25.0.3"
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
  }
  provisioner "shell" {
    inline = ["apt-get update", "apt-get install -y sudo"]
  }
 
  provisioner "shell" {
    inline = ["apt-get update", "apt-get install -y lsb-release"]
  }

  provisioner "shell" {
    inline = ["apt-get update", "apt-get install -y wget"]
  }

  provisioner "shell" {
    inline = ["mkdir -p ${var.helper_script_folder}"]
  }

  provisioner "shell" {
    inline = ["mkdir -p ${var.installer_script_folder}"]
  }

  provisioner "shell" {
    inline = ["mkdir -p ${var.systemd_script_folder}"]
  }

  provisioner "shell" {
    inline = ["mkdir -p ${var.misc_script_folder}"]
  }

  provisioner "file" {
    destination = "${var.helper_script_folder}"
    source      = "${path.root}/../scripts/helpers/"
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}"
    source      = "${path.root}/../scripts/build/"
  }

  provisioner "file" {
    destination = "${var.systemd_script_folder}"
    source      = "${path.root}/../scripts/systemd/"
  }

  provisioner "file" {
    destination = "${var.misc_script_folder}"
    sources     = [
      "${path.root}/../assets/post-gen",
      "${path.root}/../scripts/tests",
      "${path.root}/../scripts/docs-gen"
    ]
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}/toolset.json"
    source      = "${path.root}/../toolsets/toolset-2204.json"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = [
      "${path.root}/../scripts/build/configure-apt.sh"
    ]
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = [
      "mv ${var.misc_script_folder}/post-gen ${var.misc_script_folder}/post-generation"
    ]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/configure-environment.sh"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/install-apt-vital.sh"]
  }

#  provisioner "shell" {
#    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
#    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
#    scripts          = ["${path.root}/../scripts/build/install-powershell.sh"]
#  }

#  provisioner "shell" {
#    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
#    execute_command  = "sudo sh -c '{{ .Vars }} pwsh -f {{ .Path }}'"
#    scripts          = ["${path.root}/../scripts/build/Install-PowerShellModules.ps1"]
#  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "DEBIAN_FRONTEND=noninteractive", "SYSTEMD_SCRIPT_FOLDER=${var.systemd_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = [
#      "${path.root}/../scripts/build/install-actions-cache.sh",
#      "${path.root}/../scripts/build/install-runner-package.sh",
#      "${path.root}/../scripts/build/install-rust.sh",
       "${path.root}/../scripts/build/install-docker.sh",
    ]
  }

  provisioner "shell" {
    inline = ["sudo apt-get install -y socat"]
  }

  provisioner "shell" {
    inline = ["sudo apt-get install -y iproute2"]
  }


  provisioner "shell" {
    execute_command     = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    pause_before        = "1m0s"
    scripts             = ["${path.root}/../scripts/build/cleanup.sh"]
    start_retry_timeout = "10m"
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPT_FOLDER=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "IMAGE_FOLDER=${var.misc_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = ["${path.root}/../scripts/build/configure-system.sh"]
  }

  provisioner "shell" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "DEBIAN_FRONTEND=noninteractive", "SYSTEMD_SCRIPT_FOLDER=${var.systemd_script_folder}"]
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts          = [
      "${path.root}/../scripts/build/configure-blacksmith.sh"
    ]
  }
}
