# BUILD_LOG — TeslaCart showcase site (v1)

Built autonomously from `teslacart_site_spec.md` + the local `TeslaCart` source
repo, per your instructions. Nothing committed, nothing pushed — everything in
this repo is uncommitted working-tree changes for you to review.

**Files created:** `index.html`, `styles.css`, `assets/README.md` (media
manifest), this file. The spec file was left untouched. The TeslaCart source
repo was read-only throughout — no files there were modified.

---

## Verified rendering

Self-reviewed by rendering the finished page in headless Chrome at 1440px
(desktop) and a true 390px viewport (phone) and inspecting the screenshots.
HTML tag balance machine-checked. No horizontal overflow at 390px, no leftover
spec brackets or placeholder prose, all statuses render with their honest
tags. One note: to preview locally just open `index.html` in a browser — there
is no build step.

---

## Spec-vs-repo conflicts and how I resolved each

Your rule was "source wins, flag it." Applied as follows:

1. **Project display name → "TeslaCart" (repo wins).** The spec uses
   "TeslaKart" but defers to the repo, and the repo/README consistently say
   Tesla Cart / TeslaCart. Site-wide find-replace is trivial if you actually
   want the K spelling.

2. **Steering range → ±7000 steps (repo wins).** Spec said ±6000; the firmware
   (`firmware/controller/xbox_drive.ino`: `STEER_LIMIT = 7000`, commented
   "calibrated lock-to-lock (with margin)") says 7000. Used 7000 everywhere.

3. **Camera count → 6 cameras (spec wins — the one deliberate exception).**
   The repo's planning docs (`docs/MASTER_PLAN.md`, `CLAUDE.md`) describe a
   **5-camera** rig (3 front + 2 rear, ELP/Arducam). The spec describes a
   **6-camera** 360° rig (Innomaker U20CAM-1080P, powered hubs, buck
   converter) as *decided and ordered* — a newer purchasing decision the repo
   simply hasn't caught up on, alongside other phases (busbars, F/R wires
   located) the repo doesn't record at all. Treating the stale planning doc as
   "the source" here would put wrong hardware on a public page, so the site
   says 6. **If the rig is actually 5 cameras, this needs fixing in
   `index.html` (hero subhead, Cameras section, autonomy-loop diagram, Phase 8,
   What's next).** I kept the repo's direction-based stream selection insight
   (model sees ≤3 streams per timestep) since it reconciles 6 cameras with
   SmolVLA's input limits — verify that's still the plan.

4. **"Hold-to-go-sharp" steering feature → omitted.** Spec's Phase 5 mentions
   it; it does not exist in the repo's controller code (`xbox_drive.py` has
   expo shaping only). Phase 5 describes expo-shaped sensitivity instead. If
   the feature exists in newer uncommitted firmware, add a clause back.

5. **Brake bench test "variable force" → "variable speed" (repo wins).**
   `docs/BRAKE.md` records variable *speed* via PWM; force control needs the
   position feedback that isn't installed yet.

6. **Brake position feedback worded carefully.** The spec presents the slide
   potentiometer as part of the design; `docs/BRAKE.md` lists it as the main
   open item (planned, ~$10, not yet purchased/fitted). The site describes it
   as part of the subsystem design (matching the spec's hardware section), and
   the Phase 3 log keeps the honest "bench-tested / not yet mounted" split.
   If you want the pot described as future work instead, tweak the Braking
   card in `index.html`.

7. **GPS omitted (spec wins by omission).** The repo plans a u-blox NEO-M9N
   waypoint layer; the spec's content outline never mentions GPS, so I left it
   off rather than adding unrequested scope. Easy to add a bullet under
   Software → "How the pieces talk" if you want it.

8. **Dates without git.** You barred git commands, so commit history wasn't
   used. Dates come from the docs themselves: Phase 1 = July 11–14 (bench →
   road test, from `MILESTONE_1_THROTTLE.md`/`CLAUDE.md`), Phase 3 = July
   26–30 (`BRAKE.md`). Phases 2, 4–8 have no dated docs, so they carry
   month-level dates ("July 2026", "August 2026", "July–August 2026") inferred
   from doc ordering and the repo's last-known activity (Aug 16). **These are
   the softest facts on the page — tighten them from `git log` when you
   review.**

## Other decisions made on your behalf

- **Design:** dark engineering-notebook look — near-black background, one
  amber accent, monospace labels, generous spacing, system fonts only (no
  webfonts, no JS, no external requests → fast and CSP-proof). Status colors:
  green = complete, amber = in progress, gray = planned.
- **Diagrams built in, not placeholders:** the three-layer control stack and
  the autonomy loop are rendered as styled HTML/CSS flow diagrams, since the
  spec allowed "diagram — your call." The wiring schematic stayed a
  placeholder because a real export of your draw.io file will beat anything I
  redraw.
- **Footer credit:** "Noah Sabbavarapu" (spelling taken from
  `docs/MASTER_PLAN.md` line 2) with a link to
  `https://github.com/NoahSabb/TeslaCart`. **Verify that repo is public before
  publishing** — I couldn't check without hitting GitHub. No email/LinkedIn
  added (spec said confirm first).
- **Spec statuses preserved verbatim** — ✅ Complete / 🟡 In progress /
  ⬜ Planned, including Phase 3's split "✅ Bench-tested / 🟡 not yet mounted"
  and Phase 5's "✅ Complete (throttle + steering)".
- **Overview reversibility line** softened from "unplug one harness" to
  "unplug the intercept harness and unbolt a couple of brackets" — matches the
  source README now that steering hardware bolts on.
- `og:image` points at `assets/cart-wide.jpg` so link previews light up once
  that photo lands. Favicon is an inline SVG emoji (⛳) — zero extra files.

---

## Files you need to add to `assets/`

Full table with tips lives in `assets/README.md`. Every placeholder block in
`index.html` has an HTML comment right above it containing the exact
swap-in markup to paste.

| File | What it should show |
|---|---|
| `hero.mp4` + `hero-poster.jpg` | Cart driving (autonomous, or Xbox-controlled until then); poster = full cart with camera rail |
| `cart-wide.jpg` | Wide shot of finished cart (also the social-preview image) |
| `wiring-diagram.png` | PNG export of `TeslaCart/testlacartschematic.drawio` (app.diagrams.net → File → Export as → PNG) |
| `electronics-closeup.jpg` | Arduino, relays, drivers, busbars |
| `detectnet.jpg` | Jetson live object detection with bounding boxes |
| `steering-test.mp4` | Lock-to-lock / self-centering on stands |
| `drive-test.mp4` | Controller-driven clip on the ground |
| `brake-bench.mp4` | Brake actuator bench test |
| `camera-mount-cad.png` | CAD render of camera housing / rail mount |

---

## Enabling GitHub Pages

1. Commit and push these files to `main` (your call, per your instructions).
2. On github.com → **NoahSabb/TestlaCart-site** → **Settings** → **Pages**
   (left sidebar).
3. Under **Build and deployment**: Source = **Deploy from a branch**;
   Branch = **main**, folder = **/ (root)**. Save.
4. The site appears at **https://noahsabb.github.io/TestlaCart-site/** within
   a minute or two (first deploy can take ~5).
5. Optional tidy-ups: the repo name is spelled T-e-s-**t**-l-a — renaming to
   `TeslaCart-site` (Settings → General) also fixes the URL, and GitHub
   auto-redirects the old name. Consider a one-line `.gitignore` with
   `.DS_Store` (one is already sitting untracked in this repo).
