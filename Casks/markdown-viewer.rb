cask "markdown-viewer" do
  version "1.2.0"
  sha256 "2259af3db6fadbdba2d04ea653e8af56ddb9f94374aab25305790b5d139ee865"

  # For GitHub Releases (or private tap assets):
  url "https://github.com/jomalaca/markdown-viewer/releases/download/v#{version}/MarkdownViewer-macOS.zip"
  name "Markdown Viewer"
  desc "100% private, local-first Markdown viewer and editor with live GFM, math, and diagrams"
  homepage "https://github.com/jomalaca/markdown-viewer"

  depends_on macos: :ventura

  app "Markdown Viewer.app"
  binary "#{appdir}/Markdown Viewer.app/Contents/MacOS/markdown-viewer-cli", target: "markdown-viewer"

  zap trash: [
    "~/Library/Application Support/MarkdownViewer",
    "~/Library/Preferences/org.markdownviewer.app.plist",
    "~/Library/Saved Application State/org.markdownviewer.app.savedState",
    "~/Library/WebKit/org.markdownviewer.app",
  ]
end
