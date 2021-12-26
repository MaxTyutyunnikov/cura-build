#!/bin/bash
#
# This script is used in the docker container to create a Cura AppImage.
#

set -e

# Get where this script resides
SCRIPT_DIR="$( cd $( dirname "${BASH_SOURCE[0]}" ) >/dev/null 2>&1 && pwd )"
ROOT_DIR="${SCRIPT_DIR}/.."

# Make sure that cura-build-environment is present
if [[ -z "${CURA_BUILD_ENV_PATH}" ]]; then
    echo "CURA_BUILD_ENV_PATH is not defined. Cannot find the installed cura build environment."
    exit 1
fi

export PATH="${CURA_BUILD_ENV_PATH}/bin:${PATH}"
export PKG_CONFIG_PATH="${CURA_BUILD_ENV_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export CMAKE_INSTALL_PREFIX=${CURA_BUILD_ENV_PATH}
export LD_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib/
export PYTHONPATH=${CMAKE_INSTALL_PREFIX}/lib/python3/dist-packages/:${CMAKE_INSTALL_PREFIX}/lib/python3.5:${CMAKE_INSTALL_PREFIX}/lib/python3.5/site-packages/

# Make sure that a directory for saving the resulting AppImage exists
CURA_APPIMAGES_OUTPUT_DIR="${CURA_APPIMAGES_OUTPUT_DIR:-/home/ultimaker/appimages}"
if [[ ! -d "${CURA_APPIMAGES_OUTPUT_DIR}" ]]; then
    mkdir -p "${CURA_APPIMAGES_OUTPUT_DIR}"
fi

# Set up Cura build configuration in environment variables
export CURA_VERSION_MAJOR="${CURA_VERSION_MAJOR:-0}"
export CURA_VERSION_MINOR="${CURA_VERSION_MINOR:-0}"
export CURA_VERSION_PATCH="${CURA_VERSION_PATCH:-0}"
export CURA_VERSION_EXTRA="${CURA_VERSION_EXTRA:-}"
export CURA_BUILD_NAME="${CURA_BUILD_NAME:-master}"

export CURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT:-https://api.ultimaker.com}"
export CURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION:-1}"
export CURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT:-https://account.ultimaker.com}"

# Set up development environment variables
#source /opt/rh/devtoolset-7/enable
export PATH="${CURA_BUILD_ENV_PATH}/bin:${PATH}"
export PKG_CONFIG_PATH="${CURA_BUILD_ENV_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"

export CMAKE_INSTALL_PREFIX=${CURA_BUILD_ENV_PATH}
#export LD_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib/
export PYTHONPATH=${CMAKE_INSTALL_PREFIX}/lib/python3/dist-packages/:${CMAKE_INSTALL_PREFIX}/lib/python3.5:${CMAKE_INSTALL_PREFIX}/lib/python3.5/site-packages/

mkdir -p ${ROOT_DIR}/build
cd ${ROOT_DIR}/build

#echo ${PYTHONPATH}
#/bin/bash

# Create AppImage
cmake "${ROOT_DIR}" \
    -DCMAKE_PREFIX_PATH="${CURA_BUILD_ENV_PATH}" \
    \
    -DPYTHON3_PACKAGES_PATH="${CMAKE_INSTALL_PREFIX}/lib/python3/site-packages" \
    -DPYTHON3_LIBRARY="${CMAKE_INSTALL_PREFIX}/lib/libpython3.so" \
    -DPYTHON_INCLUDE_DIR="${CMAKE_INSTALL_PREFIX}/include/python3.5" \
    -DPYTHON3_EXECUTABLE="${CMAKE_INSTALL_PREFIX}/bin/python3" \
    \
    -DCURA_VERSION_MAJOR="${CURA_VERSION_MAJOR}" \
    -DCURA_VERSION_MINOR="${CURA_VERSION_MINOR}" \
    -DCURA_VERSION_PATCH="${CURA_VERSION_PATCH}" \
    -DCURA_VERSION_EXTRA="${CURA_VERSION_EXTRA}" \
    -DCURA_BUILD_NAME="${CURA_BUILD_NAME}" \
    -DCURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT}" \
    -DCURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION}" \
    -DCURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT}" \
    -DSIGN_PACKAGE=OFF
make

# Copy the appimage to the output directory
chmod a+x Cura-*.AppImage
cp Cura-*.AppImage "${CURA_APPIMAGES_OUTPUT_DIR}/"
