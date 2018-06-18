//
//  NSImage+Bicubic.swift
//  waifu2x
//
//  Created by xieyi on 2017/12/29.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

extension NSImage {
    
    /// Resize image using Hermite Bicubic Interpolation
    ///
    /// - Parameter scale: Scale factor
    /// - Returns: Generated image
    func bicubic(scale: Float) -> NSImage {
        
        let width = Int(self.representations[0].pixelsWide)
        let height = Int(self.representations[0].pixelsHigh)
        var rect = NSRect.init(origin: .zero, size: CGSize(width: width, height: height))
        let cgimg = self.representations[0].cgImage(forProposedRect: &rect, context: nil, hints: nil)
        let outw = Int(Float(width) * scale)
        let outh = Int(Float(height) * scale)
        
        let pixels = cgimg?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixels!)
        let buffer = UnsafeBufferPointer(start: data, count: 4 * width * height)
        let arr = Array(buffer)
        
        let bicubic = Bicubic(image: arr, channels: 4, width: width, height: height)
        
        let scaled = bicubic.resize(scale: scale)
        
        // Generate output image
        let cfbuffer = CFDataCreate(nil, scaled, outw * outh * 4)!
        let dataProvider = CGDataProvider(data: cfbuffer)!
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Big
        let cgImage = CGImage(width: outw, height: outh, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: outw * 4, space: colorSpace, bitmapInfo: bitmapInfo, provider: dataProvider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        let outImage = NSImage(cgImage: cgImage!, size: NSSize(width: outw, height: outh))
        
        return outImage
    }
    
}
