FROM izone/arm:jessie

workdir /root
RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y install logrotate mlocate supervisor

ADD https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.4.1/elasticsearch-2.4.1.deb /root
ADD https://download.elastic.co/kibana/kibana/kibana-4.6.1-linux-x86_64.tar.gz /root
ADD https://download.elastic.co/logstash/logstash/packages/debian/logstash-2.4.0_all.deb /root
ADD http://node-arm.herokuapp.com/node_latest_armhf.deb /root
RUN dpkg -i elasticsearch-2.4.1.deb
RUN dpkg -i logstash-2.4.0_all.deb

RUN mkdir -p /opt/es/data
RUN mkdir -p /etc/kibana
RUN mkdir -p /opt/kibana

RUN tar -zxvf kibana-4.6.1-linux-x86_64.tar.gz
workdir /root/kibana-4.6.1-linux-x86_64
RUN mv * /opt/kibana/
workdir /root

RUN apt-get -y install ant git build-essential openjdk-7-jdk
RUN mkdir -p /opt/logstash/vendor/bundle/jruby/1.9/lib/jni/arm-Linux/
RUN git clone https://github.com/jnr/jffi.git
workdir /root/jffi
RUN ant jar
RUN cp build/jni/libjffi-1.2.so /opt/logstash/vendor/bundle/jruby/1.9/lib/jni/arm-Linux/
RUN apt-get -y remove ant git build-essential openjdk-7-jdk
workdir /root

RUN dpkg -i node_latest_armhf.deb
RUN mv /opt/kibana/node/bin/node /opt/kibana/node/bin/node.orig
RUN mv /opt/kibana/node/bin/npm /opt/kibana/node/bin/npm.orig
RUN ln -s /usr/local/bin/node /opt/kibana/node/bin/node
RUN ln -s /usr/local/bin/npm /opt/kibana/node/bin/npm

RUN rm -rf kibana* *.deb jffi
RUN echo "export JAVA_OPTIONS=-Xmx512M" >> .bashrc
RUN mkdir -p /usr/share/elasticsearch/config/scripts

COPY conf/supervisord.conf /etc/supervisor/supervisord.conf
COPY conf/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY conf/logging.yml /usr/share/elasticsearch/config/logging.yml
COPY conf/kibana.yml /etc/kibana/kibana.yml
COPY conf/logstash.conf /etc/logstash/conf.d/logstash.conf

CMD ["/usr/bin/supervisord"]
EXPOSE 9200 9300 5601 5000/udp 6666
