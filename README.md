https://github.com/user-attachments/assets/d61cd45f-abd8-4fa1-9038-5f9968ce9c9c

## A native macOS app for [pprof](https://github.com/google/pprof)
Open pprof profiles without command-line hassle ✨.

## Install
```bash
brew install approf
```

You can also download the latest app from [release](https://github.com/moderato-app/approf/releases/latest).

## Requirements
* `Graphviz` installed
* macOS **Sonoma 14.0** or later on a **M-series chip**

_Translucent background is only availble on macOS **Sequoia 15.0** or later_


## Features
- [x] Drag and drop pprof files to open
- [x] Compare pprof profiles using the [`-diff_base`](https://github.com/google/pprof/blob/main/doc/README.md#comparing-profiles) option
- [x] Reorder / Add / Remove files in seconds
- [x] Dark / Light mode
- [x] Save sessions for later use

## Screenshots
<img width="100%" alt="Screenshot" src="https://github.com/user-attachments/assets/efff596b-302d-45c9-8795-1ff8633e7d0f">
<div align="center">Command line under the hood</div>
<br/>
<br/>
<img width="100%" alt="Screenshot" src="https://github.com/user-attachments/assets/d34f68fb-8aa6-46ad-9a34-7c97c1a3ae0b">
<div align="center">WEB page in dark mode </div>

## Implementation
* SwiftUI and AppKit as the UI framework.
* The Composable Architecture for state management.
* Running [pprof](https://github.com/golang/go/tree/master/src/cmd/pprof) binay in a process.
