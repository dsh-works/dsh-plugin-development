#!/usr/bin/env bash
# Links the skills of this repository into the DSH skills folder, or removes
# those links. Existing real folders are never overwritten.
#
#   ./install.sh
#   ./install.sh --uninstall
#
# On macOS and Linux the link is a symbolic link; git pull in this repository
# updates the live skills without copying.

set -euo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$repo/skills"
target_dir="${DSH_HOME:-$HOME/.dsh}/skills"
uninstall=0

if [ "${1:-}" = "--uninstall" ]; then
    uninstall=1
fi

if [ ! -d "$source_dir" ]; then
    echo "no skills folder in $repo" >&2
    exit 1
fi

mkdir -p "$target_dir"

for skill in "$source_dir"/*/; do
    skill="${skill%/}"
    name="$(basename "$skill")"
    [ -f "$skill/SKILL.md" ] || continue
    link="$target_dir/$name"

    if [ "$uninstall" -eq 1 ]; then
        if [ -L "$link" ] && [ "$(readlink "$link")" = "$skill" ]; then
            rm "$link"
            echo "removed  $link"
        else
            echo "skipped  $link (not a link into this repository)"
        fi
        continue
    fi

    if [ -L "$link" ]; then
        if [ "$(readlink "$link")" = "$skill" ]; then
            echo "current  $link"
            continue
        fi
        rm "$link"
    elif [ -e "$link" ]; then
        echo "$link exists and is not a symlink; move it aside first" >&2
        exit 1
    fi

    ln -s "$skill" "$link"
    echo "linked   $link -> $skill"
done

if [ "$uninstall" -eq 0 ]; then
    echo
    echo "Start a new DSH session to load the skills."
fi
