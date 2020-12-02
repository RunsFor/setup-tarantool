# setup-tarantool

This action installs tarantool with version specified.

## Example

```yaml
jobs:
  with-version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: runsfor/setup-tarantool@v0.1.1
        with:
          version: 2.4
```

It is also works inside containers. ubuntu (apt) and centos (yum) are supported:

```yaml
jobs:
  inside-docker-container:
    runs-on: ubuntu-latest
    container:
      image: centos:7
    steps:
      - uses: actions/checkout@v2
      - uses: runsfor/setup-tarantool@v0.1.1 # defaults to 2.6
```
