FROM openjdk:8
WORKDIR /root

RUN apt-get update \
&& apt-get install wget -y \
&& apt-get install -y libfindbin-libs-perl \
&& apt-get install jq -y \
&& apt install python2 -y \
&& apt install curl -y \
&& apt install gzip \
&& apt-get install openssh-client -y

ENV JAVA_HOME=/usr/local/openjdk-8

CMD ["/bin/bash"]
