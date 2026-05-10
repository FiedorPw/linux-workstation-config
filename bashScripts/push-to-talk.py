#!/usr/bin/env python3
"""
Push-to-talk speech-to-text using whisper.cpp with Vulkan on Wayland.

Hold Mac F4 (Launchpad) to record, release to transcribe and copy to clipboard.
Keyd remaps dashboard → F20, so we listen for KEY_F20.
Model loading starts on key press (overlaps with recording time).

Usage:
    ./push-to-talk.py [--lang pl|en|auto]

Requires: python3-evdev, pw-record, wl-copy, notify-send, whisper-cli
User must be in 'input' group.
"""

import argparse
import asyncio
import os
import signal
import subprocess
import sys
import tempfile
import threading

import evdev
from evdev import ecodes

WHISPER_CLI = os.path.expanduser("~/.local/bin/whisper-cli")
MODELS_DIR = os.path.expanduser("~/Applications/whisper.cpp/models")
MODEL_PATH = os.path.join(MODELS_DIR, "ggml-large-v3-turbo.bin")

SAMPLE_RATE = 16000


NOTIFY_ID = "8492"  # fixed ID so notifications replace each other


def notify(title, body="", urgency="normal"):
    subprocess.Popen(
        ["notify-send", "-r", NOTIFY_ID, "-u", urgency, "-a", "Push-to-Talk", title, body],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )


def find_keyboards():
    keyboards = []
    for path in evdev.list_devices():
        dev = evdev.InputDevice(path)
        caps = dev.capabilities()
        if ecodes.EV_KEY in caps:
            keys = caps[ecodes.EV_KEY]
            if ecodes.KEY_A in keys and ecodes.KEY_Z in keys:
                keyboards.append(dev)
    return keyboards


def copy_to_clipboard(text):
    proc = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
    proc.communicate(text.encode())


class PushToTalk:
    def __init__(self, lang="auto"):
        self.lang = lang
        self.pressed_keys = set()
        self.recording = False
        self.rec_process = None
        self.tmp_file = None
        self.transcribe_thread = None

    def is_hotkey_held(self):
        return ecodes.KEY_F19 in self.pressed_keys

    def _preload_model(self):
        """Read model file into OS page cache so whisper-cli starts faster."""
        try:
            with open(MODEL_PATH, "rb") as f:
                while f.read(1024 * 1024):
                    pass
        except Exception:
            pass

    def start_recording(self):
        if self.recording:
            return
        # Preload model into page cache while recording
        threading.Thread(target=self._preload_model, daemon=True).start()
        self.tmp_file = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
        self.tmp_file.close()
        self.rec_process = subprocess.Popen(
            ["pw-record", "--rate", str(SAMPLE_RATE), "--channels", "1",
             "--format", "s16", self.tmp_file.name],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        self.recording = True
        notify("Recording...", "Release F4 (Launchpad) to stop")
        print("Recording...")

    def stop_recording(self):
        if not self.recording:
            return
        self.recording = False
        if self.rec_process:
            self.rec_process.send_signal(signal.SIGINT)
            self.rec_process.wait(timeout=5)
            self.rec_process = None
        print("Stopped. Transcribing...")

        audio_path = self.tmp_file.name
        # Run transcription in a thread so we don't block key events
        self.transcribe_thread = threading.Thread(
            target=self._transcribe, args=(audio_path,), daemon=True)
        self.transcribe_thread.start()

    def _transcribe(self, audio_path):
        try:
            cmd = [WHISPER_CLI, "-m", MODEL_PATH, "-f", audio_path, "-np", "-nt"]
            if self.lang != "auto":
                cmd += ["-l", self.lang]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            text = result.stdout.strip()
            lines = [line.strip() for line in text.splitlines() if line.strip()]
            text = " ".join(lines)
            if text:
                notify("Copied to clipboard", text[:200])
                copy_to_clipboard(text)
                print(f"Copied: {text}")
            else:
                print("No speech detected")
                notify("No speech detected", urgency="low")
        except subprocess.TimeoutExpired:
            print("Whisper timed out")
            notify("Transcription timed out", urgency="critical")
        except Exception as e:
            print(f"Error: {e}")
            notify(f"Error: {e}", urgency="critical")
        finally:
            try:
                os.unlink(audio_path)
            except OSError:
                pass

    def handle_event(self, event):
        if event.type != ecodes.EV_KEY:
            return

        key = event.code
        value = event.value  # 1=press, 0=release, 2=hold/repeat

        if value == 1:
            self.pressed_keys.add(key)
        elif value == 0:
            self.pressed_keys.discard(key)

        if self.is_hotkey_held() and not self.recording:
            self.start_recording()
        elif not self.is_hotkey_held() and self.recording:
            self.stop_recording()


async def main():
    parser = argparse.ArgumentParser(description="Push-to-talk whisper transcription")
    parser.add_argument("--lang", default="auto",
                        help="Language code (e.g. pl, en, de) or 'auto' (default: auto)")
    args = parser.parse_args()

    if not os.path.exists(MODEL_PATH):
        print(f"Model not found: {MODEL_PATH}")
        print("Download: bash ~/Applications/whisper.cpp/models/download-ggml-model.sh large-v3-turbo")
        sys.exit(1)

    if not os.path.exists(WHISPER_CLI):
        print(f"whisper-cli not found at {WHISPER_CLI}")
        sys.exit(1)

    keyboards = find_keyboards()
    if not keyboards:
        print("No keyboards found. Are you in the 'input' group? (relogin after usermod)")
        sys.exit(1)

    print(f"Model: {MODEL_PATH}")
    print(f"Language: {args.lang}")
    print(f"Keyboards: {', '.join(kb.name for kb in keyboards)}")
    print(f"Hotkey: F4/Launchpad (hold to record, release to transcribe)")
    print("Ready. Press Ctrl+C to quit.\n")

    ptt = PushToTalk(args.lang)

    async def read_device(device):
        try:
            async for event in device.async_read_loop():
                ptt.handle_event(event)
        except OSError:
            pass

    tasks = [asyncio.create_task(read_device(kb)) for kb in keyboards]

    try:
        await asyncio.gather(*tasks)
    except asyncio.CancelledError:
        pass


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nBye.")
