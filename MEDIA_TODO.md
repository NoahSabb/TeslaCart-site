# Media status

**Every file in `~/Desktop/teslacart-media/` is on the site — 28 videos and 2
photos, nothing left over.** This file now tracks open questions and what would
strengthen a future version.

---

## Open questions — text and footage disagree

These are factual claims on a public page, so they're left as-is until you say
which is right.

**1. Phase 10 — Autonomy.** The phase text says data collection hasn't started
("collection starts once the cameras are mounted... then fine-tune, deploy, and
layer in the safety override"), but `sped up full self driving test drive
(point A to point B)` is placed there and shows the cart driving itself. Either
the clip is something other than closed-loop autonomy, or the phase text is
stale and the status should move off *In progress*.

**2. The safety override.** Same conflict: Phase 10 lists layering in the
override as future work, but `Safety brake override test` is placed under the
Safety override layer section. The caption was deliberately written as "a person
steps into the cart's path and the brake fires" — it does **not** claim the
detector triggered it, because that can't be told from the footage. If the
detector fired it, say so and the caption can be strengthened.

**3. Phase 9 — GPS module.** The phase text says a u-blox **NEO-F10N** is on
order, but `all the boards I used in the project layed out` clearly shows a
SparkFun **NEO-M9N** already in hand. Which is it, and has it moved past
"ordered"?

**4. Phase 8 — Camera rail.** Status reads *Six streams validated · not yet
mounted*, and the footage agrees (the finished rail is shot on the floor, not on
the cart). Left unchanged — flagging only so you can confirm.

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
