ARG ADD_LOCAL_CERTS="none"

FROM mcr.microsoft.com/devcontainers/base:jammy

ENV USERNAME vscode
ENV HOME /home/$USERNAME
ENV NODE_EXTRA_CA_CERTS /etc/nodecerts.pem
ENV PATH $PATH:$HOME/.local/bin

ADD createCerts.sh .
ADD nodecerts.pem /etc/nodecerts.pem
RUN apt-get update && apt-get install dos2unix git python2 curl -y \
    && dos2unix /createCerts.sh \
    && chmod +x /createCerts.sh \
    && /createCerts.sh \
    && update-ca-certificates 
    
# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine
# inside the container "overrideCommand": false is set in devcontainer.json.
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
