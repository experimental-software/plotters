#!/usr/bin/env bash

which docker > /dev/null 2>&1 || { echo "ERROR: \`docker\` not installed" ; exit 1; }
which perl > /dev/null 2>&1 || { echo "ERROR: \`perl\` not installed" ; exit 1; }
which dirname > /dev/null 2>&1 || { echo "ERROR: \`dirname\` not installed" ; exit 1; }
which basename > /dev/null 2>&1 || { echo "ERROR: \`basename\` not installed" ; exit 1; }

USAGE=$(cat <<EOF
draw.io wrapper

Renders a PNG file as a sibling of a "drawio" source file.

Usage:  drawio.sh [option] source-file

Examples:
        drawio.sh hello-world.drawio

Options:
        -h  Print the help text.
EOF
)

while getopts ":h" flag; do
case "$flag" in
    h) HELP='true';;
    \?)
        echo "Invalid flag: -$OPTARG" >&2
        exit 1
        ;;
esac
done

DIAGRAM=${*:OPTIND:1}

if [[ $HELP == 'true' || -z "$DIAGRAM" ]]; then
  echo "${USAGE}" >&2
  exit 1
fi

set -e
DIAGRAM=$(perl -MCwd -e 'print Cwd::abs_path shift' "${DIAGRAM}")
DIRNAME=$(dirname "${DIAGRAM}")
BASENAME=$(basename -- "${DIAGRAM}")
RESULT="${BASENAME%.*}.png"
set +e

docker run --rm -v "${DIRNAME}:/data" rlespinasse/drawio-desktop-headless \
  --export --format png --output /data/"${RESULT}" /data/"${BASENAME}"
