FROM frolvlad/alpine-glibc:alpine-3.8

# update base image and download required glibc libraries
RUN apk add --no-cache nss
RUN apk update && apk add libaio libnsl && \
    ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1

#install node, git, python and cleanup cache
RUN apk add --update \
    nodejs \
    nodejs-npm \
    git \
    python \
   && rm -rf /var/cache/apk/*

# get oracle instant client
ENV CLIENT_FILENAME instantclient-basic-linux.x64-18.5.0.0.0dbru.zip 
ENV JAVA_JAR_FILE ATPMicroService-0.0.1-SNAPSHOT.jar

# set working directory
WORKDIR /opt/oracle/lib

# Add instant client zip file
ADD ${CLIENT_FILENAME} .
ADD ${JAVA_JAR_FILE} .

# unzip required libs, unzip instant client and create sim links
RUN LIBS="libociei.so libocci.so.18.1 libons.so libnnz18.so libclntshcore.so.18.1 libclntsh.so.18.1" && \
    unzip ${CLIENT_FILENAME} && \
    cd instantclient_18_5 && \
    for lib in ${LIBS}; do cp ${lib} /usr/lib; done && \
    ln -s /usr/lib/libclntsh.so.18.1 /usr/lib/libclntsh.so 
    # rm ${CLIENT_FILENAME}

# get node app from git repo
RUN git clone https://github.com/cloudsolutionhubs/ATPDocker.git
RUN apk update
RUN apk fetch openjdk8
RUN apk add openjdk8
RUN apk update
RUN apk fetch curl
RUN apk add curl
RUN mkdir wallet_NODEAPPDB2
COPY ./Wallet_jse ./wallet_NODEAPPDB2
RUN mkdir ATP_Jar
COPY ./ATPMicroService-0.0.1-SNAPSHOT.jar ./ATP_Jar

#set env variables
ENV ORACLE_BASE /opt/oracle/lib/instantclient_18_5
ENV LD_LIBRARY_PATH /opt/oracle/lib/instantclient_18_5
ENV TNS_ADMIN /opt/oracle/lib/wallet_NODEAPPDB2
ENV ORACLE_HOME /opt/oracle/lib/instantclient_18_5
ENV PATH /opt/oracle/lib/instantclient_18_5/:/opt/oracle/lib/wallet_NODEAPPDB2:/opt/oracle/lib/ATPDocker/aone:/opt/oracle/lib/ATPDocker/aone/node_modules:$PATH

RUN cd /opt/oracle/lib/ATPDocker/aone && \
	npm install oracledb

EXPOSE 9081
CMD ["/bin/sh", "-c", "java -cp /opt/oracle/lib/ATP_Jar/ATPMicroService-0.0.1-SNAPSHOT.jar com.oracle.connect.ATPMicroService.ATPMain"]
