cask "markdown-viewer" do
  version "1.6.0"
  sha256 "66680e6336d5a42ad8d1d754b5bf0d2f57808d864b4eed474e1f5503aee88231"

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
