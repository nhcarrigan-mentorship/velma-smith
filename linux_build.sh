#! /bin/env bash

# this script is just going to take whatever asm file we feed it and compile it as elf64
# usage build.sh $FILENAME (include extension) $DEBUG_FLAG
FILENAME=$1
NAME="${FILENAME%.*}"

DEBUG_FLAG=$2

shutdown() {
  echo "something went wrong"
  exit 1
}

continueOrNah() {
  read -rp "Continue? (y/n): " -n 1 choice
  if [[ "$choice" =~ ^[Yy] ]]; then
    echo ""
    echo "continuing..."
  
  else
    echo ""
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

echo "$FILENAME"
echo "$NAME"

continueOrNah


build() {

  set +x
  
  readonly SCRIPT_DIR="$(cd -- "$(dirname -- "$BASH_SOURCE")" && pwd)"

  echo "$SCRIPT_DIR"
  
  SRC_DIR="${SCRIPT_DIR}/src"

  echo "$SRC_DIR"
  
  BIN_DIR="$SCRIPT_DIR/bin"
  
  echo "$BIN_DIR"
  
  continueOrNah

  FILEPATH="${SRC_DIR}/${FILENAME}"

  OBJECTPATH="${BIN_DIR}/${NAME}.o"
  
  if [[ ! -d BIN_DIR ]]; then
    mkdir -p "$BIN_DIR"
  fi
  if [[ ! -f "$FILEPATH" ]]; then
    echo "File at: '${FILEPATH}' does not exist"
    shutdown
  fi

  OUTPUT="${BIN_DIR}/${NAME}"
  nasm -f elf64 -g -F dwarf -dLINUX -o "${OBJECTPATH}" "${FILEPATH}"
  ld -o "${OUTPUT}" "${OBJECTPATH}"
  set +x
}

build
