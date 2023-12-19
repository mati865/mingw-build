# Running

To obtain Zstd compressed archives simulply run:

```sh
podman build . -t mingw-build --ulimit nofile=2048:2048
./copy.sh
```

You will probably want to clean-up Docker/Podman images and build cache.
