##
# BUILD CONTAINER
##

FROM alpine:3.19 as certs

RUN \
apk add --no-cache ca-certificates



FROM golang:1.22 as builder
COPY . /go/src/gitlab-ci-pipelines-exporter
WORKDIR /go/src/gitlab-ci-pipelines-exporter
RUN go build ./cmd/gitlab-ci-pipelines-exporter
##
# RELEASE CONTAINER
##

FROM busybox:1.36-glibc

WORKDIR /

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/src/gitlab-ci-pipelines-exporter /usr/local/bin/

# Run as nobody user
USER 65534

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/gitlab-ci-pipelines-exporter"]
CMD ["run"]
