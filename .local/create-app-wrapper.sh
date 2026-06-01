#!/bin/bash
# screenpipe — AI that knows everything you've seen, said, or heard
# https://screenpi.pe
# Creates a minimal .app bundle so macOS TCC grants permissions to
# "Screenpipe" rather than Terminal.app.

set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)/Screenpipe.app"
AUDIO_APP_DIR="$(cd "$(dirname "$0")" && pwd)/ScreenpipeAudio.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
AUDIO_CONTENTS="$AUDIO_APP_DIR/Contents"
AUDIO_MACOS="$AUDIO_CONTENTS/MacOS"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------------------------
# Build Screenpipe.app (no audio)
# ---------------------------------------------------------------------------
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

cat > "$MACOS/screenpipe-wrapper" <<WRAPPER
#!/bin/bash
exec "$SCRIPT_DIR/screenpipe-startup.sh"
WRAPPER
chmod +x "$MACOS/screenpipe-wrapper"

# ---------------------------------------------------------------------------
# Build ScreenpipeAudio.app (audio enabled)
# ---------------------------------------------------------------------------
echo "Creating ScreenpipeAudio.app at $AUDIO_APP_DIR ..."
mkdir -p "$AUDIO_MACOS"

cat > "$AUDIO_CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>com.screenpipe.local.audio</string>
  <key>CFBundleName</key>
  <string>ScreenpipeAudio</string>
  <key>CFBundleExecutable</key>
  <string>screenpipe-audio-wrapper</string>
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

cat > "$AUDIO_MACOS/screenpipe-audio-wrapper" <<WRAPPER
#!/bin/bash
exec "$SCRIPT_DIR/screenpipe-startup-audio.sh"
WRAPPER
chmod +x "$AUDIO_MACOS/screenpipe-audio-wrapper"

echo "Done! Usage:"
echo "  open $APP_DIR          # start without audio"
echo "  open $AUDIO_APP_DIR    # start with audio (Whisper)"
echo "  kill \$(pgrep -f 'screenpipe record')  # stop"
echo "  $SCRIPT_DIR/../target/release/screenpipe status  # check status"

# ---------------------------------------------------------------------------
# Add / update aliases in ~/.zshrc (idempotent — replaces existing block)
# ---------------------------------------------------------------------------
ZSHRC="$HOME/.zshrc"
ALIAS_BLOCK="# screenpipe aliases (added by create_wrapper.sh)
sp-start() {
  if pgrep -f 'screenpipe record' >/dev/null; then
    echo \"⚠️  screenpipe is already running (pid \$(pgrep -f 'screenpipe record' | head -1)). Run 'sp-stop' first.\"
    return 1
  fi
  open '$APP_DIR' && echo '✅ screenpipe started (no audio)'
}
sp-start-audio() {
  if pgrep -f 'screenpipe record' >/dev/null; then
    echo \"⚠️  screenpipe is already running (pid \$(pgrep -f 'screenpipe record' | head -1)). Run 'sp-stop' first.\"
    return 1
  fi
  open '$AUDIO_APP_DIR' && echo '✅ screenpipe started (audio + Whisper)'
}
sp-stop() {
  if ! pgrep -f 'screenpipe record' >/dev/null; then
    echo 'ℹ️  screenpipe is not running'
    return 0
  fi
  kill \$(pgrep -f 'screenpipe record') && echo '✅ stopped'
}
alias sp-status='$SCRIPT_DIR/../target/release/screenpipe status'"

if grep -q "screenpipe aliases" "$ZSHRC" 2>/dev/null; then
  # Replace the existing block in-place
  python3 - "$ZSHRC" "$ALIAS_BLOCK" <<'PYEOF'
import sys, re
path, block = sys.argv[1], sys.argv[2]
text = open(path).read()
# Remove old block: from the marker line up to (but not including) the next
# top-level comment, blank line followed by a non-related line, or EOF.
# Match the marker and everything up to a double newline or EOF.
text = re.sub(
    r'\n# screenpipe aliases.*?(?=\n\n|\Z)',
    '',
    text,
    flags=re.DOTALL,
)
text = text.rstrip('\n') + '\n\n' + block + '\n'
open(path, 'w').write(text)
PYEOF
  echo ""
  echo "Updated screenpipe aliases in ~/.zshrc."
else
  printf "\n%s\n" "$ALIAS_BLOCK" >> "$ZSHRC"
  echo ""
  echo "Added screenpipe aliases to ~/.zshrc."
fi
echo "  sp-start        — open Screenpipe.app (no audio)"
echo "  sp-start-audio  — open ScreenpipeAudio.app (Whisper transcription)"
echo "  sp-stop         — kill the running screenpipe process"
echo "  sp-status       — check screenpipe status"
echo "Run 'source ~/.zshrc' (or open a new terminal) to activate them."
