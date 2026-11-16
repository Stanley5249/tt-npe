# Stanley5249/tt-npe

This fork packages upstream [tenstorrent/tt-npe](https://github.com/tenstorrent/tt-npe), the Tenstorrent NoC performance estimator, as one conda package for linux-64, so [tt-vllm-tracer](https://github.com/Stanley5249/tt-vllm-tracer) can install it with pixi instead of cloning and building it. The source is upstream's; the fork adds only `conda/`, `.github/workflows/conda.yaml`, and this file.

## What the package holds

`conda/recipe.yaml` builds this checkout with conda-forge's Clang 20, libc++, and a glibc 2.34 sysroot, and installs:

- `libtt_npe.so`, with the `libfmt` and `libsimdjson` that tt-npe's CMake fetches, in `lib/`;
- `tt_npe_pybind` and upstream's `tt_npe.py`, `npe_analyze_noc_trace_dir.py`, and `fabric_post_process.py` as importable modules in `site-packages`, so no `PYTHONPATH` is needed;
- the device models in `share/tt_npe/device/models/`, and an activation script that sets `TT_NPE_DEVICE_MODEL_CONFIG_DIR` to them.

The recipe's tests import the modules and model upstream's sample workload. The bundled `libfmt` and `libsimdjson` clash with conda-forge's packages of the same libraries, so keep tt-npe in an environment of its own.

## Releases

The version is the date of the upstream commit, such as `2026.10.8`, and the tag adds the build number, such as `v2026.10.8-conda.1`. Bump the build number for a packaging change at the same upstream commit.

To move to a newer upstream commit:

```sh
git fetch https://github.com/tenstorrent/tt-npe.git main
git merge FETCH_HEAD          # upstream never touches conda/, so this merges cleanly
# set version in conda/recipe.yaml to the commit's date and build.number to 1
git push
gh workflow run conda.yaml -f tag=v<version>-conda.<number>
```

The run builds and tests the package, then publishes it as the release with the package as its only asset, and prints its URL and sha256. tt-vllm-tracer pins both in `pyproject.toml`.

Upstream's own workflows are disabled in this fork; `conda.yaml` is its only CI.
