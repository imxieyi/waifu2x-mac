//
//  MainWindowController.swift
//  waifu2x-mac-app
//
//  Created by xieyi on 2020/10/22.
//  Copyright © 2020 xieyi. All rights reserved.
//

import Foundation
import AppKit
import waifu2x_mac

class MainWindowController: NSWindowController, NSToolbarItemValidation {
    
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var pickBarItem: NSToolbarItem!
    @IBOutlet weak var configBarItem: NSToolbarItem!
    @IBOutlet weak var processBarItem: NSToolbarItem!
    @IBOutlet weak var saveBarItem: NSToolbarItem!
    
    weak var windowContent: ViewController!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        windowContent = window?.contentViewController as? ViewController
        pickBarItem.isEnabled = true
        configBarItem.isEnabled = true
        processBarItem.isEnabled = false
        saveBarItem.isEnabled = false
        pickBarItem.autovalidates = true
        configBarItem.autovalidates = true
        processBarItem.autovalidates = true
        saveBarItem.autovalidates = true
        toolbar.allowsUserCustomization = false
    }
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        return item.isEnabled
    }
    
    @IBAction func onPick(_ sender: Any) {
        let dialog = NSOpenPanel()
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["public.image"]
        dialog.beginSheetModal(for: window!) { (resp) in
            if resp == NSApplication.ModalResponse.OK {
                let url = dialog.urls[0]
                self.windowContent.inImg.image = NSImage(contentsOf: url)
                self.processBarItem.isEnabled = true
            }
        }
    }
    
    @IBAction func onConfig(_ sender: Any) {
        let nib = NSNib(nibNamed: "ConfigView", bundle: nil)
        var objects: NSArray?
        nib?.instantiate(withOwner: nil, topLevelObjects: &objects)
        guard let popOver = objects?.compactMap({ $0 as? NSPopover }).first else {
            fatalError("Failed to load config view")
        }
        let configButtonView = configBarItem.perform(Selector(("_view")))?.retain().takeRetainedValue() as? NSView
        popOver.show(relativeTo: configButtonView!.bounds, of: configButtonView!, preferredEdge: .maxY)
    }
    
    @IBAction func onProcess(_ sender: Any) {
        let background = DispatchQueue(label: "background")
        guard let img = windowContent.inImg.image else {
            return
        }
        configBarItem.isEnabled = false
        pickBarItem.isEnabled = false
        processBarItem.isEnabled = false
        saveBarItem.isEnabled = false
        windowContent.spinner.startAnimation(self)
        windowContent.status.isHidden = true
        windowContent.outImg.image = nil
        
        let style = UserDefaults.standard.string(forKey: "style") ?? "anime"
        let noise = UserDefaults.standard.string(forKey: "noise") ?? "1"
        let scale = UserDefaults.standard.string(forKey: "scale") ?? "2x"
        var modelName = style
        if noise != "none" {
            modelName += "_noise" + noise
        }
        if scale != "none" {
            modelName = "up_" + modelName + "_scale2x"
        }
        modelName += "_model"
        
        let start = Date()
        background.async {
            guard let outImage = Waifu2x.run(img, model: Model(rawValue: modelName)!) else {
                return
            }
            DispatchQueue.main.async {
                self.windowContent.outImg.image = outImage
                debugPrint("\(outImage.size)")
                self.windowContent.spinner.stopAnimation(self)
                self.windowContent.status.isHidden = false
                self.windowContent.status.stringValue = "Time elapsed: \(Date().timeIntervalSince(start))s"
                self.configBarItem.isEnabled = true
                self.pickBarItem.isEnabled = true
                self.processBarItem.isEnabled = true
                self.saveBarItem.isEnabled = true
            }
        }
    }
    
    @IBAction func onSave(_ sender: Any) {
        guard let outImage = windowContent.outImg.image else {
            return
        }
        let dialog = NSSavePanel()
        dialog.allowedFileTypes = ["public.png"]
        dialog.beginSheetModal(for: window!) { (resp) in
            if resp == NSApplication.ModalResponse.OK {
                guard let url = dialog.url else {
                    return
                }
                try! outImage.pngWrite(to: url)
            }
        }
    }
}
