cask "markdown-viewer" do
  version "1.4.0"
  sha256 "8a1341575911e188e550cffd5f273eb6e9b962469bb6868c7ffe9fb78b34311c"

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
