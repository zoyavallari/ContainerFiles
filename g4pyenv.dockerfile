FROM centos:7.6.1810
MAINTAINER Zoya Vallari (zoya@caltech.edu)

#Tools for installation
RUN yum install -y wget \
    && yum install -y gcc \
    && yum install -y gcc-c++ \
    && yum install -y make \
    && yum -y clean all

#Libraries
RUN yum install -y boost-devel \
    && yum install -y python-devel \ 
    && yum install -y libzip-devel \
    && yum install -y libX11-devel \
    && yum install -y libXmu-devel \
    && yum install -y libXext-devel \
    && yum install -y libXt-devel \
    && yum install -y libXpm-devel \
    && yum install -y libXft-devel \
    && yum install -y freeglut-devel \
    && yum -y clean all

#Install cmake-3.15.0-rc4 from binary file
RUN mkdir /opt/CMAKE/
WORKDIR /opt/CMAKE/
RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.0-rc4/cmake-3.15.0-rc4-Linux-x86_64.tar.gz
RUN tar xvf cmake-3.15.0-rc4-Linux-x86_64.tar.gz \
    &&  rm cmake-3.15.0-rc4-Linux-x86_64.tar.gz
ENV PATH=$PATH:/opt/CMAKE/cmake-3.15.0-rc4-Linux-x86_64/bin

#Install ROOT-6.16.00 binary file
RUN mkdir /opt/ROOT/
WORKDIR /opt/ROOT/
RUN wget https://root.cern/download/root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz
RUN tar xvf root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz \
    && rm root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz
ENV ROOTSYS=/opt/ROOT/root
ENV CMAKE_INCLUDE_PATH=${CMAKE_INCLUDE_PATH}:"${ROOTSYS}/include"
ENV CMAKE_LIBRARY_PATH=${CMAKE_LIBRARY_PATH}:"${ROOTSYS}/lib"


#Install xercesC
RUN mkdir /opt/xercesC
WORKDIR /opt/xercesC
RUN wget http://mirrors.ibiblio.org/apache//xerces/c/3/sources/xerces-c-3.2.2.tar.gz
RUN tar xvf xerces-c-3.2.2.tar.gz \
    &&  rm xerces-c-3.2.2.tar.gz 
RUN mkdir /opt/xercesC/xercesC-install
WORKDIR /opt/xercesC/xerces-c-3.2.2
RUN ./configure --prefix=/opt/xercesC/xercesC-install
RUN make
RUN make install
ENV XERCESC_DIR=/opt/xercesC/xercesC-install
ENV CMAKE_INCLUDE_PATH=${CMAKE_INCLUDE_PATH}:"${XERCESC_DIR}/include"
ENV CMAKE_LIBRARY_PATH=${CMAKE_LIBRARY_PATH}:"${XERCESC_DIR}/lib"


#Install Geant4
RUN mkdir /opt/Geant4
WORKDIR /opt/Geant4
RUN wget http://geant4-data.web.cern.ch/geant4-data/releases/geant4.10.05.p01.tar.gz
RUN tar xvf geant4.10.05.p01.tar.gz \
    &&  rm geant4.10.05.p01.tar.gz
RUN mkdir geant4-build
RUN mkdir geant4-install
WORKDIR /opt/Geant4/geant4-build
ENV GEANT4_DIR=/opt/Geant4/
RUN cmake -DCMAKE_INSTALL_PREFIX=${GEANT4_DIR}/geant4-install ${GEANT4_DIR}/geant4.10.05.p01
RUN cmake -DGEANT4_USE_OPENGL_X11=ON .
RUN cmake -DGEANT4_INSTALL_DATA=ON .
RUN cmake -DCMAKE_XERCESC_ROOT_DIR=${XERCES_DIR} .
RUN make -j1
RUN make install
ENV GEANT4_INSTALL="/opt/Geant4/geant4-install"
ENV CMAKE_INCLUDE_PATH=${CMAKE_INCLUDE_PATH}:"${GEANT4_INSTALL}/include"
ENV CMAKE_LIBRARY_PATH=${CMAKE_LIBRARY_PATH}:"${GEANT4_INSTALL}/lib"


#Install g4py
RUN mkdir /opt/Geant4/geant4.10.05.p01/environments/g4py/g4py-build
WORKDIR /opt/Geant4/geant4.10.05.p01/environments/g4py/g4py-build
RUN cmake ..
RUN make
RUN make install


#Setup the environment and run thisroot.sh and geant4.sh at entrypoint
WORKDIR /opt
ENV PYTHONPATH="${GEANT4_DIR}/geant4.10.05.p01/environments/g4py/lib64/":"${ROOTSYS}/lib/"
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:"${XERCESC_DIR}/lib"
RUN echo -e '#!/bin/bash\nsource /opt/ROOT/root/bin/thisroot.sh; \nsource /opt/Geant4/geant4-install/bin/geant4.sh; $@' > g4pyEnvWrapper.sh

ENTRYPOINT ["bash", "/opt/g4pyEnvWrapper.sh"]
CMD ["bash"]