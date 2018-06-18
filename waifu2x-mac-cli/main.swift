//
//  main.swift
//  waifu2x-mac-cli
//
//  Created by xieyi on 2018/6/18.
//  Copyright © 2018年 xieyi. All rights reserved.
//

import Foundation
import Darwin
import CommandLineKit
import waifu2x_mac

enum ImageType: String {
    case anime = "a"
    case photo = "p"
}

let cli = CommandLineKit.CommandLine()

let imageType = EnumOption<ImageType>(shortFlag: "t", longFlag: "type", required: false, helpMessage: "Image type - a for anime (default), p for photo")
let scaleFactor = IntOption(shortFlag: "s", longFlag: "scale", required: true, helpMessage: "Scale factor (1 or 2)")
let denoiseLevel = IntOption(shortFlag: "n", longFlag: "noise", required: true, helpMessage: "Denoise level (0-4)")
let inputImage = StringOption(shortFlag: "i", longFlag: "input", required: true, helpMessage: "Input image file (any format as long as NSImage loads)")
let outputImage = StringOption(shortFlag: "o", longFlag: "output", required: true, helpMessage: "Output image file (png)")
let help = Option(shortFlag: "h", longFlag: "help", helpMessage: "Print usage")

cli.addOptions(imageType, scaleFactor, denoiseLevel, inputImage, outputImage, help)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if !([1, 2].contains(scaleFactor.value!)) {
    fputs("Scale factor must be 1 or 2!\n", __stderrp)
    exit(EX_USAGE)
}

if !([0, 1, 2, 3, 4].contains(denoiseLevel.value!)) {
    fputs("Denoise level must be 0-4!\n", __stderrp)
    exit(EX_USAGE)
}

guard outputImage.value!.hasSuffix(".png") else {
    fputs("Output image must be PNG format!\n", __stderrp)
    exit(EX_USAGE)
}

let inurl = URL(fileURLWithPath: inputImage.value!)
var indata: Data
do {
    indata = try Data(contentsOf: inurl)
} catch {
    fputs("Failed to open input image: \(error.localizedDescription)\n", __stderrp)
    exit(EX_IOERR)
}

guard let inimg = NSImage(data: indata) else {
    fputs("Invalid input image\n", __stderrp)
    exit(EX_IOERR)
}

var anime = true
if imageType.value != nil {
    if (imageType.value! == .photo) {
        anime = false
    }
}

var model: Model! = nil
if anime {
    if scaleFactor.value! == 1 {
        switch denoiseLevel.value! {
        case 1: model = .anime_noise0
        case 2: model = .anime_noise1
        case 3: model = .anime_noise2
        case 4: model = .anime_noise3
        default: break
        }
    } else {
        switch denoiseLevel.value! {
        case 1: model = .anime_noise0_scale2x
        case 2: model = .anime_noise1_scale2x
        case 3: model = .anime_noise2_scale2x
        case 4: model = .anime_noise3_scale2x
        default: model = .anime_scale2x
        }
    }
} else {
    if scaleFactor.value! == 1 {
        switch denoiseLevel.value! {
        case 1: model = .photo_noise0
        case 2: model = .photo_noise1
        case 3: model = .photo_noise2
        case 4: model = .photo_noise3
        default: break
        }
    } else {
        switch denoiseLevel.value! {
        case 1: model = .photo_noise0_scale2x
        case 2: model = .photo_noise1_scale2x
        case 3: model = .photo_noise2_scale2x
        case 4: model = .photo_noise3_scale2x
        default: model = .photo_scale2x
        }
    }
}

guard model != nil else {
    fputs("Invalid scale factor and denoise level combination!\n", __stderrp)
    exit(EX_USAGE)
}

guard let outimg = Waifu2x.run(inimg, model: model) else {
    fputs("Failed to run model!\n", __stderrp)
    exit(EX_SOFTWARE)
}

let outurl = URL(fileURLWithPath: outputImage.value!)
do {
    try outimg.pngWrite(to: outurl)
} catch {
    fputs("Failed to write output image: \(error.localizedDescription)\n", __stderrp)
    exit(EX_IOERR)
}
