#!/bin/bash
# screenpipe — AI that knows everything you've seen, said, or heard
# https://screenpi.pe
# Creates a minimal .app bundle so macOS TCC grants permissions to
# "Screenpipe" rather than Terminal.app.

set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)/Screenpipe.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Creating Screenpipe.app at $APP_DIR ..."

mkdir -p "$MACOS"

# Info.plist — minimal metadata for TCC to identify the app
cat > "$CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>com.screenpipe.local</string>
  <key>CFBundleName</key>
  <string>Screenpipe</string>
  <key>CFBundleExecutable</key>
  <string>screenpipe-wrapper</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSScreenCaptureUsageDescription</key>
  <string>Screenpipe needs screen recording to capture what you see.</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>Screenpipe needs microphone access to capture what you hear.</string>
</dict>
</plist>
PLIST

# The executable just execs the startup script
cat > "$MACOS/screenpipe-wrapper" <<WRAPPER
#!/bin/bash
exec "$SCRIPT_DIR/screenpipe-startup.sh"
WRAPPER

chmod +x "$MACOS/screenpipe-wrapper"

echo "Done! Usage:"
echo "  open $APP_DIR          # start (TCC prompts for Screenpipe, not Terminal)"
echo "  kill \$(pgrep -f 'screenpipe record')  # stop"
