#!/usr/bin/env bash

which docker > /dev/null 2>&1 || { echo "ERROR: \`docker\` not installed" ; exit 1; }
which perl > /dev/null 2>&1 || { echo "ERROR: \`perl\` not installed" ; exit 1; }
which dirname > /dev/null 2>&1 || { echo "ERROR: \`dirname\` not installed" ; exit 1; }
which basename > /dev/null 2>&1 || { echo "ERROR: \`basename\` not installed" ; exit 1; }

FORMAT="png"

MERMAID_VERSION=11.15.0 # https://github.com/mermaid-js/mermaid-cli/tags

USAGE=`cat <<EOF
Mermaid wrapper, version ${MERMAID_VERSION}

Renders a binary image as a sibling of a Mermaid source file.

Usage:  mermaid.sh [option] source-file

Examples:
        mermaid.sh hello-world.txt
        mermaid.sh -f svg hello-world.txt
        mermaid.sh -w hello-world.txt

Options:
        -f  The format of the generated image.
        -w  Watch file changes and re-render the diagram every time the file changes.
        -h  Print the help text.

Examples:
        https://github.com/experimental-software/plotters/tree/master/examples/mermaid/README.md
EOF
`

while getopts "f: w h" flag; do
case "$flag" in
    h) HELP='true';;
    w) WATCH='true';;
    f) FORMAT=$OPTARG;;
esac
done

DIAGRAM=${@:$OPTIND:1}

if [[ ${HELP} == 'true' || -z "${DIAGRAM}" ]]; then
  echo "${USAGE}" >&2
  exit 1
fi

set -e
DIAGRAM=$(perl -MCwd -e 'print Cwd::abs_path shift' ${DIAGRAM})
DIRNAME=$(dirname ${DIAGRAM})
BASENAME=$(basename -- "${DIAGRAM}")
RESULT="${BASENAME%.*}.${FORMAT}"
DOCKER_IMAGE="minlag/mermaid-cli:${MERMAID_VERSION}"
COMPILE_CMD="docker run --rm -u ${UID} -it -v ${DIRNAME}:/data ${DOCKER_IMAGE} -i /data/${BASENAME} --output /data/${RESULT}"
set +x

if [[ "$(docker images -q ${DOCKER_IMAGE} 2> /dev/null)" == "" ]]; then
  docker pull ${DOCKER_IMAGE} || exit 1
fi

if [[ ${WATCH} == 'true' ]]; then
  which entr > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "(Re-)generating ${DIRNAME}/${RESULT}"
    ls ${DIAGRAM} | entr bash -c "eval \"${COMPILE_CMD}\""
  else
    echo "ERROR: You need to have \`entr\` installed to be able to use the \`-w\` flag." >&2
    echo "See https://bit.ly/36q3nN9 for setup instructions." >&2
    exit 1
  fi
else
  echo "Generating ${DIRNAME}/${RESULT}"
  eval "${COMPILE_CMD}"
fi
