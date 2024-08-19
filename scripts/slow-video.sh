#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input_file N"
    exit 1
fi

INPUT_FILE=$1
N=$2
BASENAME=$(basename "$INPUT_FILE" .mp4)
OUTPUT_FILE="${BASENAME}_output.mp4"

# Slow down the video and audio without preserving pitch
ffmpeg -i "$INPUT_FILE" -vf "setpts=${N}*PTS" -af "asetrate=44100*${N},aresample=44100" "$OUTPUT_FILE"

echo "Output file: $OUTPUT_FILE"
