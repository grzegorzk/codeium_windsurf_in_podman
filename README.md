# Run Codeium Windsurf in unprivileged podman container

* root account not involved

# Why

* Windsurf is more thun just IDE so it's good idea to have it isolated from your host system

# Run

If you have podman:

```bash
make build
make run
```

If you prefer docker:

```bash
make build DOCKER=docker
make run DOCKER=docker
```

We are forwarding X11 session and PulseAudio into the container, this is the reason why only Linux distributions are currently supported.

# Expose source code to the container

Adjust `HOST_PATH_TO_PROJECT` and `CONTAINER_PATH_TO_MOUNT_PROJECT` in `.makerc`

# Extensions

Download extensions from any extensions marketplace and drop them to `docker_files/extensions`, they will be installed next time you issue `make run`

# Thanks

People building Codeium Windsurf
* https://codeium.com/windsurf

People maintaining ArchLinux:
* https://archlinux.org/

Great teams building products I love:
* https://podman.io/

Many other giants
