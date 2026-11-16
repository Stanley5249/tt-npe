#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
set -euxo pipefail

# tt-npe compiles with -stdlib=libc++, whose headers are in the host prefix,
# not beside the compiler. Linking through the driver with it puts -lc++ after
# the objects, where --as-needed keeps it.
export CXXFLAGS="-isystem ${PREFIX}/include/c++/v1 ${CXXFLAGS}"
export LDFLAGS="${LDFLAGS} -stdlib=libc++"

# CMake 4 scans C++20 sources for modules and finds no clang-scan-deps.
cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
    -Wno-deprecated \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
cmake --build build
cmake --install build

# Make the binding and the scripts importable without PYTHONPATH.
mv "${PREFIX}"/lib/tt_npe_pybind*.so "${SP_DIR}/"
for script in tt_npe npe_analyze_noc_trace_dir fabric_post_process; do
    mv "${PREFIX}/bin/${script}.py" "${SP_DIR}/"
done
rm -f "${PREFIX}/bin/programmatic_workload_generation.py"
# Static archives, headers, and CMake files serve only C++ consumers.
rm -rf "${PREFIX}/include" "${PREFIX}/lib/cmake" "${PREFIX}/lib/pkgconfig" "${PREFIX}"/lib/*.a

mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/tt-npe.sh"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/tt-npe.sh"
