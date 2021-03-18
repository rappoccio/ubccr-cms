FROM opensciencegrid/osg-wn:latest

USER root
ENV NB_UID 1000
ENV NB_USER jovyan
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER
WORKDIR /home/$NB_USER/
RUN chown -R ${NB_USER} /home/${NB_USER}
COPY get-pip.py /tmp/get-pip.py

# CMS part Cribbed from Brian's EL6 repo
RUN yum -y update && rpm -Uvh http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm && \
    yum -y install wget selinux-policy bash && \
    wget https://bintray.com/sbt/rpm/rpm > /etc/yum.repos.d/bintray-sbt-rpm.repo && \
    yum -y install https://repo.ius.io/ius-release-el7.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    #yum -y install https://centos7.iuscommunity.org/ius-release.rpm && \
    yum -y install cvmfs \
                   gcc \
                   glibc-headers \
                   openssh-clients \
                   redhat-lsb-core \
                   sssd-client \
                   glibc coreutils bash tcsh zsh perl tcl tk readline openssl \
                   ncurses e2fsprogs krb5-libs freetype compat-readline5 \
                   ncurses-libs perl-libs perl-ExtUtils-Embed fontconfig \
                   compat-libstdc++-33 libidn libX11 libXmu libSM libICE \
                   libXcursor libXext libXrandr libXft mesa-libGLU mesa-libGL \
                   e2fsprogs-libs libXi libXinerama libXft libXrender libXpm \
                   libcom_err \
                   vim emacs python36 python-devel python36-devel \
                   java-1.8.0-openjdk maven sbt \
                   xrootd-client xrootd-libs xrootd-client-libs xrootd-client-devel \
                   mesos-1.7.2 git \
                   krb5-workstation \
                   python2-xrootd \
		   xrootd-devel \
                   zlib-devel lzma-sdk-devel bzip2-devel readline-devel libcurl-devel \
                   tree htop \
                   libcurl-devel openssl-devel libxml2-devel \
                   llvm5.0 llvm5.0-devel \
                   nodejs npm \
                   nano pandoc \
                   postgresql \
                   libXt-devel && \
    yum groupinstall -y "Development tools" && \
    yum clean all && \
    rm -rf /var/cache/yum

ENV GOPATH /home/${NB_USER}/go
ENV PATH /usr/local/go/bin/:${PATH}


RUN ( \
        wget https://dl.google.com/go/go1.16.2.linux-amd64.tar.gz && \
        tar -zxvf go1.16.2.linux-amd64.tar.gz && \
        mv go /usr/local/ && \
        rm go1.16.2.linux-amd64.tar.gz && \    
        mkdir dasgoclient_build && cd dasgoclient_build && \
	git clone https://github.com/dmwm/dasgoclient.git && \
	cd dasgoclient && \
        /usr/local/go/bin/go get github.com/dmwm/cmsauth && \
        /usr/local/go/bin/go get github.com/dmwm/das2go && \
        /usr/local/go/bin/go get github.com/vkuznet/x509proxy && \
        /usr/local/go/bin/go get github.com/buger/jsonparser && \
        /usr/local/go/bin/go get github.com/pkg/profile && \
	#/usr/local/go/bin/go get github.com/konsorten/go-windows-terminal-sequences && \
        make build_all && cp dasgoclient_amd64 /usr/local/bin/dasgoclient && cd ../.. && rm -rf dasgoclient_build \
    )



ENV APACHE_SPARK_VERSION 2.4.1
ENV HADOOP_VERSION 2.7.6
ENV SCALA_VERSION -2.12


RUN cd /tmp ; set -x && \
        wget -q http://mirror.accre.vanderbilt.edu/jupyter/hadoop-${HADOOP_VERSION}.tar.gz && \
        wget -q http://mirror.accre.vanderbilt.edu/jupyter/spark-${APACHE_SPARK_VERSION}-bin-without-hadoop-scala${SCALA_VERSION}.tgz && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-without-hadoop-scala${SCALA_VERSION}.tgz -C /usr/local && \
        tar xzf hadoop-${HADOOP_VERSION}.tar.gz -C /usr/local && \
        rm spark-${APACHE_SPARK_VERSION}-bin-without-hadoop-scala${SCALA_VERSION}.tgz && \
        rm hadoop-${HADOOP_VERSION}.tar.gz && \
    cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-without-hadoop-scala${SCALA_VERSION} spark && \
                     ln -s hadoop-${HADOOP_VERSION} hadoop && \
    mkdir -p /hdfs \
             /mnt/hadoop \
             /hadoop \
             /cms \
             /etc/cvmfs/

