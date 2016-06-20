//
//  GameViewController.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/4/16.
//  Copyright (c) 2016 Milo Spirig. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
    
}

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = self.view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
            
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        //let scene = GameScene.unarchiveFromFile("Level\(GameScene.levelSelector)") as! GameScene
        
        let scene = GameStartScene(size: view!.bounds.size)
        
        /* Set the scale mode to scale to fit the window */
        //let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .AspectFit
        
        print("width " + String(view.bounds.size.width))
        print("height " + String(view.bounds.size.height))
        print(UIDevice.currentDevice().name)
        
        skView.presentScene(scene)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("memory warning")
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
