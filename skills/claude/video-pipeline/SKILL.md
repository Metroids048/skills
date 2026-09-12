---
name: video-pipeline
description: Drive a safe video workflow from topic and Mandarin script through storyboard, assets, render, and media QA, including duration, streams, captions, keyframes, and playback checks.
---

# Video Pipeline

The pipeline is `topic → Mandarin voice script → storyboard → assets → visual production (Remotion/HyperFrames/FFmpeg) → render → QA`. A finished script is not a finished video.

## Required render QA

Run `scripts/verify-video.ps1 -Path <file>` after rendering. Confirm the file exists, ffprobe can parse it, duration is positive and expected, video and (when required) audio streams exist, render logs contain no errors, captions stay inside a safe area, key frames are present, and the file is playable. Check basic audio/video sync and state any tolerance used.

Use synthetic media or local fixtures for tests. Do not upload private media or expose credentials. If any check fails, report `NOT DONE` with the exact evidence path.
