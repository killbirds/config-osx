#!/bin/bash

isRecursive() {
  if [ -f _recursive_ ]; then
    echo true
  else
    echo false
  fi
}

isIgnored() {
  local files=( *.swp _recursive_ )
  for file in "${files[@]}"; do
    if [ $1 == $file ]; then
      return 0
    fi
  done
  return 1
}

install() {
  pushd $1 > /dev/null

  local base=${2}
  local recursive=${3-`isRecursive`}

  echo
  echo "INSTALL: $1 $base $recursive"
  echo

  if [ ! -d $base ]; then
    mkdir -p $base
  fi

  local current=`pwd`
  local files=(`ls -lA1`)

  for file in "${files[@]}"; do
    local src=$current/$file
    local target=$base/$file

    rm -rf $target

    if (isIgnored $file); then
      continue
    elif [ $recursive == true -a -d $src ]; then
      (install $file $target)
    elif [ -f $src -a $file == _install_ ]; then
      eval $src
    else
      echo "ln -s $src $target"
      ln -s $src $target
    fi
  done

  popd > /dev/null
}

install . ${1-~}

