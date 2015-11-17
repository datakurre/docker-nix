FROM busybox
MAINTAINER asko.soukka@iki.fi
RUN \
# Download, unpack and install nixpkgs
wget -O- http://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz | \
xz -d - | tar xf - && \
mkdir -p -m 0555 /var && mv nixpkgs* /var/nixpkgs && \
# Create non-root user
adduser --disabled-password --gecos '' user && \
# Prepare /nix while still as root
mkdir -p -m 0755 /nix/var/nix/profiles && chown user:user -R /nix && \
mkdir -p -m 0555 /usr && ln -s /nix/var/nix/profiles/default /usr/local
USER user
WORKDIR /home/user
ENV USER="user" HOME="/home/user" \
    NIX_PATH="nixpkgs=/var/nixpkgs" \
    GIT_SSL_CAINFO="/usr/local/etc/ssl/certs/ca-bundle.crt" \
    SSL_CERT_FILE="/usr/local/etc/ssl/certs/ca-bundle.crt"
RUN \
# Download and unpack Nix
version="1.10" && \
basename="nix-$version-x86_64-linux" && \
wget -O- http://nixos.org/releases/nix/nix-$version/$basename.tar.bz2 | \
bzcat - | tar xf - && \
# Inspect Nix install
nix=`grep -o -E 'nix="[^"]*"' $basename/install|grep -o '/[^"]*'` && \
cacert=`grep -o -E 'cacert="[^"]*"' $basename/install|grep -o '/[^"]*'` && \
# Install Nix manually
mv nix-1.10-x86_64-linux/store /nix && \
mkdir -p .nix-defexpr/channels && ln -s /var/nixpkgs .nix-defexpr/channels && \
$nix/bin/nix-store --init && \
$nix/bin/nix-store --load-db < $basename/.reginfo && \
# Init Nix default profile
SSL_CERT_FILE=$cacert/etc/ssl/certs/ca-bundle.crt && \
$nix/bin/nix-env -i $nix && \
$nix/bin/nix-env -i $cacert && \
$nix/bin/nix-collect-garbage -d && \
# Fix permissions
chmod a-ws -R /nix && chmod u+w -R /nix/var && chmod u+w /nix/store && \
# Cleanup
rm -rf $basename
