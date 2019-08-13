FROM centos:7.6.1810
MAINTAINER Zoya Vallari (zoya@caltech.edu)

#Tools for installation
RUN yum install -y --setopt=tsflags=nodocs \
    wget \
    gcc	 \ 
    gcc-c++ \
    make \
 && yum -y clean all

#Libraries
RUN yum install -y --setopt=tsflags=nodocs \
    boost-devel \
    python-devel \
    libzip-devel \
    libX11-devel \
    libXmu-devel \
    libXext-devel \
    libXt-devel \
    libXpm-devel \
    libXft-devel \
    freeglut-devel \
 && yum -y clean all

#Install cmake-3.15.0-rc4 from binary file
RUN mkdir /opt/CMAKE/
WORKDIR /opt/CMAKE/
RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.0-rc4/cmake-3.15.0-rc4-Linux-x86_64.tar.gz \
    && tar xvf cmake-3.15.0-rc4-Linux-x86_64.tar.gz \
    && rm cmake-3.15.0-rc4-Linux-x86_64.tar.gz
ENV PATH="$PATH:/opt/CMAKE/cmake-3.15.0-rc4-Linux-x86_64/bin"

#Install ROOT-6.16.00 binary file
RUN mkdir /opt/ROOT/
WORKDIR /opt/ROOT/
RUN wget https://root.cern/download/root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz \
    && tar xvf root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz \
    && rm root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz
ENV ROOTSYS="/opt/ROOT/root"
ENV CMAKE_INCLUDE_PATH="${CMAKE_INCLUDE_PATH}:${ROOTSYS}/include" 
ENV CMAKE_LIBRARY_PATH="${CMAKE_LIBRARY_PATH}:${ROOTSYS}/lib"


#Install xercesC
RUN mkdir /opt/xercesC
WORKDIR /opt/xercesC
RUN wget http://mirrors.ibiblio.org/apache//xerces/c/3/sources/xerces-c-3.2.2.tar.gz \
    && tar xvf xerces-c-3.2.2.tar.gz \
    &&  rm xerces-c-3.2.2.tar.gz 
RUN mkdir /opt/xercesC/xercesC-install
WORKDIR /opt/xercesC/xerces-c-3.2.2
RUN ./configure --prefix=/opt/xercesC/xercesC-install \
    && make \
    && make install
ENV XERCESC_DIR="/opt/xercesC/xercesC-install" 
ENV CMAKE_INCLUDE_PATH="${CMAKE_INCLUDE_PATH}:${XERCESC_DIR}/include" 
ENV CMAKE_LIBRARY_PATH="${CMAKE_LIBRARY_PATH}:${XERCESC_DIR}/lib"


#Install Geant4
RUN mkdir /opt/Geant4
WORKDIR /opt/Geant4
RUN wget http://geant4-data.web.cern.ch/geant4-data/releases/geant4.10.05.p01.tar.gz \
    && tar xvf geant4.10.05.p01.tar.gz \
    &&  rm geant4.10.05.p01.tar.gz
RUN mkdir geant4-build \
    && mkdir geant4-install
WORKDIR /opt/Geant4/geant4-build
ENV GEANT4_DIR="/opt/Geant4/"
RUN cmake -DCMAKE_INSTALL_PREFIX=${GEANT4_DIR}/geant4-install ${GEANT4_DIR}/geant4.10.05.p01 \
    && cmake -DGEANT4_USE_OPENGL_X11=ON . \
    && cmake -DGEANT4_INSTALL_DATA=ON . \
    && cmake -DCMAKE_XERCESC_ROOT_DIR=${XERCES_DIR} .
RUN make -j1 \
    && make install
ENV GEANT4_INSTALL="/opt/Geant4/geant4-install" 
ENV CMAKE_INCLUDE_PATH="${CMAKE_INCLUDE_PATH}:${GEANT4_INSTALL}/include" 
ENV CMAKE_LIBRARY_PATH="${CMAKE_LIBRARY_PATH}:${GEANT4_INSTALL}/lib"


#Install g4py
RUN mkdir /opt/Geant4/geant4.10.05.p01/environments/g4py/g4py-build
WORKDIR /opt/Geant4/geant4.10.05.p01/environments/g4py/g4py-build
RUN cmake .. \ 
    && make \
    && make install

#Setup ${ROOTSYS}/bin/thisroot.sh and ${GEANT4_INSTALL}/bin/geant4.sh as ENV because Entrypoint is not yet cross-platform compatible
WORKDIR /opt
ENV G4LEVELGAMMADATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/PhotonEvaporation5.3" 
ENV G4LEDATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/G4EMLOW7.7" 
ENV G4NEUTRONHPDATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/G4NDL4.5" 
ENV G4ENSDFSTATEDATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/G4ENSDFSTATE2.2"  
ENV G4RADIOACTIVEDATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/RadioactiveDecay5.3" 	
ENV G4ABLADATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/G4ABLA3.1" 
ENV G4PIIDATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/G4PII1.3" 
ENV G4PARTICLEXSDATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/G4PARTICLEXS1.1" 
ENV G4SAIDXSDATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/G4SAIDDATA2.0" 
ENV G4REALSURFACEDATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/RealSurface2.1.1" 
ENV G4INCLDATA="${GEANT4_INSTALL}/share/Geant4-10.5.1/data/G4INCL1.0"

ENV MANPATH="${ROOTSYS}/man:"   
ENV LIBPATH="${ROOTSYS}/lib"
ENV JUPYTER_PATH="${ROOTSYS}/etc/notebook" 
ENV DYLD_LIBRARY_PATH="${ROOTSYS}/lib"  
ENV SHLIB_PATH="${ROOTSYS}/lib"

ENV CMAKE_PREFIX_PATH="${ROOTSYS}" 
ENV LD_LIBRARY_PATH="${GEANT4_INSTALL}/lib64:${ROOTSYS}/lib:${XERCESC_DIR}/lib:${LD_LIBRARY_PATH}" 
ENV PATH="${GEANT4_INSTALL}/bin:${ROOTSYS}/bin:${PATH}" 
ENV PYTHONPATH="${ROOTSYS}/lib/:"${GEANT4_DIR}/geant4.10.05.p01/environments/g4py/lib64/":${PYTHONPATH}"