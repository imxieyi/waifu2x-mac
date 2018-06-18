#  Waifu2x-mac
Waifu2x porting to macos, still in CoreML and Metal. For other details please refer to [waifu2x-ios](https://github.com/imxieyi/waifu2x-ios).

## Disclaimer
I haven't published this app to the Mac App Store. Any app appears on the store has nothing to do with me.

## Requirements
 - macOS 10.13+
 - XCode 9.0+
 
## Install Dependencies for CLI Version
```bash
cd Dependencies
swift package update
rake xcodeproj
```

## CLI Version Usage
```
Usage: waifu2x [options]
    -t, --type:
        Image type - a for anime (default), p for photo
    -s, --scale:
        Scale factor (1 or 2)
    -n, --noise:
        Denoise level (0-4)
    -i, --input:
        Input image file (any format as long as NSImage loads)
    -o, --output:
        Output image file (png)
    -h, --help:
        Print usage
```
**WARNING:** This CLI version is not a self-contained executable.  `CommandLineKit.framework` and `waifu2x_mac.framework` must be in the same directory as `waifu2x` executable in order to run. Refer to [this question](https://stackoverflow.com/questions/35423862/realm-swift-osx-cocoapods-sample-app-crashes) if you are interested in improving it. 
