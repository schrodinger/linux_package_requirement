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
        return 1
        ;;
    esac

    echo "${required_packages[@]}"
}

required_packages=$(get_required_packages "$platform")

function check_if_package_installed() {
    platform=$1

    case "$platform" in
    "debian" | "ubuntu")
        cmd="dpkg -s"
        ;;
    "centos")
        cmd="yum list"
        ;;
    "redhat" | "suse" | "fedora")
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

function get_missing_package() {
    required_packages="$1"
    cmd="$2"

    for package in ${required_packages}; do
        echo "package: $package, cmd: $cmd"
        $cmd $package
        if [[ $? != 0 ]]; then
            echo "$package is a required package to use Schrödinger suite.
            Please install it using: sudo <package_manager place holder> $package."
        fi
    done
}

echo "required_packages for your platform are: ${required_packages}"
get_missing_package "${required_packages[@]}" "$package_check_cmd"

function package_install_cmd() {
    echo "Do we want to suggest specific package manager per distro?"
}
