//
//  NSImage+PNG.swift
//  waifu2x-mac-app
//
//  Created by 谢宜 on 2018/1/24.
//  Copyright © 2018年 谢宜. All rights reserved.
//
//  Reference: https://stackoverflow.com/questions/39925248/swift-on-macos-how-to-save-nsimage-to-disk

import Foundation
import Cocoa

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
