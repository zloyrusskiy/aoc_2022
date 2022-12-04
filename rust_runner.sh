#!/bin/bash
set -e
name=$(basename $1 .rs)
rustc --crate-type=lib -O ./common/mylib.rs
rustc --extern mylib=./libmylib.rlib -O $@
./$name
rm $name
rm libmylib.rlib
