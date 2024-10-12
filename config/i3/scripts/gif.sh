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
PALETTE="/tmp/palette.png"
RAW_OUTPUT="/tmp/raw_output.mkv"

# Check if ffmpeg is already running by checking the PID file
if [ -f "$PIDFILE" ]; then
    FFMPEG_PID=$(cat "$PIDFILE")
    if kill -0 "$FFMPEG_PID" 2>/dev/null; then
        echo "Stopping recording..."
        kill "$FFMPEG_PID"
        rm -f "$PIDFILE"

        echo "Rendering GIF..."
        # Render the gif using the raw recorded video and the generated palette
        ffmpeg -y -i "$RAW_OUTPUT" -i "$PALETTE" -lavfi "fps=20,paletteuse" "$OUTPUT_FILE"
        echo "GIF created: $OUTPUT_FILE"
        
        # Cleanup the temporary files
        rm -f "$RAW_OUTPUT" "$PALETTE"
    else
        echo "No active recording found. Cleaning up PID file."
        rm -f "$PIDFILE"
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
               -t $DURATION -vf "fps=20,palettegen" "$PALETTE"

        # Start recording the raw video
        echo "Recording raw video..."
        ffmpeg -y -f x11grab -video_size "${WIDTH}x${HEIGHT}" \
               -framerate 20 -i "$DISPLAY+$X,$Y" \
               -t $DURATION "$RAW_OUTPUT" &
        
        echo $! > "$PIDFILE"  # Save the PID of the background process

        echo "Recording started. Run the script again to stop and render the GIF."
    else
        echo "No area selected, aborting."
    fi
fi
