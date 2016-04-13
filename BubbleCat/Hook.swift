//
//  Hook.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/9/16.
//  Copyright © 2016 Milo Spirig. All rights reserved.
//

import Foundation
import SpriteKit

class Hook : SKSpriteNode
{
    static let ropeImageName = "rope"
    static let hookImageName = "anchor"
    static var tiledRope:SKTexture? = nil
    static let hookTex = SKTexture(imageNamed: Hook.hookImageName)
    var ropeNode = SKSpriteNode()
    
    init(hookName:String, ladderHeight:CGFloat) {
        let hookSize = CGSize(width: 10,height: 10)
        
        super.init(texture: Hook.hookTex, color: UIColor(), size: hookSize)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: hookSize)
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.angularDamping = 0
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody!.categoryBitMask = HookCategory
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = BallCategory | ObstacleCategory
        self.name = hookName
        
        let ropeTex = SKTexture(imageNamed: Hook.ropeImageName)
        
        if(Hook.tiledRope == nil) {
        Hook.tiledRope = Hook.setTiledFillTexture(Hook.ropeImageName, tileSize: CGSize(width: ropeTex.size().width, height: ropeTex.size().height), targetSize: CGSize(width: ropeTex.size().width, height: ladderHeight))
        }
        
        ropeNode = SKSpriteNode(texture: Hook.tiledRope)
        ropeNode.size.width = 6
        ropeNode.size.height = ladderHeight
        ropeNode.position.y = -ladderHeight/2
        ropeNode.position.x = 0
        ropeNode.physicsBody = SKPhysicsBody(rectangleOfSize: ropeNode.size)
        ropeNode.physicsBody!.usesPreciseCollisionDetection = true
        ropeNode.physicsBody!.affectedByGravity = false
        ropeNode.physicsBody!.dynamic = false
        ropeNode.physicsBody!.categoryBitMask = HookCategory
        ropeNode.physicsBody!.collisionBitMask = 0
        ropeNode.physicsBody!.contactTestBitMask = BallCategory
        ropeNode.name = "rope"
        self.addChild(ropeNode)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func setTiledFillTexture(imageName: String, tileSize: CGSize, targetSize: CGSize) -> SKTexture {
        
        let targetRef = UIImage(named: imageName)!.CGImage
        
        UIGraphicsBeginImageContext(targetSize)
        let contextRef = UIGraphicsGetCurrentContext()
        CGContextDrawTiledImage(contextRef, CGRect(origin: CGPointZero, size: tileSize), targetRef)
        let tiledTexture = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: tiledTexture)
    }
    
}