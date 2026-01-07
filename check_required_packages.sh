#!/bin/bash

set -euo pipefail

# Detects the OS distribution and version.
function identify_platform() {
    platform="$(. /etc/os-release && echo "$ID")"
    version_id="$(. /etc/os-release && echo "$VERSION_ID")"
    major_version="${version_id%%.*}"
}

# Determines which packages are required based on the distribution or the external requirements file fed as input.
#
# Basic: Requirements needed for the distribution is checked if no input file is provided.
# Extensive: For extensive check for the release, the package requirements of the release corresponding to the linux distribution
# is fed as an argument to the script.
function get_required_packages() {
    if [[ $# -gt 0 ]]; then
        package_file=$1
        required_packages="$(awk '{print $1}' $package_file)"
        if [[ -z "$required_packages" ]]; then
            echo "ERROR: could not parse required packages for $platform from $package_file"
            exit 1
        fi
        return
    fi

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
        echo "List of supported platforms can be found at: https://www.schrodinger.com/supportedplatforms"
        exit 1
        ;;
    esac
}

# Selects the command according to the OS to check if a package is installed.
function check_if_package_installed() {
    case "$platform" in
    "ubuntu")
        cmd="dpkg -s"
        ;;
    "centos" | "rhel" | "rocky" | "sled" | "sles")
        cmd="rpm -q"
        ;;
    *)
        echo "WARNING: package check command for distribution \"$platform\" is unknown."
        ;;
    esac
}

# Determines the appropriate package manager according to the OS.
function get_package_manager() {

    case "$platform" in
    "centos" | "rhel" | "rocky")
        package_manager="yum"
        if [[ "$major_version" -gt 7 ]]; then
          package_manager="dnf"
        fi
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

# Identifies if additional repositories (like EPEL) are needed
function get_extra_repos() {
  extra_repos=()
  case "$platform" in
    "centos" | "rhel" | "rocky")
        extra_repos+=("epel-release")
        ;;
    *)
        ;;
    esac
}

# Iterate through required packages and suggests how to install if missing.
function get_missing_package() {
    missing_packages=()
    for package in ${required_packages[@]}; do
        if ! ($cmd $package); then
            missing_packages+=($package)
        fi
    done

    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo "Your machine has the required packages."
    else
        echo "(${missing_packages[@]}) is/are required package/s to use Schrödinger suite. Please install them using:"
        if [ ${#extra_repos[@]} -gt 0 ]; then
            echo -e "\tsudo $package_manager install ${extra_repos[@]}"
        fi
        echo -e "\tsudo $package_manager install ${missing_packages[@]}"
        exit 1
    fi
}

## Main execution

# Identify the platform and version
identify_platform
if [[ -z "$platform" ]]; then
    echo "ERROR: This system couldn't be identified."
    exit 1
else
    echo "INFO: This system was identified as \"$platform\"."
fi

# Get the required packages for the platform and check if they are installed

get_required_packages "$@"
check_if_package_installed
get_package_manager
get_extra_repos
echo -e "required_packages for your platform are: \n${required_packages[@]}"
get_missing_package
