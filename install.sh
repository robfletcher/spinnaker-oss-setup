#!/bin/bash
if [ "$#" -eq 0 ]; then
  echo "usage: install.sh <github_username>"
  echo
  echo "github_username   Your Github username"
  exit 1
fi

if [[ `uname` -ne "Darwin" ]]; then
  echo "Only supports OSX at this point (contribs welcome!)"
  exit 1
fi

if ! type "bork" > /dev/null; then
  echo "Dependency not met: bork, installing..."
  git clone https://github.com/mattly/bork $HOME/.bork
  ln -sf $HOME/.bork/bin/bork /usr/local/bin/bork
fi

echo "export GITHUB_USERNAME=$1" | tee /tmp/spinnaker-setup.sh
source /tmp/spinnaker-setup.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

bork do ok symlink $HOME/.spinnaker-env.sh $DIR/files/env.sh
if did_error; then
  echo "Failed symlinking environment"
  exit 1
fi
source $HOME/.spinnaker-env.sh

bork satisfy satisfy/osx.sh
if did_error; then
  echo "Failed satisfying OSX requirements"
  exit 1
fi

bork satisfy satisfy/repos.sh
if did_error; then
  echo "Failed satisfying repo setup"
  exit 1
fi

bork do ok directory $HOME/.spinnaker
if did_error; then
  mkdir -p $HOME/.spinnaker
fi
bork do ok symlink $HOME/.spinnaker/logback-defaults.xml $DIR/files/logback-defaults.xml
if did_error; then
  echo "Failed symlinking logging defaults"
  exit 1
fi

# TODO rz - should be automatic
echo "Add 'source $HOME/.spinnaker-env.sh' to your shell"
