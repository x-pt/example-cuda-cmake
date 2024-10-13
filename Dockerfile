# BUILDING
FROM rockylinux:9 AS builder
LABEL author="X Author Name"
WORKDIR /app

# build deps
RUN dnf upgrade --refresh -y && \
    dnf --enablerepo=crb install -y \
        cmake \
        gcc \
        gcc-c++ \
        make \
        # enable repo crb to install the following packages for building static binary
        libstdc++-static \
        glibc-static && \
    # due to this Dockerfile is a multi-stage, the following clean steps are redundant.
    dnf clean all && \
    rm -fr /var/cache/yum

COPY .. .

RUN cmake -B build && cmake --build build --target example-cuda-cmake --config Release --parallel 8

# DEPLOYING
FROM rockylinux:9-minimal

COPY --from=builder /app/build/example-cuda-cmake /example-cuda-cmake

CMD ["/example-cuda-cmake"]
