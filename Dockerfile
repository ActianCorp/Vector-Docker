#-------------------------------------------------------------------------------

# Copyright 2017 Actian Corporation

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
# Pre-requisites required before using this Dockerfile:
#   1. An installed and working Docker/Moby
#   2. Register for and download Actian Vector Community Edition
#   3. Copy the Vector *.tgz file you downloaded to the same location as this Dockerfile

###
### this is for the install
###

FROM centos:7 as buildstage

# Docker file for Actian Vector 5.0 Community Edition
LABEL com.actian.vendor="Actian Corporation" \
      version=5.0 \
      description="Actian Vector 5.1 Community Edition" \
      maintainer=jeremy.hankinson@actian.com
#TAG actian vector v5 community

# Pull dependencies
RUN yum install -y libaio util-linux-ng sudo

# This Dockerfile will work with any community linux version that follows this naming convention
ENV VECTOR_ARCHIVE actian-vector-*-community-linux-x86_64-*
ENV II_SYSTEM /VectorVW

# Pull in Vector saveset
ADD ${VECTOR_ARCHIVE}.tgz .

# Install Vector
RUN cd $VECTOR_ARCHIVE && ./install.sh -express $II_SYSTEM VW -noad && hostname > /tmp/hostname.build

# set environment globally
RUN cp $II_SYSTEM/ingres/.ingVWsh /etc/profile.d/vectorVW.sh

# fix hostname as localhost
RUN source /etc/profile.d/vectorVW.sh && sed -i -e "s,`cat /tmp/hostname.build`,localhost," $II_SYSTEM/ingres/files/config.dat && ingsetenv II_HOSTNAME localhost

# Install Vector control script
RUN ln -s $II_SYSTEM/ingres/utility/dockerctl /usr/local/bin/dockerctl


###
### keep this stage only
###

FROM centos:7 as workingstage
ENV II_SYSTEM /VectorVW
COPY --from=buildstage /etc/passwd /etc/passwd
COPY --from=buildstage /etc/group /etc/group
COPY --from=buildstage /etc/profile.d/vectorVW.sh /etc/profile.d/vectorVW.sh
COPY --from=buildstage /VectorVW /VectorVW
RUN chown -R actian:actian /VectorVW
RUN source /etc/profile.d/vectorVW.sh && $II_SYSTEM/ingres/bin/ingsetenv II_HOSTNAME localhost
RUN ln -s $II_SYSTEM/ingres/utility/dockerctl /usr/local/bin/dockerctl

# Allow external connections
# NOTE: these are instance ID dependent (II_INSTALLATION)
EXPOSE 27832 27839 44223 16902

# Allow external locations - uncomment to make these available for use
# Data
VOLUME /VectorVW/ingres/data
# Backup
VOLUME /VectorVW/ingres/ckp
# Journals
VOLUME /VectorVW/ingres/jnl
# TxLog
VOLUME /VectorVW/ingres/log
# Configuration
VOLUME /VectorVW/ingres/files

ENTRYPOINT ["dockerctl"]
