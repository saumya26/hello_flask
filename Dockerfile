############################################################################################################################################
#   Limited Materials - Property of IBM
#   5636-ZCB
#   C) Copyright IBM Corp. 2025 All Rights Reserved
#   US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
############################################################################################################################################

#
# Start from latest UBI 9 minimal image
#
FROM --platform=linux/amd64 registry.access.redhat.com/ubi9-minimal:latest

#
# Environment variables
#
ENV SHELL="bash" \
    GOPATH="/root/go" \
    PATH="$PATH:/usr/local/go/bin:/root/go/bin" 

#
# Update packages and install Go
#

RUN microdnf upgrade -y && \
    microdnf install -y wget gzip gcc sudo tar git make gcc gpg findutils zip jq && \
    microdnf clean all && \
    wget -q -c https://github.com/hashicorp/copywrite/releases/download/v0.22.0/copywrite_0.22.0_linux_x86_64.tar.gz -O - | sudo tar --overwrite -xz -C /usr/local/bin && \
    wget -q -c https://go.dev/dl/go1.24.6.linux-amd64.tar.gz -O - | sudo tar --overwrite -xz -C /usr/local && \
    wget -q -c https://github.com/goreleaser/goreleaser/releases/download/v2.9.0/goreleaser_Linux_x86_64.tar.gz -O - | sudo tar --overwrite -xz -C /usr/local/bin && \
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.1.6 && \
    curl -sSfL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | sh -s -- -b /usr/local/bin && \
     # Install GoSec v2.20.0
    curl -sSfL https://raw.githubusercontent.com/securego/gosec/master/install.sh | sh -s -- -b /usr/local/bin v2.20.0 && \ 
    #Install OC Cli
    curl -sSL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.15.0/openshift-client-linux-4.15.0.tar.gz | tar -xz -C /usr/local/bin oc && \
    git clone https://github.com/bflad/tfproviderlint.git
WORKDIR /tfproviderlint
RUN go mod tidy && \
    go build ./cmd/tfproviderlintx/tfproviderlintx.go && \
    cp tfproviderlintx /usr/local/bin
WORKDIR /
