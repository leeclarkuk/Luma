# Luma

A tiny, tactile instant camera for iPhone, built entirely in SwiftUI.

Luma is designed around one idea: the interaction is the product. It recreates the feel of a physical instant camera through motion, sound, haptics and deliberate little details that make taking a photo feel like an event rather than another button tap.

## The experience

**Drag to open.**
Luma lives as a compact pill beneath the Dynamic Island. Pull it open with a rubbery, detented drag, complete with physical clicks and haptic ticks at each stop.

**Tap to snap.**
Press the chunky red shutter and the whole camera reacts. You get a proper flash bloom followed by a two-stage shutter haptic that mimics the mirror slap and curtain.

**Morph, slot and eject.**
After capture, the camera body flinches, the motor starts to whirr and the print rolls physically out of the slot before gliding onto your photo shelf.

**Slow development.**
Photos emerge milky and slightly green, then develop over roughly 18 seconds as saturation, contrast, brightness and sharpness gradually resolve.

**Shake to develop.**
Shake the phone to hurry the chemistry along using Core Motion. In the Simulator, use ⌃⌘Z to trigger the same behaviour.

**Sound and haptics in lockstep.**
Every sound cue is synthesised at runtime and synchronised with its corresponding haptic. Luma ships with no bundled audio assets.

**Private by design.**
No accounts. No network connection. No analytics. No tracking.

Real captures can optionally be saved directly to the user’s photo library.

## Running Luma

```bash
brew install xcodegen
xcodegen generate
open Luma.xcodeproj
```

The deployment target is iOS 17.

On a physical device, Luma uses AVCaptureSession for the live viewfinder and photo capture.

In the Simulator, or when camera permission is unavailable, Luma falls back to a procedural dusk scene rendered using SwiftUI Canvas. The entire interaction can therefore be demonstrated without camera hardware.

The status chip shows:

- **LIVE** when using the physical camera
- **DEMO** when using the procedural scene

## Audio in the Simulator

Simulator audio is routed through the host machine’s CoreAudio server. That server may be unavailable on headless or CI environments and can cause AVAudioEngine to hang.

Audio is therefore disabled by default when running Luma in the Simulator.

To enable it, add the following environment variable to the scheme:

```text
LUMA_AUDIO=1
```

Audio is always enabled on a physical device.

## Tests

LumaUITests drives the complete interaction:

```text
drag → snap → eject → develop → focus
```

A screenshot is captured at each stage.

Run the suite with:

```bash
xcodebuild -project Luma.xcodeproj -scheme Luma \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

Set `LUMA_SHOT_DIR` to write generated PNG screenshots somewhere outside the application container.

`LumaTests` covers detent snapping and development chemistry with no UI.

UI tests pass `-luma-fast-chem` so development takes about three seconds instead of 18. Production behaviour is unchanged.

## Project layout

```text
Luma/Sources
├── App/        app entry point
├── Camera/     AVFoundation capture, preview layer and procedural demo scene
├── Core/       synthesised audio, Core Haptics and shake detection
├── Models/     camera state machine and instant photo model
└── Views/      camera body, instant print card and composition
```

Luma recreates the behaviour and visual language demonstrated publicly for this style of instant-camera interaction. No proprietary source code was used.
