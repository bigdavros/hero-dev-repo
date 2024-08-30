FROM maven:3-openjdk-11-slim

# Install Tomcat
RUN groupadd tomcat
RUN useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
WORKDIR /tmp
RUN apt update 
RUN apt install curl wget jq git -y
# Apache Tomcat doesn't offer a "-latest" shortcut,
# figure out the latest Tomcat 9.0 and download it.
RUN curl -s "https://dlcdn.apache.org/tomcat/tomcat-9/?C=M;O=D" 2>&1 \
| grep "\[DIR\]" | head -1 | cut -d'"' -f6 | sed 's/v//g' | sed 's/\///g' \
| awk '{print "https://dlcdn.apache.org/tomcat/tomcat-9/v"$0"/bin/apache-tomcat-"$0".tar.gz"}' \
| xargs curl -O
RUN mkdir /opt/tomcat
RUN tar xzvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
WORKDIR /opt/tomcat
RUN chgrp -R tomcat /opt/tomcat
RUN chown -R tomcat webapps/ work/ temp/ logs/

ARG development=false
ARG filename=nosecrets.json # Optional default value to be `nosecrets.json`
ARG apikey=AAA
ARG legacykey=BBB
ARG trustedkey=CCC
ARG comitid=Local
ARG sa=nosecrets.json

WORKDIR /
RUN rm -rf /opt/tomcat/webapps/ROOT
ADD target/demo-container.war /opt/tomcat/webapps/ROOT.war
ADD config.json /
ADD config.sh /
ADD make-secrets.sh /

RUN chmod +x make-secrets.sh

ADD ${filename} /

RUN mkdir /secrets 

RUN if [ "$development" = "true" ] ; then \
    mv secrets.json /secrets/recaptcha-demo-secrets.json ; \
fi 

RUN if [ "$development" = "false" ] ; then \
    /make-secrets.sh $apikey $legacykey $trustedkey; \
fi 

RUN chmod +x /config.sh && /config.sh ${comitid} && sed 's/#!\/usr\/bin\/env bash//g' /opt/tomcat/bin/catalina.sh >> /newcatalina.sh && cp /newcatalina.sh /opt/tomcat/bin/catalina.sh && chmod +x /opt/tomcat/bin/catalina.sh

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]