//
//  Actor.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/15/16.
//  Copyright © 2016 Milo Spirig. All rights reserved.
//

import Foundation
import SpriteKit

class Actor : SKSpriteNode
{
    static let actorImageName = "actor"
    static let actorTex = SKTexture(imageNamed: Actor.actorImageName)
    static var walkFrames = [SKTexture]()
    //var actorWalkingDirectionMultiplier : CGFloat = 1
    var isActorMoving : Bool = false
    
    init(actorName:String, actorSize:CGSize) {
     
        if(Actor.walkFrames.count == 0) {
            //Actor.walkFrames.append(Actor.actorTex)
            let actorAnimatedAtlas = SKTextureAtlas(named: "HunterImages")
            let numImages = actorAnimatedAtlas.textureNames.count
            for i in 1...numImages {
                let actorTextureName = "hunter\(i)"
                Actor.walkFrames.append(actorAnimatedAtlas.textureNamed(actorTextureName))
            }
        }

        //super.init(texture: Actor.actorTex, color: UIColor(), size: actorSize)
        super.init(texture: Actor.actorTex, color: UIColor(), size: actorSize)

        self.name = actorName
        self.zPosition = 101
        
        // TODO create different physics bodies for each frame
        //self.physicsBody = SKPhysicsBody(texture: Actor.walkFrames[0], size: self.size)
        
        // adjust width of collision area because the width of the image includes the walking animation
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: actorSize.width*0.6, height: actorSize.height))
        //self.physicsBody = SKPhysicsBody(circleOfRadius: actorSize.height/2)
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.angularDamping = 0
        self.physicsBody!.dynamic = false
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.categoryBitMask = ActorCategory
        self.physicsBody!.collisionBitMask = ObstacleCategory
        self.physicsBody!.contactTestBitMask = BallCategory | ObstacleCategory
    }
    
    func walkActor() {
        if(isActorMoving == false) {
            isActorMoving = true
            
            // TODO adjust walking speed dependent on distance
            self.runAction(SKAction.repeatActionForever(
                SKAction.animateWithTextures(Actor.walkFrames,
                    timePerFrame: 0.1,
                    resize: false,
                    restore: true)),
                                withKey:"walkingInPlace")
        }
    }
    
    func stopWalkingActor() {
        if(isActorMoving) {
            self.removeActionForKey("walkingInPlace")
            isActorMoving = false
        }
        self.texture = Actor.actorTex
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        //fatalError("init(coder:) has not been implemented")
    }
}