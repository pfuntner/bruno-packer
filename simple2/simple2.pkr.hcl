source "docker" "simple2" {
  image = "almalinux:latest"
  pull = "true"
  commit = "true"
}

build {
  sources = ["source.docker.simple2"]

  provisioner "ansible" {
    playbook_file = "simple2-playbook.yml"
  }

  provisioner "shell" {
    inline = [
      "ls -ld /tmp > /root/tmp.txt"
    ]
  }

  post-processor "docker-tag" {
    repository = "simple2"
    force = "true"
    tags = [
      "latest"
    ]
  }
}
