FROM centos:7.6.1810
MAINTAINER Zoya Vallari (zoya@caltech.edu)

#Tools for installation
RUN yum install -y wget
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y make

#Libraries
RUN yum install -y boost-devel
RUN yum install -y python-devel
RUN yum install -y libzip-devel
RUN yum install -y libX11-devel
RUN yum install -y libXmu-devel
RUN yum install -y libXext-devel
RUN yum install -y libXt-devel
RUN yum install -y libXpm-devel
RUN yum install -y libXft-devel
RUN yum install -y freeglut-devel

#Install cmake-3.15.0-rc4 from binary file
RUN mkdir /opt/CMAKE/
WORKDIR /opt/CMAKE/
RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.0-rc4/cmake-3.15.0-rc4-Linux-x86_64.tar.gz
RUN tar xvf cmake-3.15.0-rc4-Linux-x86_64.tar.gz
RUN rm cmake-3.15.0-rc4-Linux-x86_64.tar.gz
ENV PATH=$PATH:/opt/CMAKE/cmake-3.15.0-rc4-Linux-x86_64/bin

#Install ROOT-6.16.00
RUN mkdir /opt/ROOT/
WORKDIR /opt/ROOT/
RUN wget https://root.cern/download/root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz
RUN tar xvf root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz
RUN rm root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz
ENV ROOTSYS=/opt/ROOT/root
RUN bin/bash -c "source ${ROOTSYS}/bin/thisroot.sh"
ENV CMAKE_INCLUDE_PATH=${CMAKE_INCLUDE_PATH}:"${ROOTSYS}/include"
ENV CMAKE_LIBRARY_PATH=${CMAKE_LIBRARY_PATH}:"${ROOTSYS}/lib"


#Install xercesC
RUN mkdir /opt/xercesC
WORKDIR /opt/xercesC
RUN wget http://mirrors.ibiblio.org/apache//xerces/c/3/sources/xerces-c-3.2.2.tar.gz
RUN tar xvf xerces-c-3.2.2.tar.gz 
RUN rm xerces-c-3.2.2.tar.gz 
RUN mkdir /opt/xercesC/xercesC-install
WORKDIR /opt/xercesC/xerces-c-3.2.2
RUN ./configure --prefix=/opt/xercesC/xercesC-install
RUN make
RUN make install
ENV XERCESC_DIR=/opt/xercesC/xercesC-install/
ENV CMAKE_INCLUDE_PATH=${CMAKE_INCLUDE_PATH}:"${XERCESC_DIR}/include"
ENV CMAKE_LIBRARY_PATH=${CMAKE_LIBRARY_PATH}:"${XERCESC_DIR}/lib"


#Install Geant4
RUN mkdir /opt/Geant4
WORKDIR /opt/Geant4
RUN wget http://geant4-data.web.cern.ch/geant4-data/releases/geant4.10.05.p01.tar.gz
RUN tar xvf geant4.10.05.p01.tar.gz
RUN rm geant4.10.05.p01.tar.gz
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


#Setup the environment
WORKDIR /opt
RUN bin/bash/ -c "source ${GEANT4_INSTALL}/bin/geant4.sh"
ENV PYTHONPATH="${GEANT4_DIR}/geant4.10.05.p01/environments/g4py/lib64/"
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:"${XERCESC_DIR}/lib"
RUN bin/bash/ -c "source ${ROOTSYS}/bin/thisroot.sh"
