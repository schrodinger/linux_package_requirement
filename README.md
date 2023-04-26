# linux_package_requirement
Script to check required packages for Schrödinger suite on Linux machine

## How to use

* Download the script which checks for required packages of the distribution [check_required_package.sh](https://raw.githubusercontent.com/schrodinger/linux_package_requirement/main/check_required_packages.sh)
* Running the script as-is checks for a limited requirement needed for your distribution, and report missing packages if any.
* If you want to do an extensive check, download the package requirements of the release corresponding to your linux distribution from [packages](https://github.com/schrodinger/linux_package_requirement/tree/main/packages) and feed as an argument to the script. For example for centos distribution and 2023-2 release, download [centos 2023-2](https://raw.githubusercontent.com/schrodinger/linux_package_requirement/main/packages/centos/2023-2/packages.txt) and run ```check_required_packages.sh packages.txt```
