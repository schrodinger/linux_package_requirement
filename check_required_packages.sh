#!/bin/bash

set -uo pipefail

function identify_platform() {
    platform="$(. /etc/os-release && echo "$ID")"
}

identify_platform

if [[ -z "$platform" ]]; then
    echo "ERROR: This system couldn't be identified."
    exit 1
else
    echo "INFO: This system was identified as \"$platform\"."
fi

function get_required_packages() {
    case "${platform,,}" in
    "centos" | "rhel" | "rocky")
        required_packages=('fontconfig' 'libX11' 'libxkbcommon-x11' 'xcb-util-renderutil' 'libglvnd-egl' 'libglvnd-opengl' 'libxkbcommon')
        ;;
    "ubuntu")
        required_packages=('fontconfig' 'libegl1' 'libopengl0' 'libxkbcommon0' 'libxcb-xinput0')
        ;;
    *)
        echo "WARNING: List of dependencies for distribution \"$platform\" is unknown."
        echo "Please install libX11 and/or libfontconfig packages."
        exit
        ;;
    esac
}

get_required_packages

function check_if_package_installed() {
    case "$platform" in
    "ubuntu")
        cmd="dpkg -s"
        ;;
    "centos")
        cmd="yum list"
        ;;
    "rhel" | "rocky" | "sled" | "sles")
        cmd="rpm -q"
        ;;
    *)
        echo "WARNING: package check command for distribution \"$platform\" is unknown."
        ;;
    esac
}

check_if_package_installed

function get_package_manager() {

    case "$platform" in
    "centos" | "rhel" | "rocky")
        package_manager="yum"
        ;;
    "ubuntu")
        package_manager="apt-get"
        ;;
    "sles" | "sled")
        package_manager="zypper"
        ;;
    *)
        echo "WARNING: package manager for distribution \"$platform\" is unknown."
        ;;
    esac
}

get_package_manager

function get_missing_package() {
    missing_packages=()
    for package in ${required_packages[@]}; do
        $cmd $package
        if [[ $? != 0 ]]; then
            missing_packages+=($package)
        fi
    done

    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo "Your machine has the required packages."
    else
        echo "(${missing_packages[@]}) is/are required package/s to use Schrödinger suite. Please install them using:
        sudo $package_manager install ${missing_packages[@]}"
        exit 1
    fi
}

echo "required_packages for your platform are: ${required_packages[@]}"

get_missing_package
