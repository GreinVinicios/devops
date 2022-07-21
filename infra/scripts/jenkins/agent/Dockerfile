FROM jenkins/inbound-agent

USER root

# Docker script
# RUN apt update
# RUN apt install -y curl
# RUN curl -fsSL https://get.docker.com -o get-docker.sh
# RUN sh ./get-docker.sh
# RUN usermod -aG docker jenkins

# Docker manual installation
RUN echo 'Installing docker routine ...'
RUN apt-get update && \
    apt-get -y install apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    uidmap \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get -y install docker-ce
RUN usermod -a -G docker jenkins
RUN usermod -a -G docker root

USER jenkins
RUN dockerd-rootless-setuptool.sh install

USER root
RUN systemctl enable docker.service
RUN systemctl enable containerd.service

RUN chown jenkins:jenkins /home/jenkins/.docker -R
RUN chmod g+rwx "/home/jenkins/.docker" -R
#RUN chown jenkins /var/run/docker.sock

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
#ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

RUN chgrp docker /lib/systemd/system/docker.socket
RUN chmod g+w /lib/systemd/system/docker.socket

#CMD ["/bin/bash", "-c", "service docker start"]
CMD ["/bin/bash", "-c", "/usr/local/bin/entrypoint.sh"]
