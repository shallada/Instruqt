FROM gcr.io/instruqt-images-330918/java8base:1.0
WORKDIR /root

RUN wget https://ftp.wayne.edu/apache/druid/0.21.1/apache-druid-0.21.1-bin.tar.gz \
&& tar -xzf apache-druid-0.21.1-bin.tar.gz \
&& gunzip /root/apache-druid-0.21.1/quickstart/tutorial/wikiticker-2015-09-12-sampled.json.gz

CMD ["/bin/bash"]
