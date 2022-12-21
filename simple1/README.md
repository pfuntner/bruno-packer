# `simple1`
This is a simple example that creates an Ubuntu Docker image.

I had seen issues in more complicated Packer scripts where `/tmp` in the temporary container was being mapped to a host directory with permission 0700 but that seemed like a very poor idea.  I wanted to examine this behavior and potentially open an issue for Packer.

I imagine Packer is trying to protect files in the host directory (files might have access keys, passwords, etc) but the permissions get used in the container.

## Packer details
| Detail | Comment |
| - | - |
| [`docker` builder](https://developer.hashicorp.com/packer/plugins/builders/docker) | Docker is probably versatile and easy to set up |
| [`shell` provisioner](https://developer.hashicorp.com/packer/docs/provisioners/shell) | I just decided to use a simple shell command to check out `/tmp`, saving the output in a file in the root user's home directory |
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

# `simple1-redux`
By default, Packer maps the secure host directory to the build container as `/packer-files` and it the empty directory committed in the created image.

I was curious if that would prevent the image from being used as the base image for a new `packer build` but it wasn't a problem.

```
$ packer build simple1.pkr.hcl
docker.simple1: output will be in this color.

==> docker.simple1: Creating a temporary directory for sharing data...
==> docker.simple1: Pulling Docker image: ubuntu:latest
    docker.simple1: latest: Pulling from library/ubuntu
    docker.simple1: 6e3729cf69e0: Pulling fs layer
    docker.simple1: 6e3729cf69e0: Verifying Checksum
    docker.simple1: 6e3729cf69e0: Download complete
    docker.simple1: 6e3729cf69e0: Pull complete
    docker.simple1: Digest: sha256:27cb6e6ccef575a4698b66f5de06c7ecd61589132d5a91d098f7f3f9285415a9
    docker.simple1: Status: Downloaded newer image for ubuntu:latest
    docker.simple1: docker.io/library/ubuntu:latest
==> docker.simple1: Starting docker container...
    docker.simple1: Run command: docker run -v /home/ubuntu/.config/packer/tmp71763336:/packer-files -d -i -t --entrypoint=/bin/sh -- ubuntu:latest
    docker.simple1: Container ID: c5a323049669d63abe3c6970b9dc70b1129752cfde3ff42abcca14345507b52f
==> docker.simple1: Using docker communicator to connect: 172.17.0.2
==> docker.simple1: Provisioning with shell script: /tmp/packer-shell667978592
==> docker.simple1: Committing the container
    docker.simple1: Image ID: sha256:ee49f84e4a12ad8fe74e0387bf0c39483f5c10677da3b625e96ccf041a6fc54b
==> docker.simple1: Killing the container: c5a323049669d63abe3c6970b9dc70b1129752cfde3ff42abcca14345507b52f
==> docker.simple1: Running post-processor:  (type docker-tag)
    docker.simple1 (docker-tag): Tagging image: sha256:ee49f84e4a12ad8fe74e0387bf0c39483f5c10677da3b625e96ccf041a6fc54b
    docker.simple1 (docker-tag): Repository: simple1:latest
Build 'docker.simple1' finished after 7 seconds 174 milliseconds.

==> Wait completed after 7 seconds 174 milliseconds

==> Builds finished. The artifacts of successful builds are:
--> docker.simple1: Imported Docker image: sha256:ee49f84e4a12ad8fe74e0387bf0c39483f5c10677da3b625e96ccf041a6fc54b
--> docker.simple1: Imported Docker image: simple1:latest with tags simple1:latest
$ packer build simple1-redux.pkr.hcl
docker.simple1: output will be in this color.

==> docker.simple1: Creating a temporary directory for sharing data...
==> docker.simple1: Error determining source Docker image digest; this image may not have been pushed yet, which means no distribution digest has been created. If you plan to call docker push later, the digest value will be stored then.
==> docker.simple1: Starting docker container...
    docker.simple1: Run command: docker run -v /home/ubuntu/.config/packer/tmp710976830:/packer-files -d -i -t --entrypoint=/bin/sh -- simple1:latest
    docker.simple1: Container ID: ad9485c8b16eaf6a251e34543e12a5733a032b3db16356002f7ddae3f8a8e45a
==> docker.simple1: Using docker communicator to connect: 172.17.0.2
==> docker.simple1: Provisioning with shell script: /tmp/packer-shell3465727082
==> docker.simple1: Committing the container
    docker.simple1: Image ID: sha256:c716ba217f7b92d160cd28a5d75bcf2c396f66682cc0d31b6f4e9403be766e60
==> docker.simple1: Killing the container: ad9485c8b16eaf6a251e34543e12a5733a032b3db16356002f7ddae3f8a8e45a
==> docker.simple1: Running post-processor:  (type docker-tag)
    docker.simple1 (docker-tag): Tagging image: sha256:c716ba217f7b92d160cd28a5d75bcf2c396f66682cc0d31b6f4e9403be766e60
    docker.simple1 (docker-tag): Repository: simple1:redux
Build 'docker.simple1' finished after 2 seconds 801 milliseconds.

==> Wait completed after 2 seconds 801 milliseconds

==> Builds finished. The artifacts of successful builds are:
--> docker.simple1: Imported Docker image: sha256:c716ba217f7b92d160cd28a5d75bcf2c396f66682cc0d31b6f4e9403be766e60
--> docker.simple1: Imported Docker image: simple1:redux with tags simple1:redux
$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
simple1      redux     c716ba217f7b   11 seconds ago   77.8MB
simple1      latest    ee49f84e4a12   19 seconds ago   77.8MB
ubuntu       latest    6b7dfa7e8fdb   12 days ago      77.8MB
$ docker run -it --entrypoint bash --rm simple1:latest -c 'cat /root/modes.txt; echo; ls -l /; echo; find /packer-files'
drwx------ 2 1000 1000 4096 Dec 21 19:20 /packer-files
drwxrwxrwt 1 root root 4096 Dec 21 19:20 /tmp

total 52
lrwxrwxrwx   1 root root    7 Nov 30 02:04 bin -> usr/bin
drwxr-xr-x   2 root root 4096 Apr 18  2022 boot
drwxr-xr-x   5 root root  360 Dec 21 19:25 dev
drwxr-xr-x   1 root root 4096 Dec 21 19:25 etc
drwxr-xr-x   2 root root 4096 Apr 18  2022 home
lrwxrwxrwx   1 root root    7 Nov 30 02:04 lib -> usr/lib
lrwxrwxrwx   1 root root    9 Nov 30 02:04 lib32 -> usr/lib32
lrwxrwxrwx   1 root root    9 Nov 30 02:04 lib64 -> usr/lib64
lrwxrwxrwx   1 root root   10 Nov 30 02:04 libx32 -> usr/libx32
drwxr-xr-x   2 root root 4096 Nov 30 02:04 media
drwxr-xr-x   2 root root 4096 Nov 30 02:04 mnt
drwxr-xr-x   2 root root 4096 Nov 30 02:04 opt
drwxr-xr-x   2 root root 4096 Dec 21 19:20 packer-files
dr-xr-xr-x 193 root root    0 Dec 21 19:25 proc
drwx------   1 root root 4096 Dec 21 19:20 root
drwxr-xr-x   5 root root 4096 Nov 30 02:07 run
lrwxrwxrwx   1 root root    8 Nov 30 02:04 sbin -> usr/sbin
drwxr-xr-x   2 root root 4096 Nov 30 02:04 srv
dr-xr-xr-x  13 root root    0 Dec 21 19:25 sys
drwxrwxrwt   1 root root 4096 Dec 21 19:20 tmp
drwxr-xr-x  14 root root 4096 Nov 30 02:04 usr
drwxr-xr-x  11 root root 4096 Nov 30 02:07 var

/packer-files
$ docker run -it --entrypoint bash --rm simple1:redux -c 'cat /root/modes.txt; echo; ls -l /; echo; find /packer-files'
drwx------ 2 1000 1000 4096 Dec 21 19:20 /packer-files
drwxrwxrwt 1 root root 4096 Dec 21 19:20 /tmp

total 52
lrwxrwxrwx   1 root root    7 Nov 30 02:04 bin -> usr/bin
drwxr-xr-x   2 root root 4096 Apr 18  2022 boot
drwxr-xr-x   5 root root  360 Dec 21 19:25 dev
drwxr-xr-x   1 root root 4096 Dec 21 19:25 etc
drwxr-xr-x   2 root root 4096 Apr 18  2022 home
lrwxrwxrwx   1 root root    7 Nov 30 02:04 lib -> usr/lib
lrwxrwxrwx   1 root root    9 Nov 30 02:04 lib32 -> usr/lib32
lrwxrwxrwx   1 root root    9 Nov 30 02:04 lib64 -> usr/lib64
lrwxrwxrwx   1 root root   10 Nov 30 02:04 libx32 -> usr/libx32
drwxr-xr-x   2 root root 4096 Nov 30 02:04 media
drwxr-xr-x   2 root root 4096 Nov 30 02:04 mnt
drwxr-xr-x   2 root root 4096 Nov 30 02:04 opt
drwxr-xr-x   2 root root 4096 Dec 21 19:20 packer-files
dr-xr-xr-x 192 root root    0 Dec 21 19:25 proc
drwx------   1 root root 4096 Dec 21 19:20 root
drwxr-xr-x   5 root root 4096 Nov 30 02:07 run
lrwxrwxrwx   1 root root    8 Nov 30 02:04 sbin -> usr/sbin
drwxr-xr-x   2 root root 4096 Nov 30 02:04 srv
dr-xr-xr-x  13 root root    0 Dec 21 19:25 sys
drwxrwxrwt   1 root root 4096 Dec 21 19:20 tmp
drwxr-xr-x  14 root root 4096 Nov 30 02:04 usr
drwxr-xr-x  11 root root 4096 Nov 30 02:07 var

/packer-files
$
```
