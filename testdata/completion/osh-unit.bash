#!/bin/bash
#
# Demo of the bash completion API.
#
# It's used by core/completion_test.py, and you can run it manually.
#
# The reason we use unit tests is that some of the postprocessing in GNU
# readline is untestable from the "outside".
#
# Usage:
#   source testdata/completion/osh-unit.bash

argv() {
  spec/bin/argv.py "$@"
}

# Complete a fixed set of words
complete_mywords() {
  local first=$1
  local cur=$2
  local prev=$3
  for candidate in one two three bin; do
    if [[ $candidate == $cur* ]]; then
      COMPREPLY+=("$candidate")
    fi
  done
}

complete_foo() {
  local first=$1
  local cur=$2
  local prev=$3

  echo
  argv args "$@"

  # NOTE: If you pass foo 'hi', then the words are quoted!  This is a mistake!
  # Also true for \hi and "hi".
  # If you pass foo $x, you get literally $x as a word!  It's BEFORE
  # evaluation rather than AFTER evaluation!
  #
  # This is asking the completion function to do something impossible!!!

  argv COMP_WORDS "${COMP_WORDS[@]}"
  argv COMP_CWORD "${COMP_CWORD}"
  argv COMP_LINE "${COMP_LINE}"
  # Somehow completion doesn't trigger in the middle of a word, so this is
  # always equal to ${#COMP_LINE} ?
  argv COMP_POINT "${COMP_POINT}"

  # This value is used in main bash_completion script.

  argv source "${BASH_SOURCE[@]}"
  argv 'source[0]' "${BASH_SOURCE[0]}"

  # Test for prefix
  # bin is a dir
  for candidate in one two three bin; do
    if [[ $candidate == $cur* ]]; then
      COMPREPLY+=("$candidate")
    fi
  done
}

foo() {
  argv completed "$@"
}

complete_filedir() {
  local first=$1
  local cur=$2
  local prev=$3
  COMPREPLY=( $( compgen -d "$cur" ) )
}

complete_bug() {
  # Regression for issue where readline swallows SystemExit.
  comsub=$(echo comsub)

  COMPREPLY=(one two three $comsub)
}

complete_optdemo() {
  local first=$1
  local cur=$2
  local prev=$3

  # Dynamically set
  #compopt -o nospace

  # -o nospace doesn't work here, but it's accepted!
  COMPREPLY=( $( compgen -o nospace -d "$cur" ) )
}

complete_optdynamic() {
  local first=$1
  local cur=$2
  local prev=$3

  # Suppress space on anything that starts with b
  if [[ "$cur" == b* ]]; then
    compopt -o nospace
  fi
  COMPREPLY=( $( compgen -A file "$cur" ) )
}

optdynamic() {
  argv optdynamic "$@"
}

complete_files() {
  local first=$1
  local cur=$2
  local prev=$3

  # This MESSES up the trailing slashes.  Need -o filenames.
  COMPREPLY=( $( compgen -A file "$cur" ) )
}

# dirnames: add dirs if nothing matches
# plusdirs: always add dirs
# filenames: adds trailing slash if it is a directory
complete -F complete_foo -o dirnames -o filenames foo
complete -F complete_foo -o nospace foo2

# from _filedir
complete -F complete_filedir filedir

# isolated bug
complete -F complete_bug bug

# Test how the options work.  git uses nospace.
complete -F complete_optdemo -o nospace optdemo

complete -F complete_optdynamic optdynamic

# Check trailing backslashes for the 'fileuser' command
# Hm somehow it knows to distinguish.  Gah.
complete -A file -A user fileuser

# everything else completes files
#complete -D -A file
complete -F complete_files -D

#
# Unit tests use this
#

# For testing interactively
flagX() { argv "$@"; }
flagX_bang() { argv "$@"; }
flagX_prefix() { argv "$@"; }
prefix_plusdirs() { argv "$@"; }
flagX_plusdirs() { argv "$@"; }
prefix_dirnames() { argv "$@"; }

complete -F complete_mywords mywords
complete -F complete_mywords -o nospace mywords_nospace

# This REMOVES two of them.  'three' should not be removed
# since it's not an exact match.
# Hm filtering comes BEFORE the prefix.
complete -X '@(two|bin|thre)' -F complete_mywords flagX

# Silly negation syntax
complete -X '!@(two|bin)' -F complete_mywords flagX_bang

complete -P __ -X '@(two|bin|thre)' -F complete_mywords flagX_prefix

complete -P __ -o plusdirs -F complete_mywords prefix_plusdirs

# Filter out bin, is it added back?  Yes, it appears to work.
complete -X '@(two|bin)' -o plusdirs -F complete_mywords flagX_plusdirs

complete -P __ -o dirnames prefix_dirnames
