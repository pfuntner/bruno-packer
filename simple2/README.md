# `simple2`
This is a simple example that creates an Alma Linux Docker image.  I switched from Ubuntu to Alma because base Docker images in the Debian family (such as Ubuntu) typically don't have Ansible installed anywhere.  It was just easiest to use an image that do have Python.

I had seen issues in more complicated Packer scripts where `/tmp` in the temporary container was being mapped to a host directory with permission 0700 but that seemed like a very poor idea.  I wanted to examine this behavior and potentially open an issue for Packer.

I imagine Packer is trying to protect files in the host directory (files might have access keys, passwords, etc) but the permissions get used in the container.

## Packer details
| Detail | Comment |
| - | - |
| [`docker` builder](https://developer.hashicorp.com/packer/plugins/builders/docker) | Docker is probably versatile and easy to set up |
| [`ansible` provisioner](https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible) | I wanted to use a super simple Ansible playbook just so Packer might map `/tmp` the way I was expected |
| [`shell` provisioner](https://developer.hashicorp.com/packer/docs/provisioners/shell) | I just decided to use a simple shell command to check out `/tmp`, saving the output in a file in the root user's home directory |
| Docker tag produced | `simple2:latest` |

### Building
```
$ packer build simple2.pkr.hcl
```

## Comments
Again, Packer maps a volume in the temporary container during the build but not `/tmp`, so there's no trouble.

While I didn't recreate the issue, it did make me believe that Packer by default map to `/tmp`.  So why was it mapping to `/tmp` in our complicated example?

I learned that we were overriding the `container_dir` variable to `/tmp` in the docker builder which probably not a good thing to do.
