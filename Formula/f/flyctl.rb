class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.3.36",
      revision: "d5225007479e8909a8c96685212b1a25e1e7e2eb"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  # Upstream tags versions like `v0.1.92` and `v2023.9.8` but, as of writing,
  # they only create releases for the former and those are the versions we use
  # in this formula. We could omit the date-based versions using a regex but
  # this uses the `GithubLatest` strategy, as the upstream repository also
  # contains over a thousand tags (and growing).
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "dfc8fd0290699af0926bcd182521e1c53d902d02e588a198869630f01cf8400e"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "dfc8fd0290699af0926bcd182521e1c53d902d02e588a198869630f01cf8400e"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "dfc8fd0290699af0926bcd182521e1c53d902d02e588a198869630f01cf8400e"
    sha256 cellar: :any_skip_relocation, sonoma:        "1f571a6ff49722a40e7411b70806bb119d8d07a37f6712faa69ea48349ed0668"
    sha256 cellar: :any_skip_relocation, ventura:       "1f571a6ff49722a40e7411b70806bb119d8d07a37f6712faa69ea48349ed0668"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "544afdc8e35f7b2788c493543c479eede5e03a1e39a3bce1ed68e1365c65cb07"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.buildVersion=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags:), "-tags", "production"

    bin.install_symlink "flyctl" => "fly"

    generate_completions_from_executable(bin/"flyctl", "completion")
    generate_completions_from_executable(bin/"fly", "completion", base_name: "fly")
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("#{bin}/flyctl status 2>&1", 1)
    assert_match "Error: No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end
