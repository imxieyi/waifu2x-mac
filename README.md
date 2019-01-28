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

## Compilation Instructions
1) Install dependencies for CLI Version as instructed above
2) Build using `waifu2x-mac-app` scheme 
3) To locate the built macOS app, expand the Products folder on Project Navigator (left pane) and right click on `waifu2x-mac-app.app` to select **Show in Finder**
4) This app can be dragged to any location you choose, such as `/Applications`
5) If you would like to use the CLI version of `waifu2x-mac-app`, right click on the app and select `Show Package Contents`. Navigate to `Contents/MacOS`. The CLI version is `waifu2x`.
6) Run `waifu2x` by navigating in a terminal to `waifu2x-mac-app.app/Contents/MacOS/` but if you would like to run the program anywhere, type in `ln -s /path/to/waifu2x /usr/local/bin/waifu2x`. You can also drag the `waifu2x` executable after `ln -s` to get the file path in terminal automatically.
    - For example, if waifu2x-mac-app is in `/Applications`, you would run the following command to create an symbolic link: 
       
       `ln -s /Applications/waifu2x-mac-app.app/Contents/MacOS/waifu2x /usr/local/bin/waifu2x` 
7) You can not drag the CLI executable out and use it directly as it will not work. You must create a symbolic link as shown above if you want to use it without going into the `waifu2x-mac-app.app` directory. Additionally the symbollic link will break if you move the macOS app. You can delete the old symbolic link in `/usr/local/bin` and run the `ln -s` command to create a new symbolic link.


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
**WARNING:** This CLI version is not a self-contained executable. `waifu2x` must be in `waifu2x-mac-app.app/Contents/MacOS/` with `CommandLineKit.framework` and `waifu2x_mac.framework` in `waifu2x-mac-app.app/Contents/Frameworks` or `CommandLineKit.framework` and `waifu2x_mac.framework` must be in the same directory as `waifu2x` executable in order to run. 
