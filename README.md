# Plotters

> Docker-based scripts that render images from diagram source files

## Supported diagramming tools

- [PlantUML](#plantuml)
- [bpmn-to-image](#bpmn-to-image)
- [Mermaid](#mermaid)
- [Context Map](#context-map)
- [Graphviz](#graphviz)

## Dependencies

To be able to use the scripts, you need to have the following tools installed:

- **[Bash](https://www.gnu.org/software/bash/)**: The plotters are Bash scripts which wrap the diagramming tools.
- **[Docker](https://www.docker.com)**: The diagramming tools are packaged in a Docker container, to use them without the need to install them natively on your PC.
- **[entr](https://dev.to/janux_de/run-a-bash-command-after-file-changes-unix-24jj)**: (Optional) If you have `entr` installed, you can use the `-w` option of the scripts which will automatically re-render the diagrams after the source file has been changed.

The plotters are tested on Ubuntu and macOS.

## Setup

For the setup, it is recommended to clone this repository and then add its `/bin` directory into your `PATH` variable defined e.g. in `~/.bashrc` or `~/.bash_profile`:

```bash
git clone git@github.com:experimental-software/plotters.git
cd plotters/bin
echo "PATH=${PWD}"':${PATH}'
```

## Usage

Then you can use the bash scripts to generate diagrams anywhere on the terminal, using relative or absolute path declarations for the source files. It will generate the diagram as a sibling of the source file.

### PlantUML

This repository hosts a [plantuml.sh](bin/plantuml.sh) script which is a wrapper around the following Docker command:

```sh
cat example.puml | docker run --rm -i dstockhammer/plantuml \
    -pipe -tpng > example.png
```

Call `plantuml.sh` with the source file as a positional parameter to plot the diagram to the default format (PNG).

```
$ plantuml.sh examples/plantuml/hello-world.puml
Generating /home/janux/src/experimental-software/plotters/examples/plantuml/hello-world.png
```

**Also see**

- https://plantuml.com
- https://github.com/dstockhammer/docker-plantuml

### bpmn-to-image

Call `bpmn.sh` with the source file as a positional parameter to plot the diagram to the PNG format.

```
$ bpmn.sh examples/bpmn-to-image/hello-world.bpmn
writing hello-world.png
$ open examples/bpmn-to-image/hello-world.png
```

**Also see**

- https://bpmn.io
- https://github.com/bpmn-io/bpmn-to-image

### Mermaid

Call `mermaid.sh` with the source file as a positional parameter to plot the diagram to the default format (PNG).

```
$ mermaid.sh examples/mermaid/hello-world.txt
Generating /Users/jdoe/src/experimental-software/plotters/examples/mermaid/hello-world.png
Generating single mermaid chart
$ open examples/mermaid/hello-world.png
```

**Also see**

- https://mermaid-js.github.io/mermaid

### Context Map

This repository hosts a [context-map.sh](bin/context-map.sh) script which is wrapper around the following Docker command:

```sh
docker run --rm -v $(PWD):/data experimentalsoftware/context-mapper \
  generate --generator context-map --input /data/context.cml --outputDir /data
```

Call `context-map.sh` with the source file as a positional parameter to plot the diagram to the default format (PNG).

**Also see**

- https://contextmapper.org/docs/home/
- https://hub.docker.com/repository/docker/experimentalsoftware/context-mapper

### Graphviz

Call `graphviz.sh` with the source file as a positional parameter to plot the diagram to the default format (PNG).

```
$ graphviz.sh examples/graphviz/hello-world.dot
Generating /home/janux/src/experimental-software/plotters/examples/graphviz/hello-world.png
```

**Also see**

- https://graphviz.org
