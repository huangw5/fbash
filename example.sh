#!/bin/bash

source fbash.sh

DEFINE_string name --required "" "Your name"
DEFINE_int age 1 "Your age"

fbash::init "$@"

LOG_INFO "Hello, $FLAGS_name! Your age is $FLAGS_age"
LOG_INFO "Non-flag arguments: ${FBASH_ARGV[@]}"
