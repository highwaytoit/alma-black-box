ARG ALMA_BOOTC_IMAGE=quay.io/almalinuxorg/almalinux-bootc:10
ARG IMAGE_REPOSITORY=ghcr.io/highwaytoit/alma-black-box

FROM scratch AS ctx
COPY build_files /build_files
COPY system_files /system_files
COPY quadlets /quadlets
COPY docs /docs
COPY cosign.pub /cosign.pub

# UPSide is built separately so Node.js/npm/git/build dependencies never remain
# in the final Alma Black Box image.
FROM registry.fedoraproject.org/fedora:44 AS upside-builder
COPY build_files/software.env /tmp/software.env
RUN dnf install -y git make nodejs npm tar \
    && . /tmp/software.env \
    && git clone https://github.com/deviationist/cockpit-upside.git /src/upside \
    && cd /src/upside \
    && test "$(git rev-parse "refs/tags/${UPSIDE_VERSION}^{commit}")" = "${UPSIDE_COMMIT}" \
    && git checkout --detach "${UPSIDE_COMMIT}" \
    && make \
    && mkdir -p /out/usr/share/cockpit/upside \
    && cp -a dist/. /out/usr/share/cockpit/upside/ \
    && test -f /out/usr/share/cockpit/upside/manifest.json \
    && dnf clean all

FROM ${ALMA_BOOTC_IMAGE}
ARG IMAGE_REPOSITORY
ARG ALMA_BOOTC_IMAGE

LABEL org.opencontainers.image.title="Alma Black Box" \
      org.opencontainers.image.description="Purpose-built AlmaLinux bootc monitoring and infrastructure supervision appliance" \
      org.opencontainers.image.source="https://github.com/highwaytoit/alma-black-box" \
      io.highwaytoit.alma-black-box.base="${ALMA_BOOTC_IMAGE}"

COPY --from=upside-builder /out/usr/share/cockpit/upside/ /usr/share/cockpit/upside/

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/run \
    --mount=type=tmpfs,dst=/tmp \
    IMAGE_REPOSITORY="${IMAGE_REPOSITORY}" \
    /ctx/build_files/build.sh

RUN bootc container lint --fatal-warnings
