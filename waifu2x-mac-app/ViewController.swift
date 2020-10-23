//
//  ViewController.swift
//  waifu2x-mac-app
//
//  Created by xieyi on 2018/1/24.
//  Copyright © 2018年 xieyi. All rights reserved.
//

import Cocoa
import waifu2x_mac

class ViewController: NSViewController {

    @IBOutlet weak var inImg: NSImageView!
    @IBOutlet weak var outImg: NSImageView!
    @IBOutlet weak var status: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.window?.styleMask.insert(.resizable)
    }
    
}
