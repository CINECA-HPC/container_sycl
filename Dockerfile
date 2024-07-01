ARG CUDA_VERSION=11.4.3

FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

# Tunables
ARG INTEL_BASEKIT_VERSION=2024.2.0.634
ARG INTEL_HPCKIT_VERSION=2024.2.0.635
ARG CMAKE_VERSION=3.29.6

WORKDIR /root
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    # Installing what we need:
    # curl             is to download CodePlay NVIDIA add-on (the recommended way)
    # wget             is to download cmake and Intel OneAPI compiler installers
    # ca-certificates  is for HTTPS certificates
    # intel-opencl-icd is for Intel LevelZero driver
    # g++              is for g++ and ld, needed by Intel OneAPI compiler
    # make             is for cmake's generation
    # libopenblas-dev  is for BLAS header and library
    # clang-format     is needed to check code formatting
    apt-get install --no-install-recommends -y curl wget ca-certificates g++ make libopenblas-dev intel-opencl-icd clang-format && \
    # Download and install Intel BaseKit
    wget --no-verbose https://registrationcenter-download.intel.com/akdlm/IRC_NAS/9a98af19-1c68-46ce-9fdd-e249240c7c42/l_BaseKit_p_${INTEL_BASEKIT_VERSION}_offline.sh -O intel_basekit.sh && \
    sh ./intel_basekit.sh -a --action install --components intel.oneapi.lin.dpcpp-cpp-compiler:intel.oneapi.lin.mkl.devel --silent --eula accept && \
    rm -f ./intel_basekit.sh && \
    # Download and install Intel HPCKit
    wget --no-verbose https://registrationcenter-download.intel.com/akdlm/IRC_NAS/d4e49548-1492-45c9-b678-8268cb0f1b05/l_HPCKit_p_${INTEL_HPCKIT_VERSION}_offline.sh -O intel_hpckit.sh && \
    sh ./intel_hpckit.sh -a --action install --components intel.oneapi.lin.dpcpp-cpp-compiler --silent --eula accept && \
    rm -f ./intel_hpckit.sh && \
    # Install Cmake
    wget --no-verbose https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh && \
    chmod +x cmake-${CMAKE_VERSION}-linux-x86_64.sh && \
    ./cmake-${CMAKE_VERSION}-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm -f ./cmake-${CMAKE_VERSION}-linux-x86_64.sh && \
    # Install CodePlay NVIDIA add-on
    curl -LOJ "https://developer.codeplay.com/api/v1/products/download?product=oneapi&variant=nvidia&version=2024.2.0&filters[]=12.0&filters[]=linux" && \
    sh ./oneapi-for-nvidia-gpus-2024.2.0-cuda-12.0-linux.sh && \
    rm -f ./oneapi-for-nvidia-gpus-2024.2.0-cuda-12.0-linux.sh && \
    # Remove unneeded stuff
    apt-get remove curl wget ca-certificates -y && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    # apt/apt-get will not work after this point
    rm -rf /var/lib/apt/lists/* && \
    # Setup environment variables automatically on startup
    echo ". /opt/intel/oneapi/setvars.sh" >> ~/.bashrc
