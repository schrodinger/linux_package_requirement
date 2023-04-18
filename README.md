# linux_package_requirement
Script to check required packages for Schrödinger suite on Linux machine

## How to use

* Identify the release version of the suite. You can do this by setting SCHRODINGER to the location of the suite, and run ```$SCHRODINGER/run python3 -c 'from schrodinger import get_release_name; print(get_release_name())'```
* Download the packages.txt from packages corresponding to the linux distribution and release, and run ```sh check_required_packages.sh <packages.txt>```
* This will report any missing packages and how to install them using package manager to the terminal.
