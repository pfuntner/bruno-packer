# `simple1`
This is a simple example that creates an Ubuntu Docker image.

I had seen issues in more complicated Packer scripts where `/tmp` in the temporary container was being mapped to a host directory with permission 0700 but that seemed like a very poor idea.

I imagine Packer is trying to protect files in the host directory (files might have access keys, passwords, etc) but the permissions get used in the container.

## Packer details
| Detail | Comment |
| - | - |
| [`docker` bulder](https://developer.hashicorp.com/packer/plugins/builders/docker) | Docker is probably versatile and easy to set up |
| [`shell` provisioner](https://developer.hashicorp.com/packer/docs/provisioners/shell) | I just decided to use a  to check out `/tmp` |
| Docker tag produced | `simple1:latest` |

### Building
```
$ packer build simple1.pkr.hcl
```

## Comments
Packer maps a volume in the temporary container during the build but not `/tmp`:

```
==> docker.simple1: Starting docker container...
    docker.simple1: Run command: docker run -v /home/ubuntu/.config/packer/tmp1263704427:/packer-files -d -i -t --entrypoint=/bin/sh -- ubuntu:latest
    docker.simple1: Container ID: 277c3a9b8f97fd6a2591b635153474217fe3d1675ce76cc4e3889e55ef9c3b35
```

When I looked at the inforamtion captured about `/tmp` at the time the image was build, it's fine, which is totally expected because the `/tmp` was not mapped:
```
drwxrwxrwt 1 root root 4096 Dec 21 12:17 /tmp
```

This leads me to investigate other provisioners - the complicated examples of which I spoke use Ansible so I'll probably try that out.
