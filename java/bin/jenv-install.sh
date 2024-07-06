#!/bin/bash
# shellcheck disable=SC2034 # Apparently unused vars are in fact injected into "[...]_PATTERN"

# shellcheck disable=SC2016 # Env vars will be expanded later on via "eval"
TEMURIN_BINS_URL_PATTERN='https://github.com/adoptium/temurin${java_version_maj}-binaries/releases/download/\
jdk-${java_version}/OpenJDK${java_version_maj}U-${java_flavor}_x64_linux_hotspot_${java_version_underscored}.tar.gz'

java_version="$1"
java_flavor="${2:-jdk}"
java_version_maj="$(echo -n "$java_version" | sed -r 's/^([0-9]+).*$/\1/')"
java_version_underscored="${java_version//+/_}"
java_download_url="$(eval echo -n "$TEMURIN_BINS_URL_PATTERN")"

sudo bash -c "curl -sSfL '$java_download_url' | tar -C /opt -xz"
jenv add "/opt/jdk-$java_version"
jenv local "$java_version_maj"