#
# We have to get Jupyter before we can make the R kernel, but the R kernel takes
# forever to build. Split up this dep by itself to not trigger rebuilds of R
# every time we add a new python dep
#
# Note: Centos7 has python3.4, but new jupyter versions require python >= 3.6
#

# First, globally disable pip caching to keep from having to add the arg for
# every install
ENV PIP_NO_CACHE_DIR=off

# Now do the install
RUN ( \        
        python3.6 /tmp/get-pip.py && \
        python3.6 -m pip install --upgrade setuptools pip virtualenv && \
        python3.6 -m virtualenv /usr/local/jupyter && \
        source /usr/local/jupyter/bin/activate && \
        pip3 install jupyter ipykernel py4j google-common hdfs hdfs3 matplotlib scipy numpy \
	     scikit-learn keras==2.2.4 tensorflow jupyter metakernel zmq \
	     lz4 notebook==5.* uproot tornado==5.1.1  coffea awkward tables neural-structured-learning \
	     pandas \
    )

#
# Now install the system-wide Jupyter extensions. Users can add their own, but
# we want these here by default.
#
RUN ( \
        set -x && \
        source /usr/local/jupyter/bin/activate ; \
        pip3.6 install \
                    jupyter jupyterhub jupyterlab \
                    RISE jupyter_nbextensions_configurator jupyter-spark \
                    widgetsnbextension nbgrader nbgitpuller nbconvert && \
        jupyter nbextension install --py --sys-prefix rise && \
        jupyter nbextension install --py --sys-prefix jupyter_spark && \
        jupyter nbextension install --py --sys-prefix nbgrader && \
        jupyter nbextension enable --py --sys-prefix rise && \
        jupyter nbextension enable --py --sys-prefix jupyter_spark && \
        jupyter serverextension enable --py --sys-prefix jupyter_spark && \
        jupyter serverextension enable --py --sys-prefix nbgrader && \
        jupyter serverextension enable --py --sys-prefix nbgitpuller && \
        jupyter serverextension enable --py --sys-prefix jupyterlab && \
        jupyter nbextensions_configurator enable --sys-prefix && \
        ln -s /usr/local/jupyter/bin/jupyter /usr/local/bin/jupyter \
    )

ENV SPARK_HOME /usr/local/spark
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/spark/conf
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.6-src.zip
ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

# SSH Config
COPY krb5.conf /etc/krb5.conf
RUN echo "Host cmslpc*.fnal.gov" >> /etc/ssh/ssh_config && \
    echo "    GSSAPIAuthentication yes" >> /etc/ssh/ssh_config && \
    echo "    GSSAPIDelegateCredentials yes" >> /etc/ssh/ssh_config && \
    echo "    GSSAPITrustDNS yes" >> /etc/ssh/ssh_config && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config
RUN groupadd -g 101 hadoop && \
    useradd -m -s /bin/bash -N -u 100 -g hadoop hadoop

COPY hdfs-site.xml /usr/local/spark/conf/hdfs-site.xml
COPY core-site.xml /usr/local/spark/conf/core-site.xml
COPY spark-env.sh /usr/local/spark/conf/spark-env.sh
COPY hadoop-xrootd-1.0.0-SNAPSHOT-jar-with-dependencies.jar /usr/local/hadoop/share/hadoop/common/lib/

ENV LANG en_US.utf8
ENV JAVA_HOME /usr
ENV LD_LIBRARY_PATH "/usr/local/hadoop/lib/native:${LD_LIBRARY_PATH}"
ENV PATH "/usr/local/jupyter/bin:/usr/local/hadoop/bin:/usr/local/spark/bin:${PATH}"
ENV SPARK_PY4J_ZIPBALL=$SPARK_HOME/python/lib/py4j-0.10.6-src.zip
CMD [ -f $SPARK_PY4J_ZIPBALL ]
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_PY4J_ZIPBALL
EXPOSE 8888

USER jovyan
ENTRYPOINT ["/bin/bash", "-l", "-c"]
