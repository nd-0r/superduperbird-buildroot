#!/bin/bash

# Since Amlogic doesn't play by the nice (and simple) Kconfig rules
#   of the Linux kernel, there are all sorts of implicit dependencies
#   between drivers. It's a pain in the ass because one really can't
#   know what drivers need to be enabled to get a particular feature
#   (unless one works at Amlogic and has access to their internal
#   docs, which i'm sure are Absolutely Excellent).

KPATH="$1"

removeDuplicates() {
  sort\
  | (\
  PREV=""
  while read line; do
    if [ "$line" == "$PREV" ]; then
      PREV="$line"
    else
      echo "$line"; PREV="$line"
    fi
  done)
}

grep "undefined reference to"\
  | sed "s/.*\`\(.*\)'/\1/g"\
  | removeDuplicates\
  | (\
  while read fn; do
    # Iterate through the files in which `fn` is defined

    cd "$KPATH"

    # Recursive
    # Kernel-mode, so doesn't consider out-of-tree includes?
    # -L1 takes the command from the command line
    cscope -R -k -L1"$fn"\
      | sed 's/ .*$//g'\
      | (\
        while read def_file; do
          # For each file in which `fn` is defined,
          #   find the config option(s) that enable(s)
          #   that target.

          # Only print matches (exclude filenames)
          # Only search makefiles
          # Exclude filename heading
          # Exclude line number
          # Match multiline strings
          # Dot also matches newline
          # Only output the second capture group
          rg \
          -o \
          --iglob "Makefile" \
          --no-heading \
          -I \
          -N \
          --multiline \
          --multiline-dotall \
          -r '$1' \
          '\$\(([A-Z_]*)\)[^\n\r;]*\+?=[^=]*'"$(echo "$(basename $def_file)" | cut -d'.' -f1)"'\.o' \
          "$KPATH"
      done)\
      | removeDuplicates
  done)\
  | removeDuplicates

