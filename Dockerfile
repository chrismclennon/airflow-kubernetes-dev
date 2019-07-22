FROM centos:7

ENV TERM linux

# Setup dependencies
RUN yum -y update \
    && yum -y groupinstall "Development Tools" \
    && yum -y install \
        vim gcc gcc-c++ cyrus-sasl-devel cyrus-sasl-gssapi libffi-devel \
        libselinux yum-utils mysql mysql-devel fernet python-devel.x86_64 \
	openssl-perl tmux
RUN echo "password" | passwd root --stdin

# Setup python 3
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
    && yum -y install python36u python36u-devel python36u-pip \
    && pip3.6 install -U pip \
    && pip3.6 install -U setuptools wheel

# Install kubectl
ARG KUBECTL_VERSION=1.9.3
RUN curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Install fixed versions of libraries as 1.10.3 workaround for AIRFLOW-4900
RUN pip install Jinja2==2.10.1 Werkzeug==0.15.4 Flask==1.0.4

# Install airflow
ARG AIRFLOW_VERSION=1.10.3
ENV AIRFLOW_GPL_UNIDECODE yes
ENV AIRFLOW_HOME /var/local/airflow
RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip3.6 install -U \
        pytz pyOpenSSL ndg-httpsclient pyasn1 mysqlclient cryptography \
        mysql-connector-python-rf kubernetes \
    && pip3.6 install \
        apache-airflow[celery,kubernetes,mysql,redis]==${AIRFLOW_VERSION} \
    && mkdir -p ${AIRFLOW_HOME}/airflow

# Set up airflow customizations
COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
COPY entrypoint.sh ${AIRFLOW_HOME}/entrypoint.sh
RUN chmod +x ${AIRFLOW_HOME}/entrypoint.sh
ENV PYTHONPATH=${AIRFLOW_HOME}/config:$PYTHONPATH

# Copy dags into image
COPY dags/ ${AIRFLOW_HOME}/dags

# Set ownership
RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080
USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["./entrypoint.sh"]
