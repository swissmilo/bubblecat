//
//  Brick.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/10/16.
//  Copyright © 2016 Milo Spirig. All rights reserved.
//

import Foundation

import Foundation
import SpriteKit

class Brick : SKSpriteNode
{
    static let brickImageName = "brick"
    static let brickTex = SKTexture(imageNamed: Brick.brickImageName)
    
    var isDestructable:Bool
    
    init(brickName:String, brickSize:CGSize, destructable:Bool) {
        
        isDestructable = destructable
        super.init(texture: Brick.brickTex, color: UIColor(), size: brickSize)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: brickSize)
        self.physicsBody!.dynamic = false
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.name = brickName
        
        self.physicsBody!.categoryBitMask = ObstacleCategory
        self.physicsBody!.collisionBitMask = ActorCategory | HookCategory | BallCategory
        self.physicsBody!.contactTestBitMask = ActorCategory | HookCategory | BallCategory
    }
    
    func setBrickColor(color:UIColor) {
        let colorNode = SKSpriteNode(color: color, size: self.size)
        colorNode.colorBlendFactor = 1.0
        colorNode.blendMode = SKBlendMode.Add
        self.addChild(colorNode)
        
        //self.color = color
        //self.colorBlendFactor = 1.0
    }
    
    func destroy() {
        let fadeAway = SKAction.fadeOutWithDuration(0.3)
        let destroy = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeAway, destroy])
        self.runAction(sequence)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}