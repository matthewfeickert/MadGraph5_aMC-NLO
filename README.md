# MadGraph5_aMC-NLO
Docker image for MadGraph5_aMC@NLO

[![Docker Pulls](https://img.shields.io/docker/pulls/matthewfeickert/madgraph5-amc-nlo)](https://hub.docker.com/r/matthewfeickert/madgraph5-amc-nlo)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/matthewfeickert/madgraph5-amc-nlo/latest)](https://hub.docker.com/r/matthewfeickert/madgraph5-amc-nlo/tags?name=latest)

## PHYS 575 Students

If you are planning on using the `phys575` tag of the Docker image, you can get up and running with it quickly.

First pull the Docker image down from Docker Hub

```
docker pull matthewfeickert/madgraph5-amc-nlo:phys575
```

then you can run it interactively as a Docker container with the following

```
docker run --rm -it -v $PWD:$PWD -w $PWD -p 8888:8888 matthewfeickert/madgraph5-amc-nlo:phys575
```

This will drop you into an interactive Bash session _inside_ of the Docker container.
You'll see that MadGraph is in `PATH`

```
# which mg5_aMC
/usr/local/MG5_aMC_v2_7_2/bin/mg5_aMC
```

so you don't need to source anything to get your environment ready for use &mdash; you're good to go.

If you want you can also create a Shell alias for this command so that you just have to type your alias to run it

```
alias runPHYS575Image='docker run --rm -it -v $PWD:$PWD -w $PWD -p 8888:8888 matthewfeickert/madgraph5-amc-nlo:phys575'
```

From this container you should have all the tools (both C++ and Python based) that you need for your 7th homework assignment.
If you would like to use Jupyter, it is also installed (check `python -m pip list` for what is installed for you) and if you simply run

```
jupyter notebook
```

and then copy the URL that is produced into your web browser on your local machine then you can interact with Jupyter inside the image from your browser.

<a href="https://asciinema.org/a/314725"><img src="https://asciinema.org/a/314725.png" width="836"/></a>

### Run Command Break Down

If you're curious as to why you had to include so many flags in your run command here is a terse summary

```
docker run \
  --rm \ # Clean up the container after it exits
  -it \ # Run in an interactive session
  -v $PWD:$PWD \ # Bind mount your cwd to the same path inside the container
  -w $PWD \ # Set the cwd inside the container to be your cwd
  -p 8888:8888 \ # Expose port 8888 on both your local machine and container
  matthewfeickert/madgraph5-amc-nlo:phys575
```

To prove to yourself that you're really in a different environment than your host machine simply check the OS information

```
cat /etc/os-release
```

### Docker basics

If you're curious about more information on Docker or containers a good place to start learning more is the [Introduction to Docker tutorial](https://matthewfeickert.github.io/intro-to-docker/) that was taught at the 2019 US ATLAS Computing Bootcamp.
