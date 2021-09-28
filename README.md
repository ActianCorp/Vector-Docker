# Running Actian Vector using Docker

This Dockerfile will build a Docker image from a supplied version of Actian Vector.

Download a saveset *.tgz file of your licensed Vector.

Clone this "git" repository from Github and copy the Vector tarball into the same directory as the Dockerfile.

If you haven't already done so, download and install Docker.

From a command prompt in this folder (e.g. Shift-Right click the folder name in Windows and select 'Command Prompt Here'), run the following command:

	`docker build -t actian/vector:latest .`

which will download a minimal Centos 7 machine image, then install Actian Vector into this. If all goes well, a new image will be created which you can see via

	`docker images`

To create a new container based on this image, type:

	`docker run --name vector actian/vector:latest`

and a new container will be created, and Vector will be started. Running the container this way will show you the Vector startup log details, and then pause, requiring you to hit Ctrl-C at the end before you can log into the container. Alternatively, starting the container via:

	`docker run --name vector -d actian/vector:latest`

with the -d for 'daemon' flag will return control to the command-line immediately, and will not print startup details onto standard out - these can be seen via Docker logs or through Kitematic instead, if needed.

Also provided here is a Docker "Compose" file which can simplify build and running of Vector Community images

To log into the running container, use:

	`docker exec -it vector bash`

If you want to expose the Vector instance inside this container to allow external access from outside the container, e.g. via Actian Director, or Tableau, or other BI tool, you need to explicitly map the ports that are exposed by the container to ports on the host machine. To do this, change the above docker run command to:

	`docker run --name vector -d -p 27832:27832 -p 27839:27839 -p 44223:44223 -p 16902:16902 actian/vector:latest`

This will allow you to allow access via ODBC, JDBC, .Net, and Ingres/Net

Also include in this repository is a sample of a docker compose file that has all the interesting settings for running a persistent container.
