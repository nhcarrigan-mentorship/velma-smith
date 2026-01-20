#! /bin/env bash

# this script is just going to take whatever asm file we feed it and compile it as elf64
# usage build.sh $FILENAME (include extension)
FILENAME=$1
NAME="$FILENAME%.*"

shutdown() {
  echo "something went wrong"
  exit 1
}

continueOrNah() {
  read -rp "Continue? (y/n): " -n 1 choice
  if [[ "$choice" =~ ^[Yy] ]]; then
    echo "continuing..."
  
  else
    echo "shutting down..."
    shutdown
  fi
}

if [ -z "$FILENAME" ]; then
  echo "FILENAME IS EMPTY"
  echo "Usage: ./build.sh FILENAME (include extension)"
  shutdown
fi


echo "made it past the first test"

if [ -z "$NAME" ]; then
  echo "NAME IS EMPTY"
  echo "Usage: ./build.sh FILENAME (include extension)"
  shutdown
fi

echo "made it past the second test"

build() {
  readonly SCRIPT_DIR="$(cd -- "$(dirname -- "$BASH_SOURCE")" && pwd)"

  echo "$SCRIPT_DIR"
  
  continueOrNah


  BIN_DIR="$SCRIPT_DIR/bin"
  if [[ ! -d BIN_DIR ]]; then
    mkdir -p "$BIN_DIR"
  fi
  nasm -f elf64 -o "${BIN_DIR}/${NAME}.o" "${SCRIPT_DIR}/${FILENAME}"

}

build
