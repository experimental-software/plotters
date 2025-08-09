#!/usr/bin/env bash

which docker > /dev/null 2>&1 || { echo "ERROR: \`docker\` not installed" ; exit 1; }
which perl > /dev/null 2>&1 || { echo "ERROR: \`perl\` not installed" ; exit 1; }
which dirname > /dev/null 2>&1 || { echo "ERROR: \`dirname\` not installed" ; exit 1; }
which basename > /dev/null 2>&1 || { echo "ERROR: \`basename\` not installed" ; exit 1; }

FORMAT="png"

# https://hub.docker.com/r/dstockhammer/plantuml/tags
DOCKER_IMAGE="dstockhammer/plantuml:latest"

USAGE=`cat <<EOF
Renders a binary image from a PlantUML source file.

Usage:  plantuml.sh [option] source-file

Options:
        -f  The format of the generated image.
        -h  Print the help text.
        -u  Update to latest PlantUML version.
        -v  Show current PlantUML version.
        -w  Watch file changes and re-render the diagram every time the file changes.

Examples:
        plantuml.sh hello-world.puml
        plantuml.sh -f svg hello-world.puml
        plantuml.sh -w hello-world.puml
EOF
`

while getopts "f: w h v u" flag; do
case "$flag" in
    h) HELP='true';;
    v) SHOW_VERSION='true';;
    u) UPDATE_VERSON='true'; SHOW_VERSION='true' ;;
    w) WATCH='true';;
    f) FORMAT=$OPTARG;;
esac
done

DIAGRAM=${@:$OPTIND:1}

if [[ ${HELP} == 'true' ]]; then
  echo "${USAGE}" >&2
  exit 0
fi

if [[ ${UPDATE_VERSON} == 'true' || "$(docker images -q ${DOCKER_IMAGE} 2> /dev/null)" == "" ]]; then
  docker pull ${DOCKER_IMAGE} || exit 1
  echo
fi

if [[ ${SHOW_VERSION} == 'true' ]]; then
  docker run -i ${DOCKER_IMAGE} -version
  echo
  echo "Also see:"
  echo "- https://hub.docker.com/r/karfau/plantuml/tags"
  echo "- https://plantuml.com/download"
  exit 0
fi

if [[ -z "$DIAGRAM" ]]; then
  echo "ERROR: Missing parameter for diagram source file."
  echo
  echo "${USAGE}" >&2
  exit 1
fi

if [[ ! -f ${DIAGRAM} ]]; then
  echo "ERROR: File does not exist: ${DIAGRAM}" 
  exit 1
fi

set -e
DIAGRAM=$(perl -MCwd -e 'print Cwd::abs_path shift' ${DIAGRAM})
DIRNAME=$(dirname ${DIAGRAM})
BASENAME=$(basename -- "${DIAGRAM}")
RESULT="${BASENAME%.*}.${FORMAT}"
set +e

if [[ ${WATCH} == 'true' ]]; then
  which entr > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "(Re-)generating $DIRNAME/$RESULT"
    ls ${DIAGRAM} | entr bash -c "date && cat ${DIAGRAM} | docker run --rm -i ${DOCKER_IMAGE} -pipe -t${FORMAT} > ${DIRNAME}/${RESULT}"
  else
    echo "ERROR: You need to have \`entr\` installed to be able to use the \`-w\` flag." >&2
    echo "See https://bit.ly/36q3nN9 for setup instructions." >&2
    exit 1
  fi
else
  echo "Generating $DIRNAME/$RESULT"
  cat ${DIAGRAM} | docker run --rm -i ${DOCKER_IMAGE} -pipe -t${FORMAT} > "${DIRNAME}/${RESULT}"
fi
