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
    
    weak var currentScene: GameScene?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let scene = GameScene(size: CGSize(width:800, height:800))
        currentScene = scene
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        self.skView!.presentScene(scene)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView!.ignoresSiblingOrder = true
        
        self.skView!.showsFPS = true
        self.skView!.showsNodeCount = true
        
        let menuBar = NSMenu(title:"")
        let app = NSMenu(title: "ChessAI")
        app.addItemWithTitle("About ChessAI", action: nil, keyEquivalent: "")
        app.addItem(NSMenuItem.separatorItem())
        app.addItemWithTitle("Quit", action: Selector("quit:"), keyEquivalent: "q")
        
        let appItem = menuBar.addItemWithTitle("", action: nil, keyEquivalent: "")
        appItem?.submenu = app
        
        let edit = NSMenu.init(title: "Edit")
        edit.addItemWithTitle("Undo", action: Selector("undo"), keyEquivalent: "z")
        
        let heading = menuBar.addItemWithTitle("", action: nil, keyEquivalent: "")
        heading?.submenu = edit
        
        NSApp.mainMenu = menuBar
    }
    
    func undo() {
        currentScene?.undo()
    }
    
    func quit(sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
