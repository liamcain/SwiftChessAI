//
//  AppDelegate.swift
//  ChessAI
//
//  Created by Liam Cain on 10/26/15.
//  Copyright (c) 2015 Pillowfort Architects. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    override func awakeFromNib() {
        let bar = NSStatusBar.systemStatusBar()
        let statusItem = bar.statusItemWithLength(CGFloat(NSVariableStatusItemLength))
        
        statusItem.title = "Edit"
        statusItem.highlightMode = true
        statusItem.menu = NSMenu()
        statusItem.enabled = true
        
        let newItem : NSMenuItem = NSMenuItem(title: "Undo", action: Selector("Undo:"), keyEquivalent: "90")
        statusItem.menu!.addItem(newItem)
        statusItem.menu!.addItem(NSMenuItem.separatorItem())
        
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let scene = GameScene(size: CGSize(width:800, height:800))
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        self.skView!.presentScene(scene)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView!.ignoresSiblingOrder = true
        
        self.skView!.showsFPS = true
        self.skView!.showsNodeCount = true
        
    }
    
    func undo(sender: AnyObject) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
