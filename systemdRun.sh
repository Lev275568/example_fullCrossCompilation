#!/usr/bin/env bash

#set -x
set -e -o pipefail


params+=(systemd-run)
#params+=(--quiet)
params+=(--pty)
#params+=(--pipe)
params+=(--same-dir)
params+=(--wait)
params+=(--collect)
params+=(--user)
params+=(--property OOMScoreAdjust=1000)
params+=(--property OOMPolicy=kill)
params+=(--property KillMode=control-group)
params+=(-p ProtectSystem=strict)
params+=(-p ProtectHome=read-only)
params+=(-p ReadWritePaths=$OUT_DIR)
#params+=(-p IPAccounting=true) # does not works and not planned https://github.com/systemd/systemd/issues/38588
params+=("${ret[@]}")
