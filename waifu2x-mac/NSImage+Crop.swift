//
//  NSImage+Crop.swift
//  waifu2x-ios
//
//  Created by xieyi on 2017/9/14.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

extension NSImage {
    
    public func crop(rects: [CGRect]) -> [NSImage] {
        var result: [NSImage] = []
        for rect in rects {
            result.append(crop(rect: rect))
        }
        return result
    }
    
    public func crop(rect: CGRect) -> NSImage {
        var rect = NSRect.init(origin: .zero, size: self.size)
        let cgimg = cgImage(forProposedRect: &rect, context: nil, hints: nil)?.cropping(to: rect)
        return NSImage(cgImage: cgimg!, size: rect.size)
    }
    
}
