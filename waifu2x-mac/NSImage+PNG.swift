//
//  NSImage+PNG.swift
//  waifu2x-mac-app
//
//  Created by xieyi on 2018/1/24.
//  Copyright © 2018年 xieyi. All rights reserved.
//
//  Reference: https://stackoverflow.com/questions/39925248/swift-on-macos-how-to-save-nsimage-to-disk

import Foundation
import Cocoa

public extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) throws {
        try pngData?.write(to: url, options: options)
    }
}
