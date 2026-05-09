# pixi-build-with-scikit-build-core

Failure of pixi-build-python pixi-build backend 0.4.8 to build a scikit-build-core package

## Related GitHub Issues

* pixi-build fails to build scikit-build-core Python project with pixi-build backend v0.4.8 ([`prefix-dev/pixi` #6057](https://github.com/prefix-dev/pixi/issues/6057))
* Question: Viable to automatically set CMAKE_GENERATOR default environment variable based on presence of ninja ([`prefix-dev/rattler-build` #2487](https://github.com/prefix-dev/rattler-build/issues/2487))

## Minimal Failing Example

`src/rosen_cpp` is a minimal example of a Python library with compiled C++ extensions built with `scikit-build-core`.

A Docker build that install `rosen-cpp` into a `uv` virtual environment (with a Pixi environment providing the build tools) through `uv pip install` can be executed with

```
pixi run docker-build-uv
```

or

```
bash docker_build_uv.sh
```

The build will succeed.

If instead, `pixi-build` is used with the `v0.4.8` `pixi-build-python` backend with


```
pixi run docker-build-pixi-build
```

or

```
bash docker_build_pixi-build.sh
```

the build will fail as it will fail to detect `ninja`, the default build engine for `scikit-build-core`, and will instead try to use `make`, which is not installed.

```
DEBUG \x1b[32m***\x1b[0m \x1b[1mConfiguring CMake...\x1b[0m
DEBUG 2026-05-08 23:32:26,416 - scikit_build_core - WARNING - Unsupported CMAKE_ARGS ignored: -DCMAKE_BUILD_TYPE=Release
DEBUG 2026-05-08 23:32:26,416 - scikit_build_core - WARNING - Unsupported CMAKE_ARGS ignored: -DCMAKE_INSTALL_PREFIX=$PREFIX
DEBUG 2026-05-08 23:32:26,417 - scikit_build_core - WARNING - Unsupported CMAKE_ARGS ignored: -DCMAKE_BUILD_TYPE=Release
DEBUG 2026-05-08 23:32:26,417 - scikit_build_core - WARNING - Unsupported CMAKE_ARGS ignored: -DCMAKE_INSTALL_PREFIX=$PREFIX
DEBUG loading initial cache file /tmp/tmpvlgwgkgf/build/CMakeInit.txt
DEBUG -- Configuring incomplete, errors occurred!
DEBUG \x1b[0mCMake Error: CMake was unable to find a build program corresponding to "Unix Makefiles".  CMAKE_MAKE_PROGRAM is not set.  You probably need to
 select a different build tool.\x1b[0m
DEBUG \x1b[0mCMake Error: CMAKE_CXX_COMPILER not set, after EnableLanguage\x1b[0m
DEBUG \x1b[31m
DEBUG \x1b[1m***\x1b[0m \x1b[31mCMake configuration failed\x1b[0m
TRACE Released lock at `/root/.cache/uv/sdists-v9/editable/df64fc0b914aef95/.lock`
  × Failed to build `rosen-cpp @ file:///app`
  ├─▶ The build backend returned an error
  ╰─▶ Call to `scikit_build_core.build.build_editable` failed (exit status: 1)
      [stdout]
      *** scikit-build-core 0.12.1 using CMake 4.3.2 (editable)
      *** Configuring CMake...
      loading initial cache file /tmp/tmpvlgwgkgf/build/CMakeInit.txt
      -- Configuring incomplete, errors occurred!
      [stderr]
      2026-05-08 23:32:26,416 - scikit_build_core - WARNING - Unsupported
      CMAKE_ARGS ignored: -DCMAKE_BUILD_TYPE=Release
      2026-05-08 23:32:26,416 - scikit_build_core
      - WARNING - Unsupported CMAKE_ARGS ignored:
      -DCMAKE_INSTALL_PREFIX=$PREFIX
      2026-05-08 23:32:26,417 - scikit_build_core - WARNING - Unsupported
      CMAKE_ARGS ignored: -DCMAKE_BUILD_TYPE=Release
      2026-05-08 23:32:26,417 - scikit_build_core
      - WARNING - Unsupported CMAKE_ARGS ignored:
      -DCMAKE_INSTALL_PREFIX=$PREFIX
      CMake Error: CMake was unable to find a build program corresponding to
      "Unix Makefiles".  CMAKE_MAKE_PROGRAM is not set.  You probably need to
      select a different build tool.
      CMake Error: CMAKE_CXX_COMPILER not set, after EnableLanguage

      *** CMake configuration failed
      hint: This usually indicates a problem with the package or the build
      environment.
```

Build logs for both the `uv` and `pixi-build` builds were captured in interactive sessions in `ghcr.io/prefix-dev/pixi:latest` Docker containers with

* `uv pip install -vv . &> uv_build_log.txt`
* `pixi install &> pixi-build_log.txt`

## Expectation

As `uv pip install` is able to execute the `scikit-build-core` Python package build then `pixi-build` should be able to as well.

## Workaround

`rattler-build` `v0.64.1` exports

```
CMAKE_GENERATOR='Unix Makefiles'
```

into the build environment in an non-configurable manner, which overrides `scikit-build-core`'s defaults.
To avoid this, provide `scikit-build-core` explicit arguments through the `[tool.scikit-build]` table to override the environment and restore the default settings.

```toml
[tool.scikit-build]
...
cmake.args = ["-GNinja"]
```

I'm not sure if the `rattler-build` behavior is intentional or not.
