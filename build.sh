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

# Check if the script is in the same directory as the Xcode project
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
        echo >&2
        git clean -dffx # delete ALL untracked files and folders
        ;;
      * ) # anything but Y cancels the operation
        echo >&2
        echo "${ERROR} Build cancelled.${RESET}" >&2
        exit 1
        ;;
    esac
  fi

  # Check to make sure Xcode.app is the active developer directory
  # N.B.: Command Line Tools are NOT sufficient
  ATTEMPT=0
  until [[ $(xcrun xcode-select -p 2> /dev/null | grep "\.app") ]]
  do # Try to find Xcode.app (or Xcode-beta.app)
    ((++ATTEMPT))
    if [[ ${ATTEMPT} -eq 3 ]]
    then
      echo "${ERROR} Xcode couldn't be selected as the active developer" \
        "directory.${RESET}" >&2
      echo "${BOLD}Please download and install Xcode from" \
        "${LINE}https://developer.apple.com/download/${RESET}" >&2
      echo "${BOLD}If Xcode is installed, try the command:${RESET}" \
        "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" >&2
      exit 1 # Fails because Xcode.app couldn't be selected
    fi
    XCODEAPP=$(find /Applications -name 'Xcode*.app' -d -maxdepth 1 | head -n1)
    if [[ ${XCODEAPP} ]] # Xcode installed but not selected
    then # try to select Xcode
      if [[ ${ATTEMPT} -eq 1 ]]
      then
        echo "${WARNING} Selecting Xcode for command line tools (requires" \
        "admin privileges).${RESET}"
      fi
      # Set Xcode.app as the active developer directory
      sudo xcrun xcode-select -s ${XCODEAPP}/Contents/Developer 2> /dev/null
      sudo xcrun xcodebuild -license accept 2> /dev/null
      continue # recheck if Xcode selected
    else # Xcode not installed
      if ! [[ $(type mas 2> /dev/null) ]] # check for Mac App Store CLI
      then
        if ! [[ $(type brew 2> /dev/null) ]] # check for Homebrew pkg manager
        then
          if [[ ${ATTEMPT} -eq 1 ]]
          then
            echo "${WARNING} Installing Homebrew.${RESET}"
          fi
          /usr/bin/ruby -e "$(curl -fsSL \
          https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi
        echo "${WARNING} Installing Mac App Store CLI package manager.${RESET}"
        brew install mas # Mac App Store CLI package manager
      fi
      XCODEMAS=$(mas search Xcode | \
        sed -E "s/^ +([0-9]+) +Xcode +\(.+\)$/\1/" | grep -E "^[0-9]+$")
      XCODESIZE=$(mas info $XCODEMAS | grep "Size:")
      if [[ ${ATTEMPT} -eq 1 ]]
      then
        echo "${WARNING} Downloading Xcode. (${XCODESIZE})${RESET}"
      fi
      mas install ${XCODEMAS}
      continue # recheck if Xcode installed
    fi
  done

  # Check for required Ruby gem and install it if missing
  if ! [[ $(gem list --local xcodeproj | grep xcodeproj) ]]
  then
    echo "${WARNING} Installing missing gem \"xcodeproj\" (requires admin" \
      "privileges).${RESET}"
    sudo gem install xcodeproj
    if ! [[ $(gem list --local xcodeproj | grep xcodeproj) ]]
    then # still missing
      echo "${ERROR} Ruby gem \"xcodeproj\" still not found.${RESET}" >&2
      echo "${BOLD}If Ruby is installed, try the command:${RESET}" \
        "sudo gem install xcodeproj" >&2
      exit 1 # xcodeproj is required to build CLI version
    fi
  fi

  # Agreeing to the Xcode license
  if [[ $(xcodebuild -help 2>&1 | grep "Agreeing") ]]
  then
    echo "${WARNING} Agreeing to the Xcode license (requires admin" \
      "privileges).${RESET}"
    echo "${BOLD}You can read the license at" \
      "${LINE}https://www.apple.com/legal/sla/docs/xcode.pdf${LOFF}${RESET}"
    sudo sudo xcrun xcodebuild -license accept
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
    echo "${ERROR} Build failed.${RESET}" >&2
    git clean -dffx >&2 # delete ALL untracked files and folders
    exit ${EXITCODE}
  fi
else # the script is not in the waifu2x-mac folder
  echo "${ERROR}This script must be placed in the same directory as" \
    "\"waifu2x-mac.xcodeproj\".${RESET}" >&2
  exit 1
fi
exit 1
