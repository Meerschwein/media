#! /usr/bin/env nix-shell
#! nix-shell --pure -i bash -p ffmpeg_7-full

FILE=big-buck-bunny.mp4

OUTDIR=out

FILE_YUV=$FILE.yuv

FILE_VERYHIGH=$OUTDIR/$FILE-VERYHIGH.mp4
FILE_HIGH=$OUTDIR/$FILE-HIGH.mp4
FILE_MEDIUM=$OUTDIR/$FILE-MEDIUM.mp4
FILE_LOW=$OUTDIR/$FILE-LOW.mp4

BITRATE_VERYHIGH=5000k
BITRATE_HIGH=3000k
BITRATE_MEDIUM=1500k
BITRATE_LOW=500k

rm $OUTDIR/*

# decompress
ffmpeg -y -i $FILE $FILE_YUV

# ecnode at 4 qualities
PRESET=fast
ffmpeg -s 1920x1080 -pix_fmt yuv420p -i $FILE_YUV \
    -c:v libx264 -preset $PRESET -b:v $BITRATE_VERYHIGH $FILE_VERYHIGH \
    -c:v libx264 -preset $PRESET -b:v $BITRATE_HIGH $FILE_HIGH \
    -c:v libx264 -preset $PRESET -b:v $BITRATE_MEDIUM $FILE_MEDIUM \
    -c:v libx264 -preset $PRESET -b:v $BITRATE_LOW $FILE_LOW

# package using dash
ffmpeg \
    -i $FILE_VERYHIGH \
    -i $FILE_HIGH \
    -i $FILE_MEDIUM \
    -i $FILE_LOW \
    -map 0:v -b:v:0 $BITRATE_VERYHIGH \
    -map 1:v -b:v:1 $BITRATE_HIGH \
    -map 2:v -b:v:2 $BITRATE_MEDIUM \
    -map 3:v -b:v:3 $BITRATE_LOW \
    -c copy -f dash $OUTDIR/manifest.mpd
