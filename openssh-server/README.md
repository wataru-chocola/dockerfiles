# Dockerfile for OpenSSH Server

## Default settings

* Enable OTP-based authentication.
* Enable public key authentication.
* Disable password authentication.
* Prohibit root login.
* Output logs to STDERR.

## Usage

### Managing users

Add users from container.

```
$ docker exec -it <container_name> adduser <username>
```

### Sudoers


### Override sshd_config

Mount `/etc/ssh/sshd_config.d`.


### Persist hostkeys

Mount `/etc/ssh/hostkeys`.

```
$ docker run -p 2022:22 --mount=type=bind,src="$(pwd)"/hostkeys,dst=/etc/ssh/hostkeys -d openssh-server:debian11
```

