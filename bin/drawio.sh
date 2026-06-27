#!/usr/bin/env bash

set -e

FORMAT="svg"
PAGE_INDEX="1"
BORDER_SIZE="0"
COUNTER="false"

USAGE=$(cat <<EOF
draw.io wrapper

Renders an image file as a sibling of a "drawio" source file.

Usage:  drawio.sh [option] <source-file>

Examples:
        drawio.sh hello-world.drawio

Options:
        -f  The format of the generated image (Default: svg).
        -p  The 1-based page index in the diagram (Default: 1).
        -b  The border size (Default: 0).
        -c  Flag to add a counter suffix to the generated image (Default: false).
        -h  Print the help text.
EOF
)

while getopts "f:p:b:hc" flag; do
case "$flag" in
    f) FORMAT=$OPTARG;;
    p) PAGE_INDEX=$OPTARG;;
    b) BORDER_SIZE=$OPTARG;;
    c) COUNTER='true';;
    h) HELP='true';;
    \?)
        echo "Invalid flag: -$OPTARG" >&2
        exit 1
        ;;
esac
done

DIAGRAM=${*:OPTIND:1}

# --------------------------------------------------------------------------------------------------

if [[ "$FORMAT" != "png" && "$FORMAT" != "svg" ]]; then
  echo "ERROR: FORMAT must be 'png' or 'svg', got '$FORMAT'" >&2
  exit 1
fi

if ! [[ "$PAGE_INDEX" =~ ^[0-9]+$ ]] || [[ "$PAGE_INDEX" -lt 1 ]]; then
  echo "ERROR: PAGE_INDEX must be an integer greater than or equal to 1, got '$PAGE_INDEX'" >&2
  exit 1
fi

if ! [[ "$BORDER_SIZE" =~ ^[0-9]+$ ]] || [[ "$PAGE_INDEX" -lt 0 ]]; then
  echo "ERROR: BORDER_SIZE must be an integer greater than or equal to 0, got '$BORDER_SIZE'" >&2
  exit 1
fi

if [[ $HELP == 'true' || -z "$DIAGRAM" ]]; then
  echo "${USAGE}" >&2
  exit 1
fi

which docker > /dev/null 2>&1 || { echo "ERROR: \`docker\` not installed" ; exit 1; }
which perl > /dev/null 2>&1 || { echo "ERROR: \`perl\` not installed" ; exit 1; }
which dirname > /dev/null 2>&1 || { echo "ERROR: \`dirname\` not installed" ; exit 1; }
which basename > /dev/null 2>&1 || { echo "ERROR: \`basename\` not installed" ; exit 1; }

# --------------------------------------------------------------------------------------------------

function count_previously_generated_target_files() {
  find "${DIRNAME}" -maxdepth 1 -name "${BASENAME%.*}_*.${FORMAT}" -type f 2>/dev/null | wc -l
}

function get_target_file_name() {
  if [[ "$COUNTER" != "true" ]]; then
      echo "${BASENAME%.*}.${FORMAT}"
      return
  fi
  local NUMBER_OF_TARGET_FILES
  NUMBER_OF_TARGET_FILES=$(count_previously_generated_target_files)
  local NEW_FILE_NUMBER
  NEW_FILE_NUMBER=$((NUMBER_OF_TARGET_FILES + 1))
  local NEW_FILE_NUMBER_FORMATTED
  NEW_FILE_NUMBER_FORMATTED=$(printf "%02d" "$NEW_FILE_NUMBER")
  echo "${BASENAME%.*}_${NEW_FILE_NUMBER_FORMATTED}.${FORMAT}"
}

# --------------------------------------------------------------------------------------------------

if [[ ! -f "$DIAGRAM" ]]; then
  echo "ERROR: File does not exist: '$DIAGRAM'" >&2
  exit 1
fi

DIAGRAM_INPUT=${DIAGRAM}
DIAGRAM=$(perl -MCwd -e 'print Cwd::abs_path shift' "${DIAGRAM_INPUT}")
if [[ -z "$DIAGRAM" ]]; then
  echo "ERROR: Failed to resolve absolute path for file: '$DIAGRAM_INPUT'" >&2
  exit 1
fi

DIRNAME=$(dirname "${DIAGRAM}")
BASENAME=$(basename -- "${DIAGRAM}")
TARGET_FILE_NAME=$(get_target_file_name)

docker run --rm -v "${DIRNAME}:/data" rlespinasse/drawio-desktop-headless \
  --export \
  --format png \
  --output /data/"${TARGET_FILE_NAME}" \
  --page-index "${PAGE_INDEX}" \
  --border "${BORDER_SIZE}" \
  /data/"${BASENAME}"

# docker run --rm -v "${DIRNAME}:/data" rlespinasse/drawio-desktop-headless --help
