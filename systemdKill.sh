#!/usr/bin/env bash

#set -x
set -e -o pipefail

main() {
    local unitName="$1";shift;

    local params=(systemctl --user --signal=KILL kill "$unitName")
    "${params[@]}" |& tee > /dev/null || true # if in "deactivating" state
    # wait for unit completely removed
    while : ;do
        systemctl --user status "$unitName" &>/dev/null && true
        local exitStatus="$?"
        #echo "exitStatus=$exitStatus"
        if [[ "$exitStatus" == 4 ]]; then
            break
        else
            sleep 0.1
        fi
    done
}

main "$@"
