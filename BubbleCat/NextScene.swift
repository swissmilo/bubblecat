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
    let newscene = GameScene.unarchiveFromFile("Level\(GameScene.levelSelector+1)") as? GameScene
    let fish = Fish(fishName: "fish", fishSize: CGSize(width: 50, height: 25))
    
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
        let backgroundNode = SKSpriteNode(texture: SKTexture(imageNamed:"background"), color: UIColor(), size: backgroundSize)
        backgroundNode.position = CGPoint(x: self.frame.width/2,y: self.frame.height/2)
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
        
        //backgroundColor = UIColor.blackColor()
        
        livesNode = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        livesNode.fontSize = 50;
        livesNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        livesNode.fontColor = SKColor.whiteColor()
        livesNode.zPosition = 100;
        if(newscene != nil) {
            livesNode.text = "Level \(GameScene.levelSelector) Complete!"
        } else {
            livesNode.text = "Game Complete!"
        }
        addChild(livesNode)
        
        //let fish = Fish(fishName: "fish", fishSize: CGSize(width: 50, height: 25))
        fish.position = CGPoint(x: 100, y: 100)
        fish.xScale = -1
        addChild(fish)
        fish.walkFish()
        
        let circle = UIBezierPath(ovalInRect: CGRectMake(50, 50, CGRectGetMaxX(self.frame)-100, CGRectGetMaxY(self.frame)-100))
        let followCircle = SKAction.followPath(circle.CGPath, asOffset: false, orientToPath: false, duration: 10.0)
        fish.runAction(SKAction.repeatActionForever(followCircle))
        // TODO: reverse half way in update function if below mid y point
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Called when a touch begins
        
        //self.scene!.view!.paused = false
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
        
        GameScene.levelSelector += 1
        //let newscene = GameScene.unarchiveFromFile("Level\(GameScene.levelSelector)") as? GameScene
        //let newscene = GameScene(size: view!.bounds.size)
        if(newscene != nil) {
            newscene!.scaleMode = .AspectFit
            self.scene!.view!.presentScene(newscene!, transition: transition)
        } else {
            GameScene.levelSelector = GameScene.firstLevel
            let newgame = GameStartScene(size: view!.bounds.size)
            newgame.scaleMode = .AspectFit
            self.scene!.view!.presentScene(newgame, transition: transition)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if(fish.position.y > CGRectGetMidY(self.frame)) {
            fish.xScale = fabs(fish.xScale)
        } else {
            fish.xScale = -fabs(fish.xScale)
        }
    }
}
