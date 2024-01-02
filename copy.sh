#!/bin/bash

set -ex

COMMAND="{COMMAND:-podman}"

id=$($COMMAND create mingw-build)

$COMMAND cp $id:/build/i686-w64-mingw32.tar.zst i686-w64-mingw32.tar.zst
$COMMAND cp $id:/build/x86_64-w64-mingw32.tar.zst x86_64-w64-mingw32.tar.zst
$COMMAND rm -v $id
