#!/usr/bin/env bash
set -e

if [ "$(git rev-parse --abbrev-ref HEAD)" != "master" ]; then
  echo ">>> error: must run from the branch 'master'"
  exit 1
fi

if [ "$(git rev-parse --show-prefix)" != "" ]; then
  echo ">>> error: must run from the git root"
  exit 1
fi

if [ -d "$PWD/.doc" ]; then
  read -p ">>> .doc exists. remove? [Yn] " -n 1 -r; echo
  if [[ $REPLY == "Y" ]]; then
    rm -vrf .doc
  else
    echo ">>> fine, be that way"
    exit 1
  fi
fi

echo ">>> running yard:"
yard doc -o .doc

echo ">>> checking out gh-pages:"
git checkout gh-pages

echo ">>> removing old stuff:"
rm -rvf *

echo ">>> moving .doc to root:"
mv -v .doc/* .
rm -rf .doc

echo ">>> hip hop hooray"
git diff

read -p ">>> commit changes? [Yn] " -n 1 -r; echo
if [[ $REPLY == "Y" ]]; then
  git commit -a -m "update yard documentation"

  read -p ">>> push changes? [Yn] " -n 1 -r; echo
  if [[ $REPLY == "Y" ]]; then
    git push
    git checkout master
    exit 0
  else
    echo ">>> okay then"
    git branch
    exit 0
  fi
else
  echo ">>> cool"
  git branch
  exit 0
fi

exit 1
