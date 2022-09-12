# Dockerfile for OpenSSH Server

## Default settings

* Enable OTP-based authentication.
* Enable public key authentication.
* Enable rate limiting.
* Disable password authentication.
* Prohibit root login.
* Output logs to STDERR.


## Installed packages

* `openssh-server`
* `vi`
* `sudo`


## Usage

### Managing users

Add users in container.

```console
### from outside container
$ docker exec -it <container_name> adduser.sh <username>

### from inside container
$ sudo adduser.sh <username>
```

### Sudoers

Use `SSH_ADMINISTRATORS` environment varaible which contains admin users seperated by comma.

```console
$ docker run ... -e SSH_ADMINISTRATORS="john,blah" openssh-server:debian11
```


### Override sshd_config

Mount `/etc/ssh/sshd_config.d`.


### Use persisted home

Mount `/home`.

```console
$ docker run ... --mount=type=bind,src="$(pwd)"/homedir,dst=/home openssh-server:debian11
```


### Use persisted hostkeys

Mount `/etc/ssh/hostkeys`.

```console
$ docker run ... --mount=type=bind,src="$(pwd)"/hostkeys,dst=/etc/ssh/hostkeys openssh-server:debian11
```

## Logs

Successful login makes a log message like:

```
Accepted keyboard-interactive/pam for john from 172.17.0.1 port 43044 ssh2
```

Failed login makes a log message, regardless of the reason, like:

```
Failed keyboard-interactive/pam for john from 172.17.0.1 port 43048 ssh2
```