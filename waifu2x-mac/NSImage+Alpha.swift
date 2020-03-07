//
//  NSImage+Alpha.swift
//  waifu2x
//
//  Created by xieyi on 2017/12/29.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

extension NSImage {
    
    // For images with more than 8 bits per component, extracting alpha only produces incomplete image
    func alphaTyped<T>(bits: Int, zero: T) -> UnsafeMutablePointer<T> {
        let width = Int(self.representations[0].pixelsWide)
        let height = Int(self.representations[0].pixelsHigh)
        var rect = NSRect.init(origin: .zero, size: CGSize(width: width, height: height))
        let cgimg = self.representations[0].cgImage(forProposedRect: &rect, context: nil, hints: nil)
        let data = UnsafeMutablePointer<T>.allocate(capacity: width * height * 4)
        data.initialize(repeating: zero, count: width * height)
        let alphaOnly = CGContext(data: data, width: width, height: height, bitsPerComponent: bits, bytesPerRow: width * 4 * bits / 8, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        alphaOnly?.draw(cgimg!, in: CGRect(x: 0, y: 0, width: width, height: height))
        return data
    }
    
    func alphaNonTyped(_ datap: UnsafeMutableRawPointer) {
        let width = Int(self.representations[0].pixelsWide)
        let height = Int(self.representations[0].pixelsHigh)
        var rect = NSRect.init(origin: .zero, size: CGSize(width: width, height: height))
        let cgimg = self.representations[0].cgImage(forProposedRect: &rect, context: nil, hints: nil)
        let alphaOnly = CGContext(data: datap, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue)
        alphaOnly?.draw(cgimg!, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    func alpha() -> [UInt8] {
        let width = Int(self.representations[0].pixelsWide)
        let height = Int(self.representations[0].pixelsHigh)
        let bits = self.representations[0].cgImage(forProposedRect: nil, context: nil, hints: nil)?.bitsPerComponent ?? 8
        NSLog("Bits per component: %d", bits)
        var data = [UInt8].init(repeating: 0, count: width * height)
        if bits == 8 {
            alphaNonTyped(&data)
        } else if bits == 16 {
            let typed: UnsafeMutablePointer<UInt16> = alphaTyped(bits: 16, zero: 0)
            for i in 0 ..< data.count {
                data[i] = UInt8(typed[i * 4 + 3] >> 8)
            }
            typed.deallocate()
        } else if bits == 32 {
            let typed: UnsafeMutablePointer<UInt32> = alphaTyped(bits: 32, zero: 0)
            for i in 0 ..< data.count {
                data[i] = UInt8(typed[i * 4 + 3] >> 24)
            }
            typed.deallocate()
        }
        return data
    }
    
}
