# Stage 1: Builder
FROM golang:1.22-bullseye AS builder

ARG GOLANGCI_LINT_VERSION=v1.60.1
ARG GOSEC_VERSION=2.20.0
ARG OC_VERSION=4.15.0

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates git unzip make gcc && \
    rm -rf /var/lib/apt/lists/*

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
    | sh -s -- -b /usr/local/bin ${GOLANGCI_LINT_VERSION}

# Install gosec
RUN go install github.com/securego/gosec/v2/cmd/gosec@v${GOSEC_VERSION} && \
    mv /go/bin/gosec /usr/local/bin/

# Install oc CLI (pin to your OCP version if you prefer)
RUN curl -sSL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}/openshift-client-linux-${OC_VERSION}.tar.gz \
    | tar -xz -C /usr/local/bin oc

# Stage 2: Final image (lean)
FROM debian:bullseye-slim

# Copy Go toolchain & tools
COPY --from=builder /usr/local/go /usr/local/go
COPY --from=builder /usr/local/bin/golangci-lint /usr/local/bin/
COPY --from=builder /usr/local/bin/gosec /usr/local/bin/
COPY --from=builder /usr/local/bin/oc /usr/local/bin/

ENV PATH=$PATH:/usr/local/go/bin

# (Optional) health check / versions sanity
RUN go version && golangci-lint --version && gosec --version && oc version --client

CMD ["bash"]
