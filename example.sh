#!/bin/bash

source fbash.sh

DEFINE_string name --required "" "Your name"
DEFINE_int age 1 "Your age"

fbash::init "$@"

echo "Hello, $FLAGS_name! Your age is $FLAGS_age"
echo "Non-flag arguments: ${FBASH_ARGV[@]}"
