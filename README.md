# dockerfiles

Dockerfiles for servers using Debian packages.

## Tag policy

Each image in this project has a tag following this pattern:

 * `<distro>`: Base image version. (e.g. `debian-11`）
 * `<version>`: Configuration version. (e.g. `1.0`)
 * `<hash>`: Image hash.

```
<base>_<version>_<hash>
```