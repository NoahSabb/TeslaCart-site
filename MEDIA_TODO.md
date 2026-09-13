# Media status

**Every file in `~/Desktop/teslacart-media/` is on the site — 28 videos and 2
photos, nothing left over.** This file now tracks open questions and what would
strengthen a future version.

---

## One thing still unresolved

**Phase 9 — which GPS module?** The phase text names a u-blox **NEO-F10N**, but
`all the boards I used in the project layed out` clearly shows a SparkFun
**NEO-M9N** in hand. The part number was left exactly as you wrote it — say
which one is actually on the cart and it's a one-word fix.

## Worth upgrading later

- **`detectnet`** is phone footage of a monitor — visible moire and bezel. A
  screen capture taken on the Jetson would look dramatically better and takes
  seconds.
- **`social-card.jpg`** (the link-preview image when the URL is shared) is a
  frame grabbed from video. A real photograph of the cart would sharpen the
  first impression.
- **The cameras mounted on the cart** — the one shot the build log is explicitly
  waiting on.

## Nice to have

- The stepper and belt drive on the steering column, close up
- The physical E-stop
- A screen capture of all six camera streams running at once
- The Jetson's view during an autonomous run (what the model actually sees)

---

## Adding more

```sh
./prep-media.sh --list                              # filled vs. missing
./prep-media.sh ~/Desktop/clip.MOV brake-bench      # convert + install
```

Videos are never trimmed unless you pass an explicit start/duration. Prefix with
`VIDH=720 CRF=30` for a full-width clip, `VIDH=540 CRF=31` for one that sits in
a side-by-side grid.
