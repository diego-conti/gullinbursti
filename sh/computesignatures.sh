cd `dirname $0`/..
mkdir -p signatures
seq 1 2000 | parallel magma -b d:={} magma/computesignatures.m >/dev/null
