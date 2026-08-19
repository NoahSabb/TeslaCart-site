# assets/ — media manifest

Drop the real files in here using these exact filenames — the page's
placeholder blocks (and the swap-in markup in `index.html`'s HTML comments)
expect them. Each placeholder comment in `index.html` includes the exact
`<figure>` markup to paste in when the file is ready.

| Filename | Type | What it should show |
|---|---|---|
| `hero.mp4` | video (short, muted loop) | The cart driving under its own control — or Xbox-controller driving until autonomy footage exists |
| `hero-poster.jpg` | image | Poster frame for the hero video: the full cart with the camera rail visible |
| `cart-wide.jpg` | image | Wide shot of the finished cart — camera rail under the roof, electronics visible (also used as the `og:image` link preview) |
| `wiring-diagram.png` | image | PNG export of `TeslaCart/testlacartschematic.drawio` (open at app.diagrams.net → File → Export as → PNG, 2× zoom) |
| `electronics-closeup.jpg` | image | Close-up of the Arduino, relay board, motor drivers, and busbars |
| `detectnet.jpg` | image | Screenshot of the Jetson running live object detection with bounding boxes |
| `steering-test.mp4` | video | Wheels turning lock-to-lock / self-centering on stands |
| `drive-test.mp4` | video | Throttle or full controller-drive clip on the ground |
| `brake-bench.mp4` | video | Brake actuator bench test — variable-speed extend/retract over serial |
| `camera-mount-cad.png` | image | CAD render of the camera housing / rail mount |

Tips:
- Keep videos short (5–20 s) and compressed (H.264 MP4, ≤1080p) — GitHub Pages
  serves them as static files with no streaming, so big files load slowly.
- JPG images around 1600–2000 px wide are plenty at this page width.
