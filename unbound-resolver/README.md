# Dockerfile for unbound DNS resolver

## Default settings

* Enable OTP-based authentication.
* Enable public key authentication.
* Enable rate limiting.
* Disable password authentication.
* Prohibit root login.
* Output logs to STDERR.


## Installed packages

* `unbound`
* `ca-certificates`

## Default config

Default config are devided into the following files:

- [basic-settings.conf](./data/basic-settings.conf)
- [logging.conf](./data/logging.conf)
- [access-control.conf](./data/access-control.conf)
- [security.conf](./data/security.conf)
- [privacy.conf](./data/privacy.conf)
- [performance.conf](./data/performance.conf)
- [remote-control.conf](./data/remote-control.conf)

## Usage

### Customize configuration

Mount `/config` containing your config files.

* A file with the same name as any of default config will override it.
* Otherwise, a config file will be just included in unbound.conf.

```console
$ docker run ... --mount=type=bind,src="$(pwd)"/configs,dst=/config unbound:debian11_1.0
```