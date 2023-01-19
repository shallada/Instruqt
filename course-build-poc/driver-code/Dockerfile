FROM python:3.8

WORKDIR /root

COPY DruidDataDriver.py /root/

RUN pip install python-dateutil \
&& pip install kafka-python \
&& pip install numpy

#ENTRYPOINT [ "python /root/DruidDataDriver.py -n 10 -f " ]

CMD ["/bin/sh"]
