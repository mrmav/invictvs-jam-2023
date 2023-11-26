#!/bin/sh
echo -ne '\033c\033]0;13 Punch Man\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/launcher.x86_64" "$@"
