# Build USQCD software (SciDAC Layers) on CLQCD clusters

This is a repository for those who want to build USQCD software (Chroma with QUDA and QDP-JIT enabled) on CLQCD clusters.

## Usage

Download the source code anywhere you like:

```bash
./download.sh cuda
```

`cuda` here is the target you want to run on. `cuda` and `dtk` are avaliable options now.

The `download.sh` script will download, patch and archive the source code you need. Upload or move `scidac.tgz` to where you want and unarchive it. Then you can build the binary with `build.sh` or `build_offline.sh`:

```bash
tar -xzvf scidac.tgz
cd scidac
./build_offline.sh
```
