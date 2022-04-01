FROM gcr.io/instruqt-images-330918/java8base:1.0
WORKDIR /root

RUN curl -O https://static.imply.io/release/imply-2021.09.tar.gz \
&& tar -xzf imply-2021.09.tar.gz \
&& wget https://github.com/shallada/InstruqtImages/raw/main/pivot-db/pivot-settings.sqlite -P /root/imply-2021.09/var/pivot \
&& apt-get install python3 -y \
&& apt install python3-pip -y \
&& pip install plotext \
&& pip3 install requests \
&& curl -O https://archive.apache.org/dist/kafka/2.7.0/kafka_2.13-2.7.0.tgz \
&& tar -xzf kafka_2.13-2.7.0.tgz


CMD ["/bin/bash"]
