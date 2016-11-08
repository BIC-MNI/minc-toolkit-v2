#!/bin/bash
set -euo pipefail

export PACKAGECLOUD_TOKEN=fillme
export PACKAGECLOUD_USER=username
export PACKAGECLOUD_REPO=minc-toolkit-v2

export VERSION=$(grep -o -E 'MINC_TOOLKIT_PACKAGE_VERSION_MAJOR.*[0-9]+' CMakeLists.txt  | grep -o -E '[0-9]+').$(grep -o -E 'MINC_TOOLKIT_PACKAGE_VERSION_MINOR.*[0-9]+' CMakeLists.txt  | grep -o -E '[0-9]+').$(grep -o -E 'MINC_TOOLKIT_PACKAGE_VERSION_PATCH.*[0-9]+' CMakeLists.txt  | grep -o -E '[0-9]+')

#Build currently fails for el-6 and debian-wheezy due to old cmake
for BUILD_NAME in el-6 el-7 fedora-23 fedora-24 fedora-25 ubuntu-trusty ubuntu-precise ubuntu-xenial ubuntu-yakkety debian-jessie debian-wheezy debian-stretch
do

    export OS=$(echo $BUILD_NAME | grep -o -E '^.*\-' | tr -d '-' || true)
    export DIST=$(echo $BUILD_NAME | grep -o -E '\-.*$' | tr -d '-' || true)

    echo "Building OS=${OS}, DIST=${DIST}"
    ./packpack/packpack || true

    shopt -s nullglob

    for file in build/*.deb build/*.rpm
    do
        package_cloud push ${PACKAGECLOUD_USER}/${PACKAGECLOUD_REPO}/${OS}/${DIST} $file || true
    done

done
