cask "markdown-viewer" do
  version "1.0.0"
  sha256 :no_check

  # For GitHub Releases (or private tap assets):
  url "https://github.com/jomalaca/markdown-viewer/releases/download/v#{version}/MarkdownViewer-macOS.zip"
  name "Markdown Viewer"
  desc "100% private, local-first Markdown viewer and editor with live GFM, math, and diagrams"
  homepage "https://github.com/jomalaca/markdown-viewer"

  depends_on macos: ">= :ventura"

  app "Markdown Viewer.app"
  binary "#{appdir}/Markdown Viewer.app/Contents/MacOS/markdown-viewer-cli", target: "markdown-viewer"

  postflight do
    # Ensure CLI executable has execution permissions
    set_permissions "#{appdir}/Markdown Viewer.app/Contents/MacOS/markdown-viewer-cli", "0755"
  end

  zap trash: [
    "~/Library/Application Support/MarkdownViewer",
    "~/Library/Preferences/org.markdownviewer.app.plist",
    "~/Library/Saved Application State/org.markdownviewer.app.savedState",
    "~/Library/WebKit/org.markdownviewer.app",
  ]
end
