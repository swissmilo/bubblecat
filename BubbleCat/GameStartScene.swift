//
//  GameScene.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/4/16.
//  Copyright (c) 2016 Milo Spirig. All rights reserved.
//

import SpriteKit

class GameStartScene: SKScene {
    
    var livesNode: SKLabelNode = SKLabelNode()
    
    override init(size: CGSize) {
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        // set up node for the background texture
        let backgroundSize = CGSize(width:self.frame.width,height:self.frame.height)
        let backgroundNode = SKSpriteNode(texture: SKTexture(imageNamed:"loadimage"), color: UIColor(), size: backgroundSize)
        backgroundNode.position = CGPoint(x: self.frame.width/2,y: self.frame.height/2)
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
        
        //backgroundColor = UIColor.blackColor()
        
        livesNode = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        livesNode.fontSize = 40;
        livesNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + 70)
        livesNode.fontColor = SKColor.whiteColor()
        livesNode.zPosition = 100;
        livesNode.text = "Tap to Begin"
        addChild(livesNode)
        
        let fadeinout = SKAction.sequence([SKAction.fadeOutWithDuration(0.7), SKAction.fadeInWithDuration(0.7), SKAction.waitForDuration(0.1)])
        livesNode.runAction(SKAction.repeatActionForever(fadeinout))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Called when a touch begins
        
        //self.scene!.view!.paused = false
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
        
        GameScene.levelSelector = GameScene.firstLevel
        
        let newscene = GameScene.unarchiveFromFile("Level\(GameScene.levelSelector)") as! GameScene
        //let newscene = GameScene(size: view!.bounds.size)
        newscene.scaleMode = .AspectFit
        
        self.scene!.view!.presentScene(newscene, transition: transition)
    }
}
