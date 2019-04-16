//
//  waifu2x_macTests.swift
//  waifu2x-macTests
//
//  Created by xieyi on 2018/1/24.
//  Copyright © 2018年 xieyi. All rights reserved.
//

import XCTest
import Cocoa
@testable import waifu2x_mac

class waifu2x_macTests: XCTestCase {
    
    private var image: NSImage!
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "white", ofType: "png")!
        let data = NSData(contentsOfFile: path)
        image = NSImage(data: data! as Data)
    }
    
    override func tearDown() {
        image = nil
        super.tearDown()
    }
    
    func testAllModels() {
        for model in Model.all {
            print(model)
            assert(Waifu2x.run(image, model: model) != nil)
        }
    }
    
}
