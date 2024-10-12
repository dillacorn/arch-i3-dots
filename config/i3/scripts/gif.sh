#!/bin/bash

# Define the output directory
OUTPUT_DIR="$HOME/Videos"

# Generate a filename with date and time (e.g., gif_2024-09-21_20-23-23.gif)
FILENAME="gif_$(date +'%Y-%m-%d_%H-%M-%S').gif"
OUTPUT_FILE="$OUTPUT_DIR/$FILENAME"

# Set max duration (60 seconds)
DURATION=60

# Define the location of the PID file
PIDFILE="/tmp/ffmpeg_recording.pid"

# Check if ffmpeg is already running by checking for the PID file
if [ -f "$PIDFILE" ]; then
    # Read the PID from the file and stop the recording
    FFMPEG_PID=$(cat "$PIDFILE")
    if [ -n "$FFMPEG_PID" ] && kill -0 "$FFMPEG_PID" 2>/dev/null; then
        echo "Stopping recording and saving as $OUTPUT_FILE..."
        kill "$FFMPEG_PID"
        rm -f "$PIDFILE"
    else
        echo "No recording is currently in progress."
        rm -f "$PIDFILE" # Clean up stale PID file
    fi
else
    # Use slop to select screen area for recording
    read -r GEOMETRY < <(slop --format "%x %y %w %h")

    if [ -n "$GEOMETRY" ]; then
        # Split the geometry into separate variables
        X=$(echo $GEOMETRY | awk '{print $1}')
        Y=$(echo $GEOMETRY | awk '{print $2}')
        WIDTH=$(echo $GEOMETRY | awk '{print $3}')
        HEIGHT=$(echo $GEOMETRY | awk '{print $4}')

        # Generate a color palette first
        echo "Generating palette..."
        ffmpeg -y -f x11grab -video_size "${WIDTH}x${HEIGHT}" \
               -framerate 20 -i "$DISPLAY+$X,$Y" \
               -t $DURATION -vf "fps=20,palettegen" palette.png

        # Start recording and save the PID to the PID file
        echo "Creating GIF..."
        ffmpeg -y -f x11grab -video_size "${WIDTH}x${HEIGHT}" \
               -framerate 20 -i "$DISPLAY+$X,$Y" \
               -t $DURATION -i palette.png -lavfi "fps=20,paletteuse" "$OUTPUT_FILE" &

        # Save the PID of the ffmpeg process
        echo $! > "$PIDFILE"
        
        echo "Recording... Run the script again to stop it."
    else
        echo "No area selected, aborting."
    fi
fi
