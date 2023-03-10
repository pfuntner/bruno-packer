source "docker" "simple1" {
  image = "ubuntu:latest"
  pull = "true"
  commit = "true"
}

build {
  sources = ["source.docker.simple1"]

  provisioner "shell" {
    inline = [
      "ls -ld /tmp /packer-files > /root/modes.txt 2>&1"
    ]
  }

  post-processor "docker-tag" {
    repository = "simple1"
    force = "true"
    tags = [
      "latest"
    ]
  }
}
