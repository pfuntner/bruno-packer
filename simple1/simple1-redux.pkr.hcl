source "docker" "simple1" {
  image = "simple1:latest"
  commit = "true"
  pull = "false"
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
      "redux"
    ]
  }
}
