#!/bin/sh

function identify_platform () {
        platform=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)
        echo "$platform"
}

platform=$( identify_platform )


function get_required_packages () {
    arg1=$1

    if [[ ${arg1,,} == *"centos"* ]];
    then
        required_packages=('fontconfig' 'libX11' 'libxkbcommon-x11' 'xcb-util-renderutil' 'test_package')
    elif [[ ${arg1,,} == *"ubuntu"* ]];
    elif [[ ${arg1,,} == *"redhat"* ]];
    then
        required_packages=('fontconfig', 'libX11', 'libxkbcommon-x11', 'xcb-util-renderutil')
    elif [[ ${arg1,,} == *"rocky"* ]];
    then
        required_packages=('fontconfig', 'libX11', 'libxkbcommon-x11', 'xcb-util-renderutil'i)
    fi
    echo "${required_packages[@]}"
}

required_packages=$( get_required_packages "$platform" )


function check_if_package_installed () {
    arg1=$1
    # Debian / Ubuntu
    if [[ ${arg1,,} == *"debian"* || ${arg1,,}  == *"ubuntu"* ]];
    then
        cmd="dpkg -s"

    # centos
    elif [[ ${arg1,,} == *"centos"* ]];
    then
        cmd="yum list"

    # redhat / Fedora / Suse
    elif [[ ${arg1,,}  == *"redhat"* || ${arg1,,} == *"suse"* || ${arg1,,} == *"fedora"* ]];
    then
        cmd="rpm -qa | grep"
    fi
    echo $cmd
}

package_check_cmd=$( check_if_package_installed "$platform" )


function get_missing_package () {
    required_packages="$@"
    cmd="$2"

    for package in ${required_packages};
    do
        echo "package: $package, cmd: $cmd"
        $cmd $package
        if [[ $? != 0 ]];
        then
            echo "$package is a required package to use Schrödinger suite. 
            Please install it using: sudo <package_manager place holder> $package."
        fi
    done
}

echo "required_packages for your platform are: ${required_packages}"
get_missing_package "${required_packages[@]}" "$package_check_cmd"


function package_install_cmd () { 
     # Do we want to suggest specific package manager per distro?
}