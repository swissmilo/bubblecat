//
//  GameScene.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/4/16.
//  Copyright (c) 2016 Milo Spirig. All rights reserved.
//

import SpriteKit

class NextScene: SKScene {
    
    var livesNode: SKLabelNode = SKLabelNode()
    
    override init(size: CGSize) {
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        backgroundColor = UIColor.greenColor()
        
        livesNode = SKLabelNode(fontNamed: "Futura-Medium")
        livesNode.fontSize = 100;
        livesNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        livesNode.fontColor = SKColor.blackColor()
        livesNode.zPosition = 100;
        livesNode.text = "WIN"
        addChild(livesNode)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Called when a touch begins
        
        //self.scene!.view!.paused = false
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
        
        let newscene = GameScene.unarchiveFromFile("Level1") as! GameScene
        //let newscene = GameScene(size: view!.bounds.size)
        newscene.scaleMode = .AspectFit
        
        self.scene!.view!.presentScene(newscene, transition: transition)
    }
}
