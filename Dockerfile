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
#Build arguments for versions
#
ARG COPYWRITE_VERSION=v0.22.0
ARG GO_VERSION=1.24.7
ARG GORELEASER_VERSION=v2.9.0
ARG GOLANGCI_LINT_VERSION=v2.1.6
ARG GOSEC_VERSION=v2.20.0
ARG OC_VERSION=4.15.0


#
# Update packages and install dependencies
#
RUN microdnf upgrade -y && \
    microdnf install -y wget gzip gcc sudo tar git make gcc gpg findutils zip jq && \
    microdnf clean all && \
    wget -q -c https://github.com/hashicorp/copywrite/releases/download/${COPYWRITE_VERSION}/copywrite_0.22.0_linux_x86_64.tar.gz -O - | sudo tar --overwrite -xz -C /usr/local/bin && \
    wget -q -c https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O - | sudo tar --overwrite -xz -C /usr/local && \
    wget -q -c https://github.com/goreleaser/goreleaser/releases/download/${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz -O - | sudo tar --overwrite -xz -C /usr/local/bin && \
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b $(go env GOPATH)/bin ${GOLANGCI_LINT_VERSION} && \
    curl -sSfL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | sh -s -- -b /usr/local/bin && \
    curl -sfL https://raw.githubusercontent.com/securego/gosec/master/install.sh | sh -s -- -b /usr/local/bin ${GOSEC_VERSION} && \
    curl -sSL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}/openshift-client-linux-4.15.0.tar.gz | tar -xz -C /usr/local/bin oc && \


    git clone https://github.com/bflad/tfproviderlint.git
WORKDIR /tfproviderlint
RUN go mod tidy && \
    go build ./cmd/tfproviderlintx/tfproviderlintx.go && \
    cp tfproviderlintx /usr/local/bin
WORKDIR /


