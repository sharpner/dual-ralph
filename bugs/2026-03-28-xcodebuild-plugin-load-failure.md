# xcodebuild-plugin-load-failure

Status: open
assigned-to: user

## Symptom

Direkte App-Verifikation für den neuen Canvas-Navigation-Slice ist lokal nicht ausführbar, weil `xcodebuild` vor dem eigentlichen Build an einer defekten Xcode-Installation scheitert:

`A required plugin failed to load. Please ensure system content is up-to-date — try running 'xcodebuild -runFirstLaunch'.`

Der konkrete Plug-in-Fehler verweist auf `com.apple.dt.IDESimulatorFoundation` und ein fehlendes Symbol in `DVTDownloads.framework`.

## Analysis

- Der Fehler tritt bereits beim Start von `xcodebuild` auf, also bevor `MLXDesignerTests` kompiliert oder ausgeführt werden.
- Der neue Canvas-Code liegt ausschließlich in `MLXDesignerApp/Sources/*` und kann diesen Plug-in-Ladefehler nicht verursachen.
- Damit ist die App-seitige lokale Test-Gate derzeit ein reines Toolchain-/Xcode-Environment-Problem.

## Affected Files

- .workflow/plans/2026-03-27-canvas-navigation.md
- MLXDesigner.xcodeproj
- /Applications/Xcode.app/Contents/Frameworks/IDESimulatorFoundation.framework
- /Library/Developer/PrivateFrameworks/DVTDownloads.framework

## Theorie Assessment (2026-03-28)

This is a local Xcode environment issue. Requires admin authorization:

```bash
sudo xcodebuild -runFirstLaunch
```

Without this, `make test` can't run the xcodebuild App-Tests portion. The engine tests via `swift test` are unaffected and pass (63/63). Reassigning to user since this requires manual admin action.

## Reproduction

```bash
cd /Users/nwagensonner/Development/AI/mlx_designer
HOME=$(pwd)/.local-home xcodebuild -project MLXDesigner.xcodeproj -scheme MLXDesigner -destination 'platform=macOS' -derivedDataPath DerivedData test -only-testing:MLXDesignerTests CODE_SIGNING_ALLOWED=NO
```
