# Media still to capture

V1 is complete — **there are no placeholders on the page**. Every section either
has real media or has none, and nothing reads as unfinished. This file tracks
what would make V2 better.

Two things were removed from the page rather than faked, and two were filled
with the closest real footage available. All of it is listed below.

---

## 1. Removed from the page — no footage exists

These sections previously had a figure pointing at a file that was never shot.
The figures are gone; the text still covers the work.

| Section | File it wanted | What to shoot |
|---|---|---|
| Phase 3 — Brake subsystem | `brake-bench.mp4` | The linear actuator driving the brake cable: extend/retract under serial command, and the Y-bridle pulling at the equalizer. This is a whole completed phase with zero media. |
| Phase 6 — Power distribution | `power-distribution.mp4` | The trunk: master disconnect → main fuse → busbars → the individually fused branches. A slow pan across the finished bay would do it. |
| Phase 7 — Forward / Reverse | `reverse-test.mp4` | The cart shifting direction under firmware control at a standstill, ideally with the relay board in frame. |

To put any of these back, drop the named file into `assets/` and re-add a
figure — the markup pattern is the same as every other video on the page.

## 2. Filled with stand-in footage — worth upgrading

These are real, relevant clips, but not the shot the section actually wants.

| Section | Using now | What would be better |
|---|---|---|
| Phase 2 — Steering | `steering-test.mp4` — the steering circuit (HBS86H driver, controller, motor cable) laid out before install | **The wheels actually turning.** Lock-to-lock and self-centering with the cart on stands, camera low and static. This is the single highest-value clip missing from the site. |
| Phase 8 — Camera subsystem | `camera-bringup.mp4` — the six modules staged on the bench next to the Jetson | The six cameras **mounted on the rail** under the roof lip, and/or a screen capture of all six streams running at once. |
| Software — detection | `detectnet.mp4` — phone footage of a monitor, with visible moire and bezel | A real screen capture taken on the Jetson. Ten seconds of work, and it will look dramatically better. |

## 3. Nice to have

- **A proper `cart-wide` photograph.** The overview currently uses video, which
  is right for the page — but `assets/social-card.jpg` (the link-preview image
  people see when the URL is shared) is a frame grabbed from video. A real
  photo would sharpen the first impression.
- **Detail stills** with no home yet, but worth having: the stepper and belt on
  the steering column, the throttle intercept under the floor, the camera rail
  under the roof lip, and the physical E-stop.
- **The custom PCB.** `cad/Teslacart_kicad/` holds a real KiCad board with
  gerbers, and the site never mentions it. `kicad-cli pcb render` produces a
  clean 3D render with no photography needed.

---

## How to add any of these

```sh
./prep-media.sh --list                              # what is filled vs. missing
./prep-media.sh ~/Desktop/clip.MOV brake-bench      # convert + install
```

Videos are never trimmed unless you pass explicit start/duration. Use
`VIDH=720 CRF=30` in front of the command to keep file size down.
