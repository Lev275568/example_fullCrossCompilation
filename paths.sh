#!/usr/bin/env bash

#set -x
set -e -o pipefail

if [ -z "$INCLUDED_scripts_paths_sh" ];then
    INCLUDED_scripts_paths_sh=yes
else
    return 0
fi

PATHS_SCRIPT_DIR="$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]:-$0}")"; )" &> /dev/null && pwd 2> /dev/null; )";

createDirs() {

    #echo "createDirs"

    local params=()
    params+=("$OUT_DIR")

    mkdir -p "${params[@]}"
}

main() {

    local SCRIPT_DIR="$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]:-$0}")"; )" &> /dev/null && pwd 2> /dev/null; )";

    WC_ROOT="$SCRIPT_DIR"
    WC_ROOT="`realpath "${WC_ROOT}"`"

   
    OUT_DIR="$WC_ROOT/outDir"
   

    createDirs
}

main
