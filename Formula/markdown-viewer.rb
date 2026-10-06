class MarkdownViewer < Formula
  desc "100% private, local-first Markdown viewer and editor with live GFM, math, and diagrams"
  homepage "https://github.com/jomalaca/markdown-viewer"
  url "https://github.com/jomalaca/markdown-viewer/releases/download/v1.6.0/markdown-viewer-1.6.0.tar.gz"
  sha256 "PENDING_BUILD_SHA"
  license "MIT"
  head "https://github.com/jomalaca/markdown-viewer.git", branch: "main"

  depends_on :macos
  depends_on xcode: ["14.0", :build]

  def install
    system "./scripts/build_macos.sh"
    prefix.install "build/Markdown Viewer.app"
    bin.write_exec_script "#{prefix}/Markdown Viewer.app/Contents/MacOS/markdown-viewer-cli"
    mv bin/"markdown-viewer-cli", bin/"markdown-viewer"
  end

  def caveats
    <<~EOS
      Markdown Viewer.app was installed to:
        #{prefix}/Markdown Viewer.app

      To link it to /Applications for Spotlight and Launchpad:
        ln -s "#{prefix}/Markdown Viewer.app" /Applications/

      You can launch it from your terminal at any time with:
        markdown-viewer [file.md]
    EOS
  end

  test do
    system "#{bin}/markdown-viewer", "--version"
  end
end
