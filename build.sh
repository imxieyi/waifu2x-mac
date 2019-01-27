#!/bin/bash

# Script to build the waifu2x-mac project (more) easily
# Copyright (c) 2019 Mathieu Guimond-Morganti

# Place this script at the root of the waifu2x-mac folder, then
# chmod +x build.sh; ./build.sh;

# Works with Xcode 10.1 and imxieyi/waifu2x-mac repo as of commit ca0088b (2018-11-17)
# https://github.com/imxieyi/waifu2x-mac

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Change the working directory to the directory containing the script
cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)

# Check if the script is in the as directory as the Xcode project
if [[ $(find . -name 'waifu2x-mac.xcodeproj' -d -maxdepth 1) ]]
then

    # Clean the base directory of previous build attempts
    UNTRACKED=$(git clean -dffnx) # dry run
    if [[ $UNTRACKED ]]
    then
        echo -e "$(tput bold)$(tput setaf 3)$(tput smul)Warning:$(tput sgr0)$(tput bold) The ${PWD##*/} directory will be cleaned of all untracked files.$(tput sgr0)"
        echo "$UNTRACKED" # list of files to delete
        read -n 1 -r -p "$(tput bold)$(tput smul)Are you sure?$(tput rmul) (y/n) $(tput sgr0)" CONFIRM
        case $CONFIRM in
            [Yy]* )
                echo
                git clean -dffx # delete ALL untracked files and folders to start anew
                ;;
            * ) # anything but Y cancels the operation
                echo
                echo "$(tput bold)$(tput setaf 1)$(tput smul)Error:$(tput sgr0)$(tput bold) Build cancelled.$(tput sgr0)"
                exit 1
                ;;
        esac
    fi

    # Check for full Xcode.app
    if ! [[ $(xcrun xcode-select -p | grep "\.app") ]] # Xcode.app is not the active developer directory
    then
        XCODEAPP=$(find /Applications -name 'Xcode*' -d -maxdepth 1 | head -n1) # Chooses Xcode.app over Xcode-beta.app if both are installed
        if [[ $XCODEAPP ]]
        then
            echo "$(tput bold)$(tput setaf 3)$(tput smul)Warning:$(tput sgr0)$(tput bold) Selecting Xcode for command line tools (requires admin privileges).$(tput sgr0)"
            sudo xcrun xcode-select -s $XCODEAPP/Contents/Developer # Set Xcode.app as the active developer directory
            if ! [[ $(xcrun xcode-select -p | grep "\.app") ]] # still missing
            then
                echo "$(tput bold)$(tput setaf 1)$(tput smul)Error:$(tput sgr0)$(tput bold) Xcode is still not selected as the active developer directory.$(tput sgr0)"
                echo "$(tput bold)If Xcode is installed, try the command: $(tput sgr0)sudo xcode-select -s $XCODEAPP/Contents/Developer"
                exit # Fails if Xcode.app is not installed (Command Line Tools are not sufficient)
            fi
        else
            echo "$(tput bold)$(tput setaf 1)$(tput smul)Error:$(tput sgr0)$(tput bold) Xcode is not installed.$(tput sgr0)"
            echo "$(tput bold)Please download and install Xcode from: $(tput sgr0)$(tput smul)https://developer.apple.com/download/$(tput sgr0)"
            exit 1 # Fails if Xcode.app is not installed (Command Line Tools are not sufficient)
        fi
    fi

    # Check for required Ruby gem and install it if missing
    if ! [[ $(gem list --local xcodeproj | grep xcodeproj) ]]
    then
        echo "$(tput bold)$(tput setaf 3)$(tput smul)Warning:$(tput sgr0)$(tput bold) Installing missing gem \"xcodeproj\" (requires admin privileges).$(tput sgr0)"
        sudo gem install xcodeproj
        if ! [[ $(gem list --local xcodeproj | grep xcodeproj) ]] # still missing
        then
            echo "$(tput bold)$(tput setaf 1)$(tput smul)Error:$(tput sgr0)$(tput bold) Ruby gem \"xcodeproj\" is still not installed.$(tput sgr0)"
            echo "$(tput bold)If Ruby is installed, try the command: $(tput sgr0)sudo gem install xcodeproj"
            exit 1 # Fails if xcodeproj is not installed (required to build command-line program)
        fi
    fi

    # Configuring dependencies for command-line program
    echo "$(tput bold)$(tput smul)Configuring...$(tput sgr0)"
    cd Dependencies
    swift package update
    rake xcodeproj
    cd ..

    # Building with Xcode
    echo "$(tput bold)$(tput smul)Building...$(tput sgr0)"
    BUILD=$(xcodebuild clean build -quiet -scheme waifu2x-mac-app CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -derivedDataPath DerivedData)
    if ! [[ $(mv ./DerivedData/Build/Products/Release ./build 2>&1) ]] # if success, the Release directory exists, so move it to a more convenient location
    then
        rm -r ./DerivedData
        echo "$(tput bold)$(tput setaf 2)$(tput smul)Info:$(tput sgr0)$(tput bold) Build success.$(tput sgr0)"
        ls -d -n1 build/* # show where the build is
        exit 0
    else
        echo "$(tput bold)$(tput setaf 1)$(tput smul)Error:$(tput sgr0)$(tput bold) Build failed.$(tput sgr0)"
        git clean -dffx # clean ALL untracked files and folders to start anew
        exit 1
    fi
else # the script is not in the waifu2x-mac folder
    echo "$(tput bold)$(tput setaf 1)This script must be placed in the same directory as \"waifu2x-mac.xcodeproj\".$(tput sgr0)"
    exit 1
fi
exit 0
