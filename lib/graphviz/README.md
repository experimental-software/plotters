# Graphviz Dot

## Usage

```
cat t/hello-world.dot | docker run --rm -i experimentalsoftware/graphviz-dot dot -Tpng > t/hello-world.png
```

## Maintenance

```sh
# Build a new image
gradle build

# Set the version tag
export GRAPHVIZ_VERSION=14.1.4
gradle tag

# Publish to Docker Hub
gradle publish
```

## References

- https://gitlab.com/graphviz/graphviz/
- https://graphviz.org/
- https://madhead.me/posts/docker-dot/
- https://fedoramagazine.org/quick-containers-with-fedora-dockerfiles/
- https://www.thegeekdiary.com/centos-rhel-how-to-install-a-specific-version-of-rpm-package-using-yum/
- http://rpmfind.net/linux/rpm2html/search.php?query=graphviz
- https://github.com/nickshine/dot
