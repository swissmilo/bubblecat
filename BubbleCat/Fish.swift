//
//  Fish.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/15/16.
//  Copyright © 2016 Milo Spirig. All rights reserved.
//

import Foundation
import SpriteKit

class Fish : SKSpriteNode
{
    static let fishImageName = "fish"
    static var walkFrames = [SKTexture]()
    var isFishMoving : Bool = false
    
    init(fishName:String, fishSize:CGSize) {
     
        if(Fish.walkFrames.count == 0) {
            let fishAnimatedAtlas = SKTextureAtlas(named: "FishImages")
            let numImages = fishAnimatedAtlas.textureNames.count
            for i in 1...numImages {
                let fishTextureName = "nemo\(i)"
                Fish.walkFrames.append(fishAnimatedAtlas.textureNamed(fishTextureName))
            }
        }

        super.init(texture: Fish.walkFrames[0], color: UIColor(), size: fishSize)

        self.name = fishName
        self.zPosition = 1
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: fishSize.width, height: fishSize.height))
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.angularDamping = 0
        self.physicsBody!.dynamic = false
    }
    
    func walkFish() {
        if(isFishMoving == false) {
            isFishMoving = true
            
            // TODO adjust walking speed dependent on distance
            self.runAction(SKAction.repeatActionForever(
                SKAction.animateWithTextures(Fish.walkFrames,
                    timePerFrame: 0.1,
                    resize: false,
                    restore: true)),
                                withKey:"walkingInPlace")
        }
    }
    
    func stopWalkingFish() {
        if(isFishMoving) {
            self.removeActionForKey("walkingInPlace")
            isFishMoving = false
        }
        self.texture = Actor.actorTex
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        //fatalError("init(coder:) has not been implemented")
    }
}