#!/usr/bin/env python3
import os
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

# Whisper model for transcribing speech
model = whisper.load_model("medium") # option include tiny, base, small, medium & large 

def is_listening():
    """Check if the lock file exists (i.e., if listening is active)."""
    return os.path.exists(LOCK_FILE)

def start_listening():
    """Start recording audio from the microphone."""
    # Clear the previous output file
    if os.path.exists(WAVE_OUTPUT_FILENAME):
        os.remove(WAVE_OUTPUT_FILENAME)

    # Create the lock file to indicate that listening is active
    open(LOCK_FILE, 'w').close()

    # Send a dunst notification that recording has started
    subprocess.run(["dunstify", "Listening Active", "Recording your speech..."])

    # Initialize PyAudio for recording
    audio = pyaudio.PyAudio()

    try:
        stream = audio.open(format=FORMAT, channels=CHANNELS, rate=RATE, input=True, frames_per_buffer=CHUNK)

        frames = []
        while is_listening():
            data = stream.read(CHUNK)
            frames.append(data)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'stream' in locals():
            stream.stop_stream()
            stream.close()
        audio.terminate()

        # Save the recorded data as a WAV file
        with wave.open(WAVE_OUTPUT_FILENAME, 'wb') as wf:
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(audio.get_sample_size(FORMAT))
            wf.setframerate(RATE)
            wf.writeframes(b''.join(frames))

def stop_listening_and_transcribe():
    """Stop recording, transcribe the audio, and copy the transcription to clipboard."""
    if os.path.exists(LOCK_FILE):
        os.remove(LOCK_FILE)

    subprocess.run(["dunstify", "Listening Deactive", "Transcribing your speech..."])

    if os.path.exists(WAVE_OUTPUT_FILENAME):
        print(f"Transcribing file: {WAVE_OUTPUT_FILENAME}")
        result = model.transcribe(WAVE_OUTPUT_FILENAME)
        transcription = result['text']
        print(f"Transcription: {transcription}")

        # Write transcription to /tmp for debugging
        with open("/tmp/transcription.txt", "w") as f:
            f.write(transcription)

        # Copy the transcription to the clipboard using os.popen and xclip
        try:
            with os.popen('xclip -selection clipboard', 'w') as clipboard:
                clipboard.write(transcription)
            print("Transcription copied to clipboard.")
        except Exception as e:
            print(f"Failed to copy to clipboard: {e}")
    else:
        print("Error: No audio file found to transcribe!")

def toggle_listening():
    """Toggle between starting and stopping the transcription."""
    if is_listening():
        stop_listening_and_transcribe()
    else:
        start_listening()

if __name__ == "__main__":
    toggle_listening()
