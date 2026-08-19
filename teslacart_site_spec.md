# TeslaKart — Showcase Site Build Spec

**For:** Claude Code
**Deliverable:** one-page static showcase site
**Scope of this doc:** content and structure only. No HTML, no CSS, no framework choices — those are yours to decide. This file defines *what goes on the page and in what order*, plus where media slots in.

> **Naming note:** The owner refers to the project as **TeslaKart** in this spec. The code repository is named **`TeslaCart`** [confirm whether this is an intentional rename or a typo — use "TeslaKart" as the public display name on the site unless the repo/README says otherwise].

---

## Page structure (top to bottom)

1. Hero
2. Project overview
3. Hardware architecture
4. Software architecture
5. Build log (dated, phase by phase)
6. What's next
7. Footer

Single scrolling page. Each numbered section below maps to one block on that page.

---

## 1. Hero

**Headline (h1):**
> TeslaKart — a self-driving golf cart

**One-line description (subhead):**
> A 2015 Club Car golf cart retrofitted with drive-by-wire controls, a 360° camera rig, and an onboard neural network that learns to drive it.

**Media placeholder:**
`[HERO VIDEO — the cart driving under its own control, or being driven via the Xbox controller if autonomy footage isn't ready yet. Short loop, muted, autoplay. Fallback poster image of the full cart with the camera rail visible.]`

---

## 2. Project overview

Two to three sentences, written for a technical recruiter who is not a robotics person. Convey scope and ambition without jargon.

**Draft copy (edit freely):**
> TeslaKart turns an ordinary electric golf cart into a self-driving vehicle. Every physical control — steering, throttle, braking, and direction — was replaced with electronics that a small onboard computer can operate, and the cart drives itself using an AI model trained on real driving demonstrations rather than hand-written rules. It's a full-stack build spanning custom electronics, embedded firmware, and modern machine learning, done solo on a student budget.

`[IMAGE — wide shot of the finished cart, ideally showing the camera rail under the roof and the electronics.]`

---

## 3. Hardware architecture

Present as a labeled breakdown (subsections or a diagram + captions — your call). Content:

**Platform**
- 2015 Club Car Precedent i2 — 48V electric golf cart
- Stock drivetrain: MCOR4 throttle module, Curtis motor controller
- Retrofitted for full drive-by-wire while keeping every control manually reversible

**Compute**
- **NVIDIA Jetson Orin Nano Super** (8GB, 67 TOPS) — runs the vision + driving model
  - JetPack 6.2.1, booting from an NVMe SSD (root filesystem migrated off the microSD)
- **Arduino Mega 2560** — real-time executor: drives the motors, holds the safety watchdog
- Design principle: a **three-layer control stack** — Jetson (high-level reasoning) → Arduino (deterministic 50 Hz execution + watchdog) → hardware safety (relays + physical E-stop). The Arduino stays in the loop even under autonomy so timing is guaranteed and a watchdog can stop the cart independently of the Linux side.

