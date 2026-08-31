# assets/ — drop your photos and videos here

**How this works:** every media slot on the site already points at a file in
this folder. If the file is here, the page shows it. If it isn't here yet, the
page shows a labeled dashed placeholder box instead. Nothing breaks, and
nothing in `index.html` ever needs editing.

So adding media is one step:

> **Name the file exactly as listed below, put it in this folder, done.**

Names are case-sensitive and the extension matters (GitHub Pages is picky in a
way your Mac is not — `Hero.MP4` will *not* work where `hero.mp4` is expected).

## The files

| Filename | Type | Where it lands | What it should show |
|---|---|---|---|
| `hero.mp4` | video | Hero, top of page | The cart driving — under its own control, or Xbox-controller driving until autonomy footage exists. Autoplays muted on a loop, so keep it short (5–20 s). |
| `hero-poster.jpg` | image | Hero | Still frame shown before the video plays: the full cart with the camera rail visible. |
| `cart-wide.jpg` | image | Overview | Wide shot of the finished cart — camera rail under the roof, electronics visible. **Also used as the social link-preview image**, so pick a good one. |
| `wiring-diagram.png` | image | Hardware | PNG export of `TeslaCart/testlacartschematic.drawio` (open at app.diagrams.net → File → Export as → PNG, 2× zoom). |
| `electronics-closeup.jpg` | image | Hardware | Close-up of the Arduino, relay board, motor drivers, and busbars. |
| `detectnet.jpg` | image | Software | Screenshot of the Jetson running live object detection with bounding boxes. |
| `steering-test.mp4` | video | Build log, Phase 2 | Wheels turning lock-to-lock / self-centering on stands. |
| `brake-bench.mp4` | video | Build log, Phase 3 | Brake actuator bench test — variable-speed extend/retract over serial. |
| `drive-test.mp4` | video | Build log, Phase 5 | Throttle or full controller-drive clip on the ground. |
| `camera-mount-cad.png` | image | Build log, Phase 8 | CAD render of the camera housing / rail mount. |

You can add them one at a time in any order — each slot flips from placeholder
to real media on its own as soon as its file appears.

## The easy way: `../prep-media.sh`

From the repo root, one command per file — it picks the right settings, names
the output correctly, and drops it in here:

```sh
./prep-media.sh ~/Desktop/teslacart-media/wide-shot.HEIC cart-wide
./prep-media.sh ~/Desktop/teslacart-media/steering.MOV steering-test
./prep-media.sh --list                      # what's filled vs. still missing
```

Trim while converting (start time, then seconds) and reshape the clip:

```sh
./prep-media.sh clip.MOV hero 00:00:04 12   # 12 seconds starting at 0:04
./prep-media.sh --speed 2 bench.MOV brake-bench    # 2x faster
./prep-media.sh --speed 0.5 sweep.MOV steering-test  # slow motion
./prep-media.sh --boomerang sweep.MOV hero 0 4     # forward+back, seamless loop
```

Point it at a video when an image slot is expected and it grabs a still frame
instead — that's how `hero-poster.jpg` gets made, so you never have to shoot one.

## Doing it by hand instead

Phone media usually isn't web-ready. iPhone photos are `.HEIC` and videos are
`.MOV`; browsers show neither. Convert first:

```sh
# iPhone photo (.HEIC) -> .jpg, resized to a sensible width
sips -s format jpeg -Z 2000 IMG_1234.HEIC --out assets/cart-wide.jpg

# any video (.MOV, .mp4 from a drone, screen recording) -> web-friendly .mp4
ffmpeg -i IMG_5678.MOV -vf "scale=-2:1080" -c:v libx264 -crf 24 \
       -preset slow -pix_fmt yuv420p -an assets/hero.mp4
```

`-an` drops the audio track — every video on the page is muted anyway, and it
saves space. For the hero loop especially, trim to the good 5–20 seconds
(`-ss 00:00:04 -t 12` before `-i`), since it downloads as soon as the page opens.

Rules of thumb: images 1600–2000 px wide, videos H.264 MP4 at 1080p or less and
ideally under ~10 MB each. GitHub Pages serves these as plain static files with
no streaming, so a 200 MB clip means a 200 MB download for every visitor.

## Checking your work

Open `index.html` in a browser. Any slot still showing a dashed box tells you
its exact expected filename right there in the box — that's your to-do list.
