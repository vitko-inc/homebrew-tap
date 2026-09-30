# Updated automatically for each release of https://github.com/vitko-inc/vitko.
class Vitko < Formula
  desc "Command-line tool for Vitko"
  homepage "https://runners.vitko.inc"
  version "0.1.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/vitko-inc/vitko/releases/download/v0.1.1/vitko_darwin_arm64.tar.gz"
      sha256 "9572f9efe2066f946af851b418e71c9c7b0a2ba7b9aa01821e0a42d8abd32de6"
    end
    on_intel do
      url "https://github.com/vitko-inc/vitko/releases/download/v0.1.1/vitko_darwin_amd64.tar.gz"
      sha256 "71af437d6a2c74aa97715ca9da682866559221faa7052e48f77a78284ac51a4d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vitko-inc/vitko/releases/download/v0.1.1/vitko_linux_arm64.tar.gz"
      sha256 "50c7569643981363ea2a495745e18686b95e55423ee64e1ea965758db025f464"
    end
    on_intel do
      url "https://github.com/vitko-inc/vitko/releases/download/v0.1.1/vitko_linux_amd64.tar.gz"
      sha256 "87ee1001c1c43a713ab4ff135fb47c31de832ffaf4fd9609d0bae0191200268b"
    end
  end

  def install
    bin.install "vitko"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vitko version --output text")
  end
end
