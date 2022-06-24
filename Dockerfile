# not to mix java versions I will ignore this for now especially that we are using Java 11 for project
#FROM ghcr.io/graalvm/jdk:java17-21.3.0
FROM cimg/openjdk:11.0.13-node

ARG PYTHON_VERSION=3.9

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip zip jq git make python${PYTHON_VERSION} python3-venv python3-pip

# Install aws-sam-cli
RUN curl "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -L -o "aws-sam-cli-linux-x86_64.zip" && \
    unzip aws-sam-cli-linux-x86_64.zip -d sam-installation && \
    ./sam-installation/install && \
    sam --version

# Install jbang for quarkus-cli install
RUN curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/ && \
    curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio

# Update NPM
RUN npm config set unsafe-perm true
RUN npm update -g

# Install AWSCLI
RUN pip install --upgrade pip && \
    pip install --upgrade awscli

# Install Serverless Framework
RUN npm install -g serverless

ENV HOME_PATH=/home/circleci/project

# Install GraalVM
# Set graavlVM version
ENV GRAALVM_JAVA_11_VERSION=22.1.0

# Download tar file and decompress it
RUN curl https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$GRAALVM_JAVA_11_VERSION/graalvm-ce-java11-linux-amd64-$GRAALVM_JAVA_11_VERSION.tar.gz  -O -J -L && \
    tar xfz graalvm-ce-java11-linux-amd64-$GRAALVM_JAVA_11_VERSION.tar.gz && \
    mv graalvm-ce-java11-$GRAALVM_JAVA_11_VERSION .graalvm

ENV GRAALVM_HOME=$HOME_PATH/.graalvm

# Install native image
RUN $GRAALVM_HOME/bin/gu install native-image

# Clean up after installation
RUN rm *.gz *.zip

