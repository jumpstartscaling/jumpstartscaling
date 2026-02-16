#!/bin/bash
# Convert all .ts and .flv files to .mp4
# Only converts files that haven't been modified in the last 2 minutes to avoid converting active recordings.

cd /home/opc/stream-rec/downloads

# Convert TS
find . -maxdepth 1 -name "*.ts" -mmin +2 -type f | while read ts; do
    mp4="${ts%.ts}.mp4"
    if [ ! -f "$mp4" ]; then
        /usr/local/bin/ffmpeg -i "$ts" -c:v copy -c:a copy -movflags +faststart "$mp4" -y 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "$(date): Converted $ts"
        else
            echo "$(date): Failed to convert $ts"
            rm -f "$mp4" # Cleanup partial file
        fi
    fi
done

# Convert FLV
find . -maxdepth 1 -name "*.flv" -mmin +2 -type f | while read flv; do
    mp4="${flv%.flv}.mp4"
    if [ ! -f "$mp4" ]; then
        /usr/local/bin/ffmpeg -i "$flv" -c:v copy -c:a copy -movflags +faststart "$mp4" -y 2>/dev/null
        if [ $? -eq 0 ]; then
             echo "$(date): Converted $flv"
        else
             echo "$(date): Failed to convert $flv"
             rm -f "$mp4"
        fi
    fi
done
