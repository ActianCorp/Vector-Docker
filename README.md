# Running Actian Vector Community Edition using Docker

This Dockerfile will build a Docker image from a supplied version of the download for Actian Vector, Community Edition.

First, register and download the Actian Vector installation file from https://www.actian.com/lp/vector-community-edition/, then create a work folder, and copy the .tgz file downloaded into that location.

Next, get a copy of this Dockerfile and README from Github and copy those into the same location.

if you haven't already done so, download and install Docker and Kitematic (optional, but quite handy if you don't want to just use Docker from the command line, especially for Windows users).

From a command prompt in this folder (e.g. Shift-Right click the folder name in Windows and select 'Command Prompt Here'), run the following command:

  `docker build -t actian/vector5.0:community .`

which will download a minimal Centos 7 machine image, then install Actian Vector into this. If all goes well, a new image will be created which you can see via

   `docker images`

To create a new container based on this image, type:

  `docker run --name vector actian/vector:community`

and a new container will be created, and Vector will be started. Running the container this way will show you the Vector startup log details, and then pause, requiring you to hit Ctrl-C at the end before you can log into the container. Alternatively, starting the container via:

  `docker run --name vector -d actian/vector5.0:community`

with the -d for 'daemon' flag will return control to the command-line immediately, and will not print startup details onto standard out - these can be seen via Docker logs or through Kitematic instead, if needed.

To log into the running container, use:

  `docker exec -it vector bash`

If you want to expose the Vector instance inside this machine to allow external access from outside the container, e.g. via Actian Director, or Tableau, or other BI tool, you need to explicitly map the ports that are exposed by the container to ports on the host machine. To do this, change the above docker run command to:

  `docker run --name vector -d actian/vector5.0:community -p 27832:27832 -p 27839:27839 -p 44223:44223 -p 16902:16902`

if you want to allow access via ODBC, JDBC, .Net, Ingres/Net, and Actian Director.

Note that if you change these mapped ports after the container is started (.e.g. via Kitematic), the container will be re-created from scratch, this losing any data you may have loaded into the database.
