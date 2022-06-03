FROM registry.access.redhat.com/ubi8/openjdk-11:1.13-1.1653918221

#Setup Proxies by uncommenting below and specifying proxies to use
#ENV HTTP_PROXY="http://company.proxy.com:8080"
#ENV HTTPS_PROXY="http://company.proxy.com:8080"
#ENV NO_PROXY="company.com"

ARG maintainer="Maintainer"

LABEL maintainer=${maintainer}

LABEL name="github-action-base-image"

LABEL description="ubi-based with Maven, OpenShift, Helm, Proxy Configurations and Certificates"

USER root

# Copy Company root/issuer CA Certificates by uncommenting below and specifying proper crts.
COPY ./certificates/company_issuing.crt /etc/pki/ca-trust/source/anchors/
COPY ./certificates/company_root.crt /etc/pki/ca-trust/source/anchors/

# Install CA certs
RUN update-ca-trust

# update microdnf packages; install tar gzip and git
RUN microdnf -y update && \
    microdnf -y install tar gzip git && microdnf clean all


# Install OpenShift Client
COPY ./libs/openshift-client-linux.tar.gz /tmp/openshift-client-linux.tar.gz

RUN mkdir -p /opt/oc && \
    tar zxf /tmp/openshift-client-linux.tar.gz -C /opt/oc && \
    chmod a+x /opt/oc/oc && \
    ln -s /opt/oc/oc /usr/local/bin/oc && \
    ln -s /opt/oc/kubectl /usr/local/bin/kubectl && \
    rm -f /tmp/openshift-client-linux.tar.gz

# Specify openshift configuration file
RUN mkdir /.kube && chmod -R a+rx /.kube
COPY ./oc/oc_config /.kube/config
RUN chmod go-r /.kube/config
ENV KUBECONFIG /.kube/config

# Install helm Client
COPY ./libs/helm-linux-amd64.tar.gz /tmp/helm-linux-amd64.tar.gz

RUN mkdir -p /opt/helm && \
    tar zxf /tmp/helm-linux-amd64.tar.gz -C /opt/helm && \
    chmod a+x /opt/helm/helm && \
    ln -s /opt/helm/helm /usr/local/bin/helm && \
    rm -f /tmp/helm-linux-amd64.tar.gz


# Uncomment and modify the custom settings.xml file if you have it.
#COPY ./maven/settings.xml /root/.m2/settings.xml

ENTRYPOINT [""]