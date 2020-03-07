#  Waifu2x-mac
Waifu2x porting to macos, still in CoreML and Metal. For other details please refer to [waifu2x-ios](https://github.com/imxieyi/waifu2x-ios).

[![Build Status](https://travis-ci.org/imxieyi/waifu2x-mac.svg?branch=master)](https://travis-ci.org/imxieyi/waifu2x-mac)

## Disclaimer
I haven't published this app to the Mac App Store. Any app appears on the store has nothing to do with me.

## Requirements
 - macOS 10.13+ (Running)
 - Xcode 11.1+ (Building)
 
## Homebrew (Experimental)
If you want to install with homebrew (CLI only):
```bash
brew install imxieyi/waifu2x/waifu2x
```
**It downloads pre-built binary from [releases](https://github.com/imxieyi/waifu2x-mac/releases). Xcode is not needed.**

## Compilation Instructions
### Option A (automatic):
1) Open the Terminal (⌘+Space, "terminal")
2) Drag `build.sh` from Finder to the Terminal window, and press Return to start building the app.  
   All missing dependencies (including Xcode) will be installed automatically by the script if needed.
3) Once the build has completed, the `waifu2x-mac-app` application can be found in the `build` folder.

### Option B (manual):
1) Build using `waifu2x-mac-app` scheme 
2) To locate the built macOS app, expand the Products folder on Project Navigator (left pane) and right click on `waifu2x-mac-app.app` to select **Show in Finder**

## Installing the App and CLI Version
The app can be dragged to any location you choose, such as `/Applications`.

If you would like to use the CLI version, right click on the app and select **Show Package Contents**. Navigate to `Contents/MacOS`. The CLI version is `waifu2x`.

If you would like to run the program anywhere, you must create a symbolic link by typing `ln -s /path/to/waifu2x /usr/local/bin/waifu2x` in a terminal. You can also drag the waifu2x executable after `ln -s ` to get the file path in terminal automatically.

> For example, if waifu2x-mac-app is in `/Applications`, you would run the following command to create a symlink:  
`ln -s /Applications/waifu2x-mac-app.app/Contents/MacOS/waifu2x /usr/local/bin/waifu2x`

**N.B.:** You can not drag the CLI executable out and use it directly as it will not work. You must create a symbolic link as shown above if you want to use it without going into the `waifu2x-mac-app.app` directory.  
Additionally the symbolic link will break if you move the macOS app. You can delete the old symlink with `unlink /usr/local/bin/waifu2x` and run `ln -s` again to create a new one.

## Command-Line Usage
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
**WARNING:** The CLI version is not a self-contained executable. `waifu2x` must remain in the same directory as `CommandLineKit.framework` and `waifu2x_mac.framework`.
