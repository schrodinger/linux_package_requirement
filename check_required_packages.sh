#!/bin/bash

function identify_platform() {
    echo "$(. /etc/os-release && echo "$ID")"
}

platform=$(identify_platform)
echo "platform is $platform"
if [[ -z $platform ]]; then
    echo "ERROR: This system couldn't be identified."
    exit 1
else
    echo "INFO: This system was identified as \"$platform\"."
fi

function get_required_packages() {
    platform=$1

    case "${platform,,}" in
    "centos" | "redhat" | "rocky")
        required_packages=('fontconfig' 'libX11' 'libxkbcommon-x11' 'xcb-util-renderutil')
        ;;
    "ubuntu")
        required_packages=('fontconfig')
        ;;
    *)
        echo "WARNING: List of dependencies for distribition \"$platform\" is unknown."
        echo "Please install libX11 and/or libfontconfig packages."
        return 1
        ;;
    esac

    echo "${required_packages[@]}"
}

required_packages=$(get_required_packages "$platform")

function check_if_package_installed() {
    platform=$1

    case "$platform" in
    "ubuntu")
        cmd="dpkg -s"
        ;;
    "centos")
        cmd="yum list"
        ;;
    "redhat" | "suse")
        cmd="rpm -qa | grep"
        ;;
    *)
        echo "WARNING: package check command for distribition \"$platform\" is unknown."
        return 1
        ;;
    esac

    echo $cmd
}

package_check_cmd=$(check_if_package_installed "$platform")

function get_package_manager() {
    platform="$1"

    case "$platform" in
    "centos" | "redhat" | "rocky")
        package_manager="yum"
        ;;
    "ubuntu")
        package_manager="apt-get"
        ;;
    "suse")
        package_manager="zypper"
        ;;
    *)
        echo "WARNING: package manager for distribition \"$platform\" is unknown."
        ;;
    esac

    echo "$package_manager"
}

package_manager=$(get_package_manager "$platform")

function get_missing_package() {
    required_packages="$1"
    cmd="$2"
    package_manager="$3"
    missing_packages=()

    for package in ${required_packages}; do
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

echo "required_packages for your platform are: ${required_packages}"
get_missing_package "${required_packages[@]}" "$package_check_cmd" "$package_manager"
