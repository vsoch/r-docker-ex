# r-docker-ex
A simple example of using R with docker

This repo was used to build a simple Docker example for [this article](https://rviews.rstudio.com/2018/01/18/package-management-for-reproducible-r-code/) on RViews.

If you have Docker installed on your system, you can execute [`./simple-ex.sh`](./simple-ex.sh) to build and launch a docker image based on the [packrat.lock](packrat/packrat.lock) file.

If you want to use the project locally, you can open the [RProject file](docker-ex.Rproj) or run `packrat::restore()` to download dependent packages.

## Singularity

Singularity is a container technology that, like Docker, is great to ensure reproducibility of a set of work. Some might consider it a better solution in that a Singularity image is a single file (and not layers that need to be found and assembled at runtime). If you aren't familiar with Singularity, you should first [install it](singularityware.github.io/install-linux). We will walk through building and using a Singularity container for this repository.


### Getting Started
The container is built from a build specification, a text file called `Singularity` that mirrors the `Dockerfile`. If you have an image on Docker Hub you can use it directly (and pull is recommended so you have a file to use again):

```
singularity pull docker://rocker/rstudio
```

### The Build Recipe
But likely you want to add custom commands to a recipe, akin to a Dockerfile, so here we've written a [Singularity recipe](Singularity) file. Instead of just a `FROM` at the top like you have with Docker, here we see an additional line that we are going to `Bootstrap`, or use a Docker image (the same one) as a base:

```
Bootstrap: docker
From: rocker/rstudio

%files
    . /home/rstudio/project

%post

    # install packrat

    R -e 'install.packages("packrat", repos="http://cran.rstudio.com", dependencies=TRUE, lib="/usr/local/lib/R/site-library");'

    # copy lock file & install deps
    R -e 'packrat::restore(project="/home/rstudio/project");'

    chown -R rstudio /home/rstudio
```

Singularity build recipes differ from Docker in that you write things in chunks. The `%files` section is a list of <source><destination> to copy. The `%post` section is where you write your entire installation procedure. The header at the top handles the base operating system (in this case, dumped into the Singularity container via Docker Hub layers for `rocker/rstudio`). The fact that we have left out a tag means that we will be getting the `latest`.

### Build the Container
To build our container, you can use the Makefile provided with `make` or run the command directly:

```
sudo singularity build r-singularity Singularity
```

A little about these images - unlike Docker, a Singularity image is read only, a file called squashfs that ensures that once you build it, it's baked. This might not seem as great because you can't write into the image, but for reproducibility, it's essential. When you need to write content, you just bind directories in the container to a path on the host where you can (and we will try this in this example).

### Inspect
Once it finishes, you can interact with it in many ways! First, try inspecting it. The default inspect returns labels:


```
singularity inspect r-singularity 
{
    "org.label-schema.usage.singularity.deffile.bootstrap": "docker",
    "maintainer": "Carl Boettiger <cboettig@ropensci.org>",
    "org.label-schema.license": "GPL-2.0",
    "org.label-schema.schema-version": "1.0",
    "org.label-schema.vcs-url": "https://github.com/rocker-org/rocker-versioned",
    "org.label-schema.build-date": "Wed,_24_Jan_2018_13:12:38_-0800",
    "org.label-schema.vendor": "Rocker Project",
    "org.label-schema.usage.singularity.deffile.from": "rocker/rstudio",
    "org.label-schema.usage.singularity.version": "2.4.1-bleuchien-apprunfix.g85c133d",
    "org.label-schema.build-size": "8614MB",
    "org.label-schema.usage.singularity.deffile": "Singularity"
}
```

And you can ask for a lot more:

```
singularity help inspect
```

### Shell
Shelling into the container is likely what you would want for an interactive environment.

```
 singularity shell r-singularity 
Singularity: Invoking an interactive shell within container...

Singularity r-singularity:~/Documents/Dropbox/Code/R/r-docker-ex> 
```

But remember that without binding a directory on the host, the container is read only. You will notice, however, that you are sitting in the same directory on the host, and that you have mapped tmp. Why? Those directories are bound by default, woohoo! Given this, you can write in these locations. 



### Run
The most logical thing to do is run it! Singularity by default changes the entrypoint then command into what it calls the "runscript." Since we need to write to a `/var` path in the container, let's make one on our host that we can bind.

```
mkdir -p /tmp/var/s6
```

Now let's run the container and bind to this!

```

```
