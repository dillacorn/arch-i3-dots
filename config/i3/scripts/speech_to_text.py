#!/usr/bin/env python3
import os
import re
import subprocess
import pyaudio
import wave
import whisper
import signal

# Updated paths to your lock file
LOCK_FILE = os.path.expanduser("~/.config/i3/scripts/listen.lock")

# Audio configuration
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 16000
CHUNK = 1024
WAVE_OUTPUT_FILENAME = os.path.expanduser("~/.config/i3/scripts/output.wav")

listening_active = False  # Flag to check if listening is still active
transcription_process = None  # To hold the transcription process

# Use the tiny Whisper model for faster processing
model = whisper.load_model("tiny")

def is_listening():
    """Check if the lock file exists (i.e., if listening is active)."""
    return os.path.exists(LOCK_FILE)

def start_listening():
    global listening_active
    stream = None  # Ensure the stream is defined in the wider scope
    listening_active = True  # Mark as listening when starting

    # Create the lock file to indicate that listening is active
    open(LOCK_FILE, 'w').close()

    # Send a dunst notification
    subprocess.run(["dunstify", "Listening Active", "Speech recognition has started."])

    # Initialize PyAudio for recording
    audio = pyaudio.PyAudio()

    try:
        stream = audio.open(format=FORMAT, channels=CHANNELS, rate=RATE, input=True, frames_per_buffer=CHUNK)
        print("Starting continuous listening...")

        frames = []
        while is_listening() and listening_active:
            # Capture audio in chunks for 5 seconds (adjustable)
            for _ in range(0, int(RATE / CHUNK * 5)):  # 5 seconds of audio
                if not listening_active:
                    break
                data = stream.read(CHUNK)
                frames.append(data)

            if not listening_active:
                break

            # Save the recorded data as a WAV file
            with wave.open(WAVE_OUTPUT_FILENAME, 'wb') as wf:
                wf.setnchannels(CHANNELS)
                wf.setsampwidth(audio.get_sample_size(FORMAT))
                wf.setframerate(RATE)
                wf.writeframes(b''.join(frames))

            # Transcribe the WAV file using Whisper
            result = model.transcribe(WAVE_OUTPUT_FILENAME)

            if listening_active:  # Only type if still active
                # Remove punctuation using regex (optional)
                cleaned_text = re.sub(r'[^\w\s]', '', result['text'])
                print(f"Cleaned Transcription: {cleaned_text}")

                # Simulate typing the result using xdotool
                transcription_process = subprocess.Popen(["xdotool", "type", "--delay", "1", cleaned_text])

    except KeyboardInterrupt:
        print("Stopping listening...")

    finally:
        # Stop the stream and terminate PyAudio
        if stream is not None:
            stream.stop_stream()
            stream.close()
        audio.terminate()

def stop_listening():
    """Forcefully stop the listening process and clean up immediately."""
    global listening_active, transcription_process
    listening_active = False  # Mark as not active to stop transcription

    if os.path.exists(LOCK_FILE):
        os.remove(LOCK_FILE)

    # Send a dunst notification
    subprocess.run(["dunstify", "Listening Deactive", "Speech recognition has stopped."])

    # If any transcription process is active, terminate it immediately
    if transcription_process and transcription_process.poll() is None:
        transcription_process.terminate()

    # Forcefully kill any xdotool typing process
    subprocess.run(["pkill", "xdotool"])

    transcription_process = None  # Clear transcription buffer

def toggle_listening():
    """Toggle between starting and stopping the transcription."""
    if is_listening():
        stop_listening()
    else:
        start_listening()

if __name__ == "__main__":
    toggle_listening()
