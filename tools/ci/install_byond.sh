#!/bin/bash
set -euo pipefail

# BYOND_MAJOR and BYOND_MINOR can be explicitly set, such as in alt_byond_versions.txt
if [ -z "${BYOND_MAJOR+x}" ]; then
  source dependencies.sh
fi

if [ -d "$HOME/BYOND/byond/bin" ] && grep -Fxq "${BYOND_MAJOR}.${BYOND_MINOR}" $HOME/BYOND/version.txt;
then
  echo "Using cached directory."
else
  echo "Setting up BYOND version $BYOND_MAJOR.$BYOND_MINOR"
  rm -rf "$HOME/BYOND"
  mkdir -p "$HOME/BYOND"
  cd "$HOME/BYOND"

  # Download BYOND for this platform.
  case "$RUNNER_OS" in
    "Linux")
      echo "...for Linux."
      curl "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip
      ;;

    "Windows")
      echo "...for Windows."
      curl "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond.zip" -o byond.zip
      ;;

    *)
      echo "The OS for this runner does not have a script to download BYOND. If BYOND is available for this OS, please fix this!"
      exit 1
      ;;
  esac

  unzip byond.zip
  rm byond.zip

  # Perform any extra steps needed to set up BYOND on this platform.
  case "$RUNNER_OS" in
    "Linux")
      cd byond
      make here
      cd ..
      ;;

    "Windows")
      echo "DM_EXE=$HOME/BYOND/byond/bin/dm.exe" >> $GITHUB_ENV
      ;;

    *)
      echo "The OS for this runner does not have a script to install BYOND. If BYOND is available for this OS, please fix this!"
      exit 1
      ;;
  esac

  echo "$BYOND_MAJOR.$BYOND_MINOR" > "$HOME/BYOND/version.txt"
  cd ~/
fi
