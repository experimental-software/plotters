#!/usr/bin/env bash

which docker > /dev/null 2>&1 || { echo "ERROR: \`docker\` not installed" ; exit 1; }
which perl > /dev/null 2>&1 || { echo "ERROR: \`perl\` not installed" ; exit 1; }
which dirname > /dev/null 2>&1 || { echo "ERROR: \`dirname\` not installed" ; exit 1; }
which basename > /dev/null 2>&1 || { echo "ERROR: \`basename\` not installed" ; exit 1; }

USAGE=`cat <<EOF
wrapper for the context-map generator of context-mapper-cli

Usage:  context-map.sh [option] source-file

Examples:
        context-mapper.sh context.cml

Options:
        -h  Print the help text.
EOF
`

while getopts "h" flag; do
case "$flag" in
    h) HELP='true';;
esac
done

DIAGRAM=${@:$OPTIND:1}

if [[ $HELP == 'true' || -z "$DIAGRAM" ]]; then
  echo "${USAGE}" >&2
  exit 1
fi

set -e
DIAGRAM=$(perl -MCwd -e 'print Cwd::abs_path shift' ${DIAGRAM})
DIRNAME=$(dirname ${DIAGRAM})
BASENAME=$(basename -- "${DIAGRAM}")
BASENAME_WITHOUT_EXTENSION="${BASENAME%.*}"
RESULT="${BASENAME%.*}.png"
set +e

if [[ ! -f $DIAGRAM ]]; then
  echo "ERROR: $DIAGRAM is not a file"
  exit 1
fi

TEMP_DIR=$(mktemp -d)

docker run --rm -v ${DIRNAME}:/data -v ${TEMP_DIR}:/out experimentalsoftware/context-mapper \
  generate --generator context-map --input /data/${BASENAME} --outputDir /out 

cp "${TEMP_DIR}/${BASENAME_WITHOUT_EXTENSION}_ContextMap.png" "${DIRNAME}/${RESULT}"
