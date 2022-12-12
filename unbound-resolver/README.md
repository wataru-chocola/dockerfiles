# Dockerfile for unbound DNS resolver

## Default settings

* Set up DNS resolver.
* Enable `unbound_control`.
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

### Optimize performance settings based on resources

Use `OPTIMIZE_PERFORMANCE_SETTINGS` environment variable to adjust settings based on system resources (procfs, cgroups).

* See: [optimize_performance.sh](./data/init.d/optimize_performance.sh)

```console
$ docker run ... -e OPTIMIZE_PERFORMANCE_SETTINGS=1 unbound-resolver:debian11_1.0
```

### Customize configuration

Mount `/config` containing your config files.

* A file with the same name as any of default config will override it.
* Otherwise, a config file will be just included in unbound.conf.

```console
$ docker run ... --mount=type=bind,src="$(pwd)"/config,dst=/config unbound-resolver:debian11_1.0
```

### Use your control key

If you want to manage server keys yourself, mount them:

* `/etc/unbound/unbound_server.key`
* `/etc/unbound/unbound_server.pem`

```console
$ docker run ... \
    --mount=type=bind,src="$(pwd)"/keys/unbound_server.key,dst=/etc/unbound/unbound_sever.key \
    --mount=type=bind,src="$(pwd)"/keys/unbound_server.pem,dst=/etc/unbound/unbound_sever.pem \
    unbound-resolver:debian11_1.0
```