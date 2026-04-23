#!/usr/bin/env bash
for jar in /home/joseph/work/PersoSimEditor/linux/plugins/*.jar; do
    files=$(jar tf "$jar" 2>/dev/null | grep -i "\.e4xmi\|\.xml")
    for f in $files; do
        result=$(unzip -p "$jar" "$f" 2>/dev/null | grep -i "Profiles\|Settings")
        if [ -n "$result" ]; then
            echo "$jar -> $f: $result"
        fi
    done
done
