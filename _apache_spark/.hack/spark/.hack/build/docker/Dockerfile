FROM quay.io/centos/centos:stream9
ADD rootfs /

#######################################################################
### Linux (Kernel + OS)
#######################################################################

RUN yum update -y;
RUN yum group install -y "Development Tools";
RUN yum install -y \
        jq tree \
        hostname lsof iproute iputils nc net-tools tcpdump \
        tmux;

RUN yum install -y sudo util-linux; \
    sed -i "s/root.*$/&\ndanny ALL=(ALL) NOPASSWD:ALL/" /etc/sudoers; \
    useradd -ms /bin/bash danny;

RUN curl -kL https://github.com/tsl0922/ttyd/releases/download/1.7.1/ttyd.x86_64 -o /usr/bin/ttyd; \
    chmod +x /usr/bin/ttyd;

USER    danny
WORKDIR /home/danny

COPY --chown=danny:danny homefs /home/danny


#######################################################################
### Java
#######################################################################

RUN mkdir -p /home/danny/.danny/opt/java/java; \
    cd /home/danny/.danny/opt/java/java; \
    curl -kL https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz -O; \
    tar -zxvf jdk-17_linux-x64_bin.tar.gz; \
    ln -sf `find . -type d -name "jdk-17*"` current;

RUN mkdir -p /home/danny/.danny/opt/java/maven; \
    cd /home/danny/.danny/opt/java/maven; \
    curl -kL https://dlcdn.apache.org/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.tar.gz -O; \
    tar -zxvf apache-maven-3.9.1-bin.tar.gz; \
    ln -sf apache-maven-3.9.1 current;

RUN mkdir -p /home/danny/.danny/opt/spark/spark; \
    cd /home/danny/.danny/opt/spark/spark; \
    curl -kL https://archive.apache.org/dist/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz -O; \
    tar -zxvf spark-3.3.1-bin-hadoop3.tgz; \
    ln -sf spark-3.3.1-bin-hadoop3 current;

RUN . /home/danny/.bashrc; \
    mvn dependency:get -Dartifact=org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.1; \
    mvn dependency:get -Dartifact=org.slf4j:slf4j-api:1.7.32; \
    mvn dependency:get -Dartifact=org.lz4:lz4-java:1.8.0; \
    mvn dependency:get -Dartifact=org.xerial.snappy:snappy-java:1.1.8.4; \
    mvn dependency:get -Dartifact=org.postgresql:postgresql:42.6.0;
 
RUN mkdir -p /home/danny/.danny/var/data/spark/master/.recovery; \
    mkdir -p /home/danny/.danny/var/data/spark/worker;

#######################################################################
### NodeJS
#######################################################################

RUN mkdir -p /home/danny/.danny/opt/node/node; \
    cd /home/danny/.danny/opt/node/node; \
    curl -kL https://nodejs.org/dist/v16.17.1/node-v16.17.1-linux-x64.tar.xz -O; \
    tar -xvf node-v16.17.1-linux-x64.tar.xz; \
    ln -sf node-v16.17.1-linux-x64 current;

#######################################################################
### Python
#######################################################################

RUN mkdir -p /home/danny/.danny/opt/conda/conda3; \
        cd /home/danny/.danny/opt/conda/conda3; \
        curl -kL https://repo.anaconda.com/miniconda/Miniconda3-py310_23.1.0-1-Linux-x86_64.sh -O; \
        sh ./Miniconda3-py310_23.1.0-1-Linux-x86_64.sh -b -p /home/danny/.danny/opt/conda/conda3/Miniconda3-py310_23.1.0-1; \
        ln -nsf Miniconda3-py310_23.1.0-1 current;

RUN . /home/danny/.bashrc; \
    conda install --name base \
        conda-build \
        jupyterlab=2.3.1 \
        -y; \
    conda create --name danny \
        python=3.10 \
        grpcio grpcio-tools \
        numpy scipy pandas matplotlib \
        ipykernel ipywidgets \
        -y;

RUN . /home/danny/.bashrc; \
    conda activate base; \
    jupyter labextension install @jupyterlab/google-drive; \
    conda deactivate;

RUN . /home/danny/.bashrc; \
    conda activate danny; \
    http_proxy="" https_proxy=""; \
    python -m ipykernel \
        install \
            --prefix=/home/danny/.danny/opt/conda/conda3/current \
            --name=danny \
            --display-name=danny; \
    pip install twine; \
    pip install grpcio-reflection; \
    pip install grpc_requests; \
    pip install confluent-kafka; \
    pip install elasticsearch==8.6.0; \
    pip install pyspark==3.3.1; \
    pip install psycopg2==2.9.5; \
    conda deactivate;

RUN mkdir -p /home/danny/.danny/var/workspace/jupyter/doc;

RUN echo "conda activate danny" >> /home/danny/.bashrc.d/conda.sh

COPY --chown=danny:danny appfs /home/danny/.danny

RUN chmod +x /home/danny/.danny/bin/*
CMD [ ".danny/bin/app.sh", "--start" ]
