#!/usr/bin/env bash
# Script to build the waifu2x-mac project (more) easily

# Works with Xcode 10.1 and waifu2x-mac as of commit ca0088b (2018-11-17)
# Place this script at the root of the waifu2x-mac folder, then
# chmod +x build.sh; ./build.sh;

# Define variables for coloured text
BOLD=$(tput bold); LINE=$(tput smul); LOFF=$(tput rmul); RESET=$(tput sgr0)
RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
WARNING="${BOLD}${YELLOW}${LINE}Warning:${RESET}${BOLD}"
ERROR="${BOLD}${RED}${LINE}Error:${RESET}${BOLD}"
INFO="${BOLD}${GREEN}${LINE}Info:${RESET}${BOLD}"

# Change the working directory to the directory containing the script
cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)

# Check if the script is in the as directory as the Xcode project
if [[ $(find . -name 'waifu2x-mac.xcodeproj' -d -maxdepth 1) ]]
then
  # Clean the base directory of previous build attempts
  UNTRACKED=$(git clean -dffnx) # dry run
  if [[ ${UNTRACKED} ]]
  then
    echo -e "${WARNING} The ${PWD##*/} directory will be cleaned of all" \
      "untracked files.${RESET}"
    echo "${UNTRACKED}" # list of files to delete
    read -n 1 -r -p "${BOLD}${LINE}Are you sure?${LOFF} (y/n) ${RESET}" CONFIRM
    case ${CONFIRM} in
      [Yy]* )
        echo
        git clean -dffx # delete ALL untracked files and folders
        ;;
      * ) # anything but Y cancels the operation
        echo
        echo "${ERROR} Build cancelled.${RESET}"
        exit 1
        ;;
    esac
  fi

  # Check to make sure Xcode.app is the active developer directory
  # N.B.: Command Line Tools are NOT sufficient
  if ! [[ $(xcrun xcode-select -p | grep "\.app") ]] # if not Xcode.app
  then # Try to find Xcode.app (or Xcode-beta.app)
    XCODEAPP=$(find /Applications -name 'Xcode*' -d -maxdepth 1 | head -n1)
    if [[ ${XCODEAPP} ]]
    then
      echo "${WARNING} Selecting Xcode for command line tools (requires" \
        "admin privileges).${RESET}"
      # Set Xcode.app as the active developer directory
      sudo xcrun xcode-select -s ${XCODEAPP}/Contents/Developer
      if ! [[ $(xcrun xcode-select -p | grep "\.app") ]] # still missing
      then
        echo "${ERROR} Xcode is still not selected as the active developer" \
          "directory.${RESET}"
        echo "${BOLD}If Xcode is installed, try the command:${RESET}" \
          "sudo xcode-select -s ${XCODEAPP}/Contents/Developer"
        exit 1 # Fails because Xcode.app is not selected
      fi
    else
      echo "${ERROR} Xcode isn't installed.${RESET}"
      echo "${BOLD}Please download and install Xcode from" \
        "${LINE}https://developer.apple.com/download/${RESET}"
      exit 1 # Fails if Xcode.app is not installed
    fi
  fi

  # Check for required Ruby gem and install it if missing
  if ! [[ $(gem list --local xcodeproj | grep xcodeproj) ]]
  then
    echo "${WARNING} Installing missing gem \"xcodeproj\" (requires admin" \
      "privileges).${RESET}"
    sudo gem install xcodeproj
    if ! [[ $(gem list --local xcodeproj | grep xcodeproj) ]]
    then # still missing
      echo "${ERROR} Ruby gem \"xcodeproj\" is still not installed.${RESET}"
      echo "${BOLD}If Ruby is installed, try the command:${RESET}" \
        "sudo gem install xcodeproj"
      exit 1 # xcodeproj is required to build CLI version
    fi
  fi

  # Configuring dependencies for command-line program
  echo "${BOLD}${LINE}Configuring...${RESET}"
  cd Dependencies
  swift package update
  rake xcodeproj
  cd ..

  # Building with Xcode
  echo "${BOLD}${LINE}Building...${RESET}"
  xcodebuild clean build -quiet -scheme waifu2x-mac-app CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO -derivedDataPath DerivedData > /dev/null
  EXITCODE=$?
  if [[ ${EXITCODE} -eq '0' ]] # success
  then # move the build to a more convenient directory
    mv ./DerivedData/Build/Products/Release ./build
    rm -r ./DerivedData
    echo "${INFO} Build success.${RESET}"
    ls -d -n1 build/* # show where the build is
    exit 0
  else
    echo "${ERROR} Build failed.${RESET}"
    git clean -dffx # delete ALL untracked files and folders
    exit ${EXITCODE}
  fi
else # the script is not in the waifu2x-mac folder
  echo "${BOLD}${RED}This script must be placed in the same directory as" \
    "\"waifu2x-mac.xcodeproj\".${RESET}"
  exit 1
fi
exit 1
