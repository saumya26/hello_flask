FROM golang:1.25 AS builder

ENV PATH=$PATH:/usr/local/go/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates git unzip make gcc && \
    rm -rf /var/lib/apt/lists/*

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
    | sh -s -- -b /usr/local/bin v1.60.1

# Install gosec
RUN go install github.com/securego/gosec/v2/cmd/gosec@v2.20.0 && \
    mv /go/bin/gosec /usr/local/bin/

# Install oc CLI
RUN curl -sSL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.15.0/openshift-client-linux-4.15.0.tar.gz \
    | tar -xz -C /usr/local/bin oc

CMD ["bash"]
