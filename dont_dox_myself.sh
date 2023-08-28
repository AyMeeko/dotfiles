#!/bin/bash

dox_words='dox_words.txt'

regex=''

while read line; do
  if [[ -z $regex ]]; then
    regex="$line"
  else
    regex="$regex|$line"
  fi
done < $dox_words

found_something=`git diff --cached | grep -E -i "$regex"`
echo $found_something

if [[ -n $found_something ]]; then
  echo "=============================================="
  echo "FOUND SOMETHING IN THE DIFF THAT MIGHT DOX YOU"
  echo "=============================================="
  exit 1
fi
