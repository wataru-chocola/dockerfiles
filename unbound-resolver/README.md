# Dockerfile for unbound DNS resolver

## Default settings

* Set up DNS resolver.
* Output logs to STDERR.


## Installed packages

* `unbound`
* `ca-certificates`

## Default config

Default config are devided into the following files:

- [basic-settings.conf](./data/configs/basic-settings.conf)
- [logging.conf](./data/configs/logging.conf)
- [access-control.conf](./data/configs/access-control.conf)
- [security.conf](./data/configs/security.conf)
- [privacy.conf](./data/configs/privacy.conf)
- [performance.conf](./data/configs/performance.conf)
- [remote-control.conf](./data/configs/remote-control.conf)

## Usage

### Customize configuration

Mount `/config` containing your config files.

* A file with the same name as any of default config will override it.
* Otherwise, a config file will be just included in unbound.conf.

```console
$ docker run ... --mount=type=bind,src="$(pwd)"/configs,dst=/config unbound:debian11_1.0
```