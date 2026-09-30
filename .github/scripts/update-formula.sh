#!/usr/bin/env bash
# Writes Formula/vitko.rb for a vitko release, after checking the Sigstore
# signature of the release's checksums.txt.
# Usage: update-formula.sh [TAG]   (default: the latest release)
set -euo pipefail

repo="vitko-inc/vitko"
tag="${1:-}"
if [ -z "$tag" ]; then
	tag=$(gh release view --repo "$repo" --json tagName --jq .tagName)
fi
version="${tag#v}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
gh release download "$tag" --repo "$repo" --dir "$tmp" --pattern checksums.txt --pattern checksums.txt.sigstore.json
cosign verify-blob \
	--bundle "$tmp/checksums.txt.sigstore.json" \
	--certificate-identity "https://github.com/$repo/.github/workflows/release.yml@refs/tags/$tag" \
	--certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
	"$tmp/checksums.txt"

sum() {
	local s
	s=$(awk -v f="vitko_$1.tar.gz" '$2 == f { print $1 }' "$tmp/checksums.txt")
	[ -n "$s" ] || { echo "no checksum for vitko_$1.tar.gz" >&2; exit 1; }
	echo "$s"
}
url="https://github.com/$repo/releases/download/$tag"

mkdir -p Formula
cat >Formula/vitko.rb <<RUBY
# Updated automatically for each release of https://github.com/$repo.
class Vitko < Formula
  desc "Command-line tool for Vitko"
  homepage "https://runners.vitko.inc"
  version "$version"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "$url/vitko_darwin_arm64.tar.gz"
      sha256 "$(sum darwin_arm64)"
    end
    on_intel do
      url "$url/vitko_darwin_amd64.tar.gz"
      sha256 "$(sum darwin_amd64)"
    end
  end

  on_linux do
    on_arm do
      url "$url/vitko_linux_arm64.tar.gz"
      sha256 "$(sum linux_arm64)"
    end
    on_intel do
      url "$url/vitko_linux_amd64.tar.gz"
      sha256 "$(sum linux_amd64)"
    end
  end

  def install
    bin.install "vitko"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vitko version --output text")
  end
end
RUBY
echo "Formula/vitko.rb: $tag"
