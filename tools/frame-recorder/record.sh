#!/bin/bash
#
# Records the frame hashes of the game at a git revision, or of the working
# tree, into tools/frame-recorder/runs/<label>/out/hashes.txt
#
#   tools/frame-recorder/record.sh <label> [<git-rev>|WORKTREE]
#
# For example, to see which frames the uncommitted changes affect:
#
#   tools/frame-recorder/record.sh before HEAD
#   tools/frame-recorder/record.sh after
#   python3 tools/frame-recorder/compare.py before after
#
# The RECORD_* settings described in main.lua pass through the environment,
# as in RECORD_DUMP=1200 tools/frame-recorder/record.sh after
#
# It opens a window for the length of the run, about 70 seconds for the
# default 4200 frames.
#
set -euo pipefail

RECORDER_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(git -C "$RECORDER_DIR" rev-parse --show-toplevel)"

if [ $# -lt 1 ]; then
    echo "usage: $0 <label> [<git-rev>|WORKTREE]" >&2
    exit 2
fi

LABEL="$1"
REV="${2:-WORKTREE}"

# The run directory is removed first, so a label like "" or ".." would
# remove much more than one run
if [[ ! "$LABEL" =~ ^[A-Za-z0-9_-][A-Za-z0-9._-]*$ ]]; then
    echo "label '$LABEL' should be letters, digits, '.', '_' or '-', not starting with '.'" >&2
    exit 2
fi

RUN_DIR="$RECORDER_DIR/runs/$LABEL"

rm -rf "$RUN_DIR"
mkdir -p "$RUN_DIR/out"

if [ "$REV" = "WORKTREE" ]; then
    cp -r "$REPO/src" "$RUN_DIR/game"
else
    git -C "$REPO" archive "$REV" src | tar -x -C "$RUN_DIR"
    mv "$RUN_DIR/src" "$RUN_DIR/game"
fi

mv "$RUN_DIR/game/main.lua" "$RUN_DIR/game/game_main.lua"
cp "$RECORDER_DIR/main.lua" "$RUN_DIR/game/main.lua"

cd "$RUN_DIR/game"
RECORD_OUT="$RUN_DIR/out" love . > "$RUN_DIR/out/stdout.txt" 2>&1 || {
    echo "love exited with status $?, the last lines of its output:" >&2
    tail -20 "$RUN_DIR/out/stdout.txt" >&2
    exit 1
}

echo "$LABEL ($REV): $(wc -l < "$RUN_DIR/out/hashes.txt") frames recorded"