**Drive-by-wire subsystems**
- **Steering** — NEMA 34 closed-loop stepper motor (12 N·m) with an HBS86H driver, belt-driven to the steering column (30T→80T, 2.67:1). Position-controlled over a calibrated ±6000-step range; self-centers on release.
- **Throttle** — a digital potentiometer (DS3502) electrically impersonates the pedal and is swapped in via relays, so the computer can command throttle without a servo touching the pedal.
- **Forward / Reverse** — the cart's direction-select logic signals are intercepted with relays so direction can be set in firmware. [Status: wires located on the cart; harness not yet traced or wired — see build log.]
- **Braking** — a self-locking 12V linear actuator pulls the brake cable via a tension-only Y-bridle at the cable equalizer, driven by a BTS7960 H-bridge, with a slide-potentiometer giving continuous brake-position feedback. Tension-only design means the human can always override. [Manual during the remote-control phase; part of the model's action space for autonomy.]

**Sensors / cameras**
- **6× Innomaker U20CAM-1080P** USB cameras — 1080p @ 30fps, MJPEG, native UVC, ~130° diagonal FOV
- **360° surround layout:** front-center, two front corners (≈±60°), two rear corners (≈±120°), rear-center — mounted on PVC rails under the roof lip, cabling routed inside the rail
- MJPEG compression is what makes six simultaneous USB streams feasible on the available bandwidth
- Cameras are powered from the cart through powered USB hubs (fed by a wide-input DC-DC buck converter off the battery busbars), so camera load and heat stay off the Jetson — the Jetson port carries data only

**Camera interface note for the site:** describe it as "six USB cameras streaming MJPEG into the Jetson." [Earlier in the project a GMSL2/CSI aggregator path was evaluated; the **decided** path is USB + MJPEG. Don't describe both on the page — it's USB.]

**Power**
- 48V pack → master battery-disconnect switch → main fuse → positive/negative busbars → individually fused branches (steering driver, camera power, compute)
- Separate DC-DC converters isolate the Jetson from the brake actuator so motor noise can't brown out the computer

`[DIAGRAM — the wiring/architecture diagram. A draw.io diagram of the full system already exists in the repo; use it or a cleaned-up export. Should show power distribution and which subsystem each Arduino pin drives.]`

`[IMAGE — close-up of the electronics (Arduino, relays, drivers) and the busbars.]`

---

## 4. Software architecture

**The model**
- A **pretrained vision-language-action (VLA) model, fine-tuned** on the cart's own driving data — not trained from scratch, and not a hand-coded rule system. The pretrained model already understands roads, scenes, and obstacles; fine-tuning teaches it *this cart's specific controls*.
- [Specific model TBD in this spec — **SmolVLA (~450M params, via LeRobot)** was the leading candidate. Confirm against the repo before stating a model name on the site.]

**The pipeline (autonomy loop)**
1. Six cameras stream frames into the Jetson
2. The VLA processes the frames and outputs normalized actions — steering, throttle, brake, direction
3. A **mapping layer** converts those normalized outputs into hardware terms: steering steps (±6000), throttle pot value, brake actuator position, direction relay state. *This is the exact same mapping layer already used for manual Xbox-controller driving — the model simply replaces the joystick.*
4. Commands go over USB serial to the Arduino
5. The Arduino executes at ~50 Hz with a watchdog that zeroes throttle if commands stop

**Safety override layer**
- A dedicated person/obstacle detector runs alongside the driving model and can override it to force a brake — a hard, deterministic rule sitting above the probabilistic driving policy. Built on the object detection already running on the Jetson (SSD-MobileNet via TensorRT).
- Defense in depth: learned model + explicit detector + Arduino watchdog + human safety driver + physical E-stop. No single layer is trusted alone.

**How the pieces talk**
- Jetson ↔ Arduino: USB serial, a compact command protocol (steering + throttle + direction per message)
- Xbox controller ↔ compute: used for manual driving *and* for data collection (over Bluetooth to the Jetson, or USB to a laptop during bring-up)

**Training / data collection**
- Data is collected by **driving the cart manually via the controller**. The controller inputs *are* the training labels — the model learns to reproduce the commands the human issued.
- Each logged record: `timestamp, 6 camera frames, commanded steering/throttle/direction` at ~30 Hz. Brake logs the *actual* potentiometer position (continuous feedback), not just the command.
- Target: roughly **5–10 hours of clean driving** (~20–30 short sessions), including deliberate **recovery episodes** (drift off-center, then correct) to teach the model how to recover — the main defense against distribution shift.
- Reverse is left out of the initial action space (rare, low-data, and mixing a discrete flip into continuous control hurts learning); logged now, added later.

`[IMAGE or DIAGRAM — the control-loop / data-flow diagram: cameras → Jetson (VLA + safety detector) → mapping → Arduino → actuators.]`

`[SCREENSHOT — the Jetson running live object detection with bounding boxes.]`

---

## 5. Build log

Dated, phase by phase. **Be honest about status.** Use a clear tag on each phase: **✅ Complete**, **🟡 In progress**, or **⬜ Planned**. Do not present unfinished work as done.

> [Most exact dates are unknown to me — I've marked known ones and bracketed the rest. Fill from the repo's commit history, which is the source of truth for dates.]

**Phase 1 — Throttle drive-by-wire · ✅ Complete**
`[date range?]` — Digital-potentiometer throttle intercept of the MCOR module, relay-switched between the real pedal and the computer. Bench-tested, then **road-tested on the cart.** Includes a serial watchdog that zeroes throttle on signal loss.

**Phase 2 — Steering drive-by-wire · ✅ Complete**
`[date range?]` — Closed-loop stepper + belt drive to the steering column. Lock-to-lock calibrated (usable range ±6000 steps; beyond that the motor loses position). Driven live from an Xbox controller with self-centering, absolute-position steering.

**Phase 3 — Brake subsystem · ✅ Bench-tested / 🟡 not yet mounted**
July 29–30, 2026 — Linear-actuator brake with tension-only cable bridle and continuous position feedback. **Full chain bench-tested successfully** (extend/retract/variable force over serial; self-locking holds position). Not yet mounted to the cart or integrated into the control loop — manual during the RC phase by design.

**Phase 4 — Compute bring-up · ✅ Complete**
`[date?]` — Jetson Orin Nano set up on JetPack 6.2.1, root filesystem migrated to NVMe SSD, live object detection running via TensorRT.

**Phase 5 — Manual controller driving · ✅ Complete (throttle + steering)**
`[date?]` — Xbox-controller drive integrating throttle + steering through one firmware path, with tuned steering sensitivity and a hold-to-go-sharp escape for tight turns. [Reverse not yet part of this — see Phase 7.]

**Phase 6 — Power distribution · 🟡 In progress**
`[date?]` — Master disconnect switch and busbars **ordered**; main + branch fusing planned. Wiring the trunk (switch → fuse → busbars → branches) is pending parts arrival. [Open finish-up item: verify the brake driver's ground tie to the Arduino — a known silent-failure point.]

**Phase 7 — Forward/Reverse · 🟡 In progress**
`[date?]` — Direction-select wires located on the cart. Still to do: meter-test the 3-wire harness (identify forward/reverse/common and signal polarity), wire the two relays, and add reverse to firmware. Uses existing relay channels and Arduino pins — no new hardware.

**Phase 8 — Camera subsystem · 🟡 In progress**
`[date?]` — Six-camera 360° rig **decided and ordered** (cameras, powered hubs, buck converter). Mounts (printed housings on PVC rails) are designed but not yet built — waiting on parts to measure and CAD. **Six-simultaneous-stream validation not yet run** — this is the gating test before mounts and cable lengths are finalized.

**Phase 9 — Autonomy (VLA training) · ⬜ Planned**
Not started. Depends on hardware-complete (drives on controller + six cameras streaming reliably) so that data collection can begin. Plan: fine-tune a pretrained VLA on RC-collected driving data, then layer in the safety override.

`[VIDEO — steering test: wheels turning lock-to-lock / self-centering on stands.]`
`[VIDEO — throttle or full controller-drive clip on the ground.]`
`[VIDEO — brake actuator bench test.]`
`[IMAGE — CAD render of the camera housing / rail mount.]`

---

## 6. What's next

Short, forward-looking. Content:

- Finish forward/reverse wiring and fold it into the firmware
- Complete power distribution (master switch, busbars, fusing) and final electronics integration
- Validate all six cameras streaming simultaneously, then build and mount the camera rail
- Reach "hardware complete" — the cart drives on the controller with all six cameras streaming and full state feedback
- Begin data collection: log synchronized camera + command data while driving manually
- Fine-tune the VLA, deploy it on the Jetson, and bring up the safety-override layer — one layer at a time, safety first
- Keep a human in the seat throughout (Level-2, always-overridable)

---

## 7. Footer

- Project name, builder name [confirm how the owner wants to be credited]
- Link to the code repository [confirm public/private and the URL]
- `[optional: contact / LinkedIn / email — confirm before adding]`

---

## Global content/tone guidance

- Audience is technical but not necessarily robotics-savvy — explain mechanisms in plain terms, keep the jargon labeled.
- **Honesty is a feature here.** The dated, clearly-status-tagged build log is the point — a recruiter should be able to see exactly what's done versus in progress. Don't smooth over the in-progress items.
- Every bracketed `[...]` in this spec is either a media placeholder or an uncertain detail to confirm — none should survive into the final site as literal brackets.

---

## Note to Claude Code

The **TeslaKart / TeslaCart code repository is available locally** — read the source before writing the site. Use it to:

- Pull **accurate implementation details** (real pin assignments, the serial protocol, calibration constants, the actual model/library names) rather than relying only on this spec, which is written from memory and flags uncertainty in brackets.
- Confirm the **file structure** (firmware/, jetson/, training/, docs/ or whatever actually exists) so any code references or repo links on the site are correct.
- Find **existing media and diagrams** already in the repo — the draw.io wiring diagram, any CAD renders, milestone docs, setup notes — and prefer real repo assets over the placeholders in this spec wherever they exist.
- Resolve the bracketed uncertainties in this spec (project name, exact dates from commit history, the specific VLA model) against what the repo actually says. Where the repo and this spec disagree, **the repo wins.**
