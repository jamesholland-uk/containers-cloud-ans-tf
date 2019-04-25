FROM ubuntu:bionic

RUN apt-get update -q \
    && apt-get install -y \
        curl \
        git \
        unzip \
        wget \
        python-pip

# Ansible ~76MB
ENV ANSIBLE_VERSION=2.7.9
RUN pip install ansible==${ANSIBLE_VERSION} \
        pandevice \
        pan-python \
        xmltodict \
        jsonschema 
RUN mkdir /etc/ansible
RUN wget https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg -O /etc/ansible/ansible.cfg
RUN wget https://raw.githubusercontent.com/ansible/ansible/devel/examples/hosts -O /etc/ansible/hosts
RUN ansible-galaxy install PaloAltoNetworks.paloaltonetworks
RUN echo '[defaults]' >> /etc/ansible/ansible.cfg
RUN echo 'library = /root/.ansible/roles/PaloAltoNetworks.paloaltonetworks/library/' >> /etc/ansible/ansible.cfg

# Microsoft Azure CLI (az) ~170MB
RUN pip install azure-cli

# Terraform 0.11 ~90MB
ENV tf_ver=0.11.13
RUN curl -L -o terraform.zip https://releases.hashicorp.com/terraform/${tf_ver}/terraform_${tf_ver}_linux_amd64.zip && \
    unzip terraform.zip && \
    install terraform /usr/local/bin/terraform-0.11 && \
    rm -rf terraform.zip terraform && \
    mv /usr/local/bin/terraform-0.11 /usr/local/bin/terraform
RUN echo 'alias terraform="/usr/local/bin/terraform"' >> /root/.bashrc
RUN echo 'alias tf="/usr/local/bin/terraform"' >> /root/.bashrc

# Google Cloud SDK ~140MB
ENV GCLOUD_VERSION 240.0.0
RUN curl --silent -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$GCLOUD_VERSION-linux-x86_64.tar.gz -o google-cloud-sdk.tar.gz \
 && tar xzf google-cloud-sdk.tar.gz \
 && rm google-cloud-sdk.tar.gz \
 && google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc \
 && google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true
RUN echo 'alias gcloud="/google-cloud-sdk/bin/gcloud"' >> /root/.bashrc
RUN echo 'alias gsutil="/google-cloud-sdk/bin/gsutil"' >> /root/.bashrc

# AWS CLI ~60MB
RUN pip install awscli awsebcli

# Clean-up
RUN apt-get -y autoremove && \
    apt-get -y autoclean && \ 
    apt-get -y clean all && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.pip/cache && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt
