#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2026 The GarudaPanel Authors
#
# GarudaPanel installer (all-in-one mode).
#
#   curl -fsSL https://raw.githubusercontent.com/Nizwarax/garudapanel-installer/main/garudapanel-installer.sh | sudo bash
#   curl -fsSL https://raw.githubusercontent.com/Nizwarax/garudapanel-installer/main/garudapanel-installer.sh | sudo bash -s -- --check
#   sudo ./install.sh --bundle garudapanel-<version>-linux-<arch>.tar.gz
#
# Online, it downloads a release from this GitHub mirror and
# installs it only when the Ed25519 signature of its SHA256SUMS verifies
# with the key below and the bundle matches SHA256SUMS. With --bundle it
# installs a local bundle (offline; SHA256SUMS, and SHA256SUMS.sig when the
# bundle is a release, must be next to it). Either way the pre-install
# check runs first: problems stop the installation, warnings are shown
# and must be accepted. Running it again upgrades in place and keeps data.
set -euo pipefail
umask 022

if [ -n "${GARUDAPANEL_RELEASES:-}" ]; then
  RELEASES=${GARUDAPANEL_RELEASES%/}
  LATEST_URL="$RELEASES/LATEST"
else
  RELEASES=https://github.com/Nizwarax/garudapanel-installer/releases/download
  LATEST_URL=https://github.com/Nizwarax/garudapanel-installer/releases/latest/download/LATEST
fi

# The release signing key (Ed25519), SHA-256 of the key:
# 43db9c44fc57719f4a42dc3842500cac369233206b7752f3e13be002b1f74f89
RELEASE_KEY='-----BEGIN PUBLIC KEY-----
MCowBQYDK2VwAyEA2lNiHb7tt0iH7aWBWgnWqFGHe9fBTpmSa8hm9P0cG6I=
-----END PUBLIC KEY-----'

die() {
  echo "install.sh: $*" >&2
  exit 1
}
say() { echo "==> $*"; }

usage() {
  cat <<'EOF'
Usage: install.sh [--version X.Y.Z | --bundle FILE.tar.gz] [--check] [--yes] [options]

  --version X.Y.Z      install this release (default: the latest)
  --bundle FILE        install a local bundle instead of downloading one
  --check              only run the pre-install check
  --yes                continue after warnings without asking

Options of the installation:
  -panel-port N        HTTPS port of the panel (default 8443)
  -names a,b           extra DNS names for the panel certificate
  -ips x,y             extra IP addresses for the panel certificate
  -admin-user NAME     first administrator (default admin)
  -admin-email EMAIL   email of the first administrator
  -no-firewall         do not open the panel port in firewalld/ufw
EOF
}

# fetch URL FILE: HTTPS only, no redirects to plain HTTP.
fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --proto '=https' --proto-redir '=https' --retry 3 -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -q --https-only -O "$2" "$1"
  else
    die "curl or wget is required to download GarudaPanel"
  fi
}

# verify_signature SUMS SIG: the release key must have signed SUMS.
verify_signature() {
  command -v openssl >/dev/null 2>&1 || die "openssl is required to verify the release signature"
  printf '%s\n' "$RELEASE_KEY" >"$work/release.pub"
  openssl pkeyutl -verify -pubin -inkey "$work/release.pub" -rawin -in "$1" -sigfile "$2" >/dev/null 2>&1 ||
    die "the signature of $(basename "$1") does not verify: the download is not an official GarudaPanel release"
}

# verify_sum FILE SUMS: FILE must be listed in SUMS with its SHA-256.
verify_sum() {
  local name want got
  name=$(basename "$1")
  want=$(awk -v n="$name" '$2 == n || $2 == "*" n { print $1; exit }' "$2")
  [ -n "$want" ] || die "$name is not listed in $(basename "$2")"
  got=$(sha256sum "$1" | awk '{ print $1 }')
  [ "$got" = "$want" ] || die "checksum mismatch for $name (expected $want, got $got)"
}

# Everything runs from main, called on the last line: a download cut short
# by the network (curl | bash) defines functions only and runs nothing.
main() {
  bundle=""
  version=""
  check_only=0
  assume_yes=0
  pass=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --bundle) [ $# -ge 2 ] || die "--bundle needs a file"; bundle=$2; shift 2 ;;
      --bundle=*) bundle=${1#*=}; shift ;;
      --version) [ $# -ge 2 ] || die "--version needs a version"; version=${2#v}; shift 2 ;;
      --version=*) version=${1#*=}; version=${version#v}; shift ;;
      --check) check_only=1; shift ;;
      --yes | -y) assume_yes=1; shift ;;
      -h | --help) usage; exit 0 ;;
      *) pass+=("$1"); shift ;;
    esac
  done

  [ "$(id -u)" -eq 0 ] || die "run as root (for example: sudo bash garudapanel-installer.sh)"
  [ "$(uname -s)" = Linux ] || die "GarudaPanel runs on Linux only"
  case "$(uname -m)" in
    x86_64 | amd64) arch=amd64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *) die "unsupported CPU architecture: $(uname -m) (x86-64 and arm64 are supported)" ;;
  esac
  for tool in tar gzip sha256sum awk mktemp; do
    command -v "$tool" >/dev/null 2>&1 || die "$tool is required"
  done
  [ -z "$bundle" ] || [ -z "$version" ] || die "--bundle and --version cannot be used together"

  # Work where executing is allowed (/tmp is often mounted noexec).
  work=$(mktemp -d /var/lib/.garudapanel-install.XXXXXX)
  trap 'rm -rf "$work"' EXIT

  if [ -n "$bundle" ]; then
    [ -f "$bundle" ] || die "bundle not found: $bundle"
    name=$(basename "$bundle")
    case "$name" in
      garudapanel-*-linux-"$arch".tar.gz) ;;
      *) die "$name is not a GarudaPanel bundle for linux-$arch" ;;
    esac
    sums="$(dirname "$bundle")/SHA256SUMS"
    [ -f "$sums" ] || die "SHA256SUMS not found next to the bundle"
    if [ -f "$sums.sig" ]; then
      verify_signature "$sums" "$sums.sig"
      say "$name: signed release, signature verified"
    else
      echo "install.sh: warning: $name is not signed (a development build)" >&2
    fi
    verify_sum "$bundle" "$sums"
  else
    if [ -z "$version" ]; then
      fetch "$LATEST_URL" "$work/LATEST" || die "cannot reach $LATEST_URL (check the server's internet access)"
      version=$(tr -d '[:space:]' <"$work/LATEST")
    fi
    [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]] || die "invalid version \"$version\""
    name="garudapanel-$version-linux-$arch.tar.gz"
    say "downloading GarudaPanel $version ($arch)"
    fetch "$RELEASES/$version/SHA256SUMS" "$work/SHA256SUMS" || die "release $version not found"
    fetch "$RELEASES/$version/SHA256SUMS.sig" "$work/SHA256SUMS.sig" || die "release $version has no signature"
    verify_signature "$work/SHA256SUMS" "$work/SHA256SUMS.sig"
    fetch "$RELEASES/$version/$name" "$work/$name" || die "release $version has no bundle for $arch"
    verify_sum "$work/$name" "$work/SHA256SUMS"
    say "signature and checksum verified"
    bundle="$work/$name"
  fi

  tar -xzf "$bundle" -C "$work" --no-same-owner
  dir="$work/${name%.tar.gz}"
  [ -x "$dir/bin/garudapanel" ] || die "unexpected bundle layout (no bin/garudapanel)"

  # Pre-install check: 0 ready, 2 ready with warnings, anything else stops.
  set +e
  "$dir/bin/garudapanel" preflight "${pass[@]}"
  status=$?
  set -e
  if [ "$check_only" -eq 1 ]; then
    exit "$status"
  fi
  case "$status" in
    0) ;;
    2)
      if [ "$assume_yes" -ne 1 ]; then
        if [ -r /dev/tty ] && [ -w /dev/tty ]; then
          printf 'Continue with the installation despite the warnings above? [y/N] ' >/dev/tty
          read -r answer </dev/tty || answer=""
          case "$answer" in
            y | Y | yes | YES | ya | Ya) ;;
            *) die "installation cancelled" ;;
          esac
        else
          die "the check above found warnings; run again with --yes to install anyway"
        fi
      fi
      ;;
    *) die "the server is not ready for GarudaPanel: fix the problems above and run the installer again" ;;
  esac

  "$dir/bin/garudapanel" install -bundle "$dir" "${pass[@]}"
}

main "$@"
