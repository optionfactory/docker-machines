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

# the favicon is a 500x500 png (hscontrol/assets/favicon.png), served at /favicon.ico: found by its IHDR chunk, since
# grep works by lines and the png signature holds a newline; its length is the sum of its chunks up to IEND
ihdr=$(LC_ALL=C grep -obaP 'IHDR\x00\x00\x01\xf4\x00\x00\x01\xf4' /opt/headscale/bin/headscale | cut -d: -f1)
if [[ ! ${ihdr} =~ ^[0-9]+$ ]]; then
    echo "headscale favicon not found exactly once" >&2
    exit 1
fi
icon_start=$((ihdr - 12))
chunk=$((icon_start + 8))
while :; do
    read -r b1 b2 b3 b4 < <(od -An -tu1 -j "${chunk}" -N4 /opt/headscale/bin/headscale)
    chunk_type=$(dd if=/opt/headscale/bin/headscale bs=1 skip=$((chunk + 4)) count=4 status=none)
    chunk=$((chunk + 12 + (b1 << 24 | b2 << 16 | b3 << 8 | b4)))
    [[ ${chunk_type} == IEND ]] && break
done
icon_length=$((chunk - icon_start))
icon_size=$(stat -c %s /build-scripts/branding/access/favicon.png)
if ((icon_size > icon_length)); then
    echo "favicon.png is ${icon_size} bytes, only ${icon_length} available" >&2
    exit 1
fi
{ cat /build-scripts/branding/access/favicon.png; head -c $((icon_length - icon_size)) /dev/zero; } | dd of=/opt/headscale/bin/headscale bs=1 seek="${icon_start}" conv=notrunc status=none

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
