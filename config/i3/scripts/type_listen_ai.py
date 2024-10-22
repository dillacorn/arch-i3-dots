#!/usr/bin/env python3
import os
import re
import subprocess
import pyaudio
import wave
import whisper

# Updated paths to your lock file
LOCK_FILE = os.path.expanduser("~/.config/i3/scripts/listen.lock")

# Audio configuration
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 16000
CHUNK = 1024
WAVE_OUTPUT_FILENAME = os.path.expanduser("~/.config/i3/scripts/output.wav")

process = None

# Use the tiny Whisper model for faster processing
model = whisper.load_model("tiny")

def is_listening():
    """Check if the lock file exists (i.e., if listening is active)."""
    return os.path.exists(LOCK_FILE)

def start_listening():
    global process
    stream = None  # Ensure the stream is defined in the wider scope

    # Create the lock file to indicate that listening is active
    open(LOCK_FILE, 'w').close()

    # Send a dunst notification
    subprocess.run(["dunstify", "Listening Active", "Speech recognition has started."])

    # Initialize PyAudio for recording
    audio = pyaudio.PyAudio()

    try:
        stream = audio.open(format=FORMAT, channels=CHANNELS, rate=RATE, input=True, frames_per_buffer=CHUNK)
        print("Starting continuous listening...")

        while is_listening():
            frames = []

            # Capture audio in chunks for 5 seconds (adjustable)
            for _ in range(0, int(RATE / CHUNK * 5)):  # 5 seconds of audio
                data = stream.read(CHUNK)
                frames.append(data)

            # Save the recorded data as a WAV file
            wf = wave.open(WAVE_OUTPUT_FILENAME, 'wb')
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(audio.get_sample_size(FORMAT))
            wf.setframerate(RATE)
            wf.writeframes(b''.join(frames))
            wf.close()

            # Transcribe the WAV file using Whisper
            result = model.transcribe(WAVE_OUTPUT_FILENAME)

            # Remove punctuation using regex
            cleaned_text = re.sub(r'[^\w\s]', '', result['text'])
            print(f"Cleaned Transcription: {cleaned_text}")

            # Simulate typing the result using xdotool
            subprocess.run(["xdotool", "type", "--delay", "1", cleaned_text])

    except KeyboardInterrupt:
        print("Stopping listening...")

    finally:
        # Stop the stream and terminate PyAudio
        if stream is not None:
            stream.stop_stream()
            stream.close()
        audio.terminate()

def stop_listening():
    """Stop the listening process and clean up."""
    if os.path.exists(LOCK_FILE):
        os.remove(LOCK_FILE)

    # Send a dunst notification
    subprocess.run(["dunstify", "Listening Deactive", "Speech recognition has stopped."])

def toggle_listening():
    """Toggle between starting and stopping the transcription."""
    if is_listening():
        stop_listening()
    else:
        start_listening()

if __name__ == "__main__":
    toggle_listening()
