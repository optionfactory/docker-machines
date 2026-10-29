#!/bin/bash -e

echo "Installing headscale"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 headscale

mkdir -p /opt/headscale/{bin,conf,data,run}
cp /build/headscale-* /opt/headscale/bin/headscale

# The logo and favicon are go:embed files: their lengths live elsewhere in the binary,
# so ours overwrite the originals in place and are padded to the same length.
logo_start=$(LC_ALL=C grep -oba '<svg class="headscale-logo"' /opt/headscale/bin/headscale | cut -d: -f1)
if [[ ! ${logo_start} =~ ^[0-9]+$ ]]; then
    echo "headscale logo not found exactly once" >&2
    exit 1
fi
logo_end=$(tail -c +$((logo_start + 1)) /opt/headscale/bin/headscale | LC_ALL=C grep -oba -m1 '</svg>' | head -1 | cut -d: -f1)
logo_length=$((logo_end + 6))
logo_size=$(stat -c %s /build-scripts/headscale/logo.svg)
if ((logo_size > logo_length)); then
    echo "logo.svg is ${logo_size} bytes, only ${logo_length} available" >&2
    exit 1
fi
{ cat /build-scripts/headscale/logo.svg; head -c $((logo_length - logo_size)) /dev/zero | tr '\0' ' '; } | dd of=/opt/headscale/bin/headscale bs=1 seek="${logo_start}" conv=notrunc status=none

# ico header with four images, the first 64x64
icon_start=$(LC_ALL=C grep -obaP '\x00\x00\x01\x00\x04\x00\x40\x40' /opt/headscale/bin/headscale | cut -d: -f1)
if [[ ! ${icon_start} =~ ^[0-9]+$ ]]; then
    echo "headscale favicon not found exactly once" >&2
    exit 1
fi
icon_length=0
for i in 0 1 2 3; do
    read -r image_size image_offset < <(od -An -tu4 -j $((icon_start + 6 + 16 * i + 8)) -N8 /opt/headscale/bin/headscale)
    if ((image_offset + image_size > icon_length)); then
        icon_length=$((image_offset + image_size))
    fi
done
icon_size=$(stat -c %s /build-scripts/headscale/favicon.ico)
if ((icon_size > icon_length)); then
    echo "favicon.ico is ${icon_size} bytes, only ${icon_length} available" >&2
    exit 1
fi
{ cat /build-scripts/headscale/favicon.ico; head -c $((icon_length - icon_size)) /dev/zero; } | dd of=/opt/headscale/bin/headscale bs=1 seek="${icon_start}" conv=notrunc status=none

chown -R headscale:docker-machines /opt/headscale
chmod 750 /opt/headscale/bin/headscale

# the cli talks to the server over /opt/headscale/run/headscale.sock (unix_socket in config.yaml):
# `docker exec headscale headscale nodes list`
cat <<'EOS' > /usr/local/bin/headscale
#!/bin/bash -e
exec setpriv --reuid=headscale --regid=docker-machines --init-groups --no-new-privs -- /opt/headscale/bin/headscale --config /opt/headscale/conf/config.yaml "$@"
EOS

cat <<'EOS' > /headscale
#!/bin/bash -e
exec /usr/local/bin/headscale serve "$@"
EOS

chmod 755 /usr/local/bin/headscale
chmod 750 /headscale
