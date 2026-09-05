ARG ALMA_REPOS_IMAGE=quay.io/almalinuxorg/10-base:10
ARG BOOTC_IMAGECTL_IMAGE=quay.io/centos-bootc/centos-bootc:stream10
ARG ALMA_BUILDER_IMAGE=quay.io/almalinuxorg/10-kitten-base:10-kitten
ARG IMAGE_REPOSITORY=ghcr.io/highwaytoit/alma-black-box

# Compose a fresh AlmaLinux 10 bootc root filesystem from the upstream
# minimal-plus content tier. This follows AlmaLinux's own bootc image build
# structure, but deliberately does not include the full standard server tier.
FROM ${ALMA_REPOS_IMAGE} AS repos
FROM ${BOOTC_IMAGECTL_IMAGE} AS imagectl
FROM ${ALMA_BUILDER_IMAGE} AS rootfs-builder

RUN dnf install -y \
    podman \
    bootc \
    ostree \
    rpm-ostree \
    && dnf clean all

COPY --from=imagectl /usr/share/doc/bootc-base-imagectl/ /usr/share/doc/bootc-base-imagectl/
COPY --from=imagectl /usr/libexec/bootc-base-imagectl /usr/libexec/bootc-base-imagectl
RUN chmod +x /usr/libexec/bootc-base-imagectl

RUN rm -rf /etc/yum.repos.d/*
COPY --from=repos /etc/yum.repos.d/*.repo /etc/yum.repos.d/
COPY --from=repos /etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-10 /etc/pki/rpm-gpg/

COPY build_files/almalinux-10-minimal-plus.yaml \
    /usr/share/doc/bootc-base-imagectl/manifests/almalinux-10-minimal-plus.yaml

RUN /usr/libexec/bootc-base-imagectl build-rootfs \
    --reinject \
    --manifest=almalinux-10-minimal-plus \
    /target-rootfs

FROM scratch AS alma-minimal-plus
COPY --from=rootfs-builder /target-rootfs/ /
LABEL containers.bootc=1 \
      ostree.bootable=1 \
      org.opencontainers.image.vendor="AlmaLinux OS Foundation" \
      io.highwaytoit.alma-black-box.base-profile="minimal-plus"
RUN bootc container lint --fatal-warnings
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]

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

FROM alma-minimal-plus
ARG IMAGE_REPOSITORY

LABEL org.opencontainers.image.title="Alma Black Box" \
      org.opencontainers.image.description="Purpose-built AlmaLinux bootc monitoring and infrastructure supervision appliance" \
      org.opencontainers.image.source="https://github.com/highwaytoit/alma-black-box" \
      io.highwaytoit.alma-black-box.base-profile="minimal-plus"

COPY --from=upside-builder /out/usr/share/cockpit/upside/ /usr/share/cockpit/upside/

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/run \
    --mount=type=tmpfs,dst=/tmp \
    IMAGE_REPOSITORY="${IMAGE_REPOSITORY}" \
    /ctx/build_files/build.sh

# Temporary testing-only marker for bootc update/reboot/rollback validation.
RUN printf 'update-test-2\n' > /usr/share/alma-black-box/update-test

RUN bootc container lint --fatal-warnings
