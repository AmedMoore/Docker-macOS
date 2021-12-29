FROM amd64/ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and upgrade packages.
RUN apt-get update && apt-get -y upgrade

# Install QEMU and other packages.
RUN apt-get -y install \
    build-essential \
    qemu \
    uml-utilities \
    virt-manager \
    git \
    wget \
    libguestfs-tools \
    p7zip-full \
    make

# Add user to the kvm and libvirt groups.
RUN usermod -aG kvm $(whoami) && \
    usermod -aG libvirt $(whoami)

# Set the work directory to "/OSX-KVM"
WORKDIR /OSX-KVM

# Copy source code.
COPY . .

# Fetch macOS installer,
# this will fetch macOS Catalina (10.15).
RUN echo 3 | ./fetch-macOS-v2.py

# Convert the downloaded BaseSystem.dmg file into the BaseSystem.img file.
RUN qemu-img convert BaseSystem.dmg -O raw BaseSystem.img

# Create a virtual HDD image where macOS will be installed.
RUN qemu-img create -f qcow2 mac_hdd_ng.img 14G
