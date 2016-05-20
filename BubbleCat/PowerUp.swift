//
//  PowerUp.swift
//  BubbleCat
//
//  Created by Milo Spirig on 5/19/16.
//  Copyright © 2016 Milo Spirig. All rights reserved.
//

//
//  Actor.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/15/16.
//  Copyright © 2016 Milo Spirig. All rights reserved.
//

import Foundation
import SpriteKit

class PowerUp : SKSpriteNode
{
    enum powerupType : Int {
        case none=0, extraLife = 1, invincible=2, staticHook=3, doubleHook=4, timeStop=5, dynamite=6
    }
    
    static let showTime:Double = 4
    static let powerupImageNames = "powerup_"
    static var powerupImages = [SKTexture]()
    
    static var active:powerupType = powerupType.none
    var powerupId:powerupType
    
    init(powerupName:String, powerupSize:CGSize, type:powerupType) {
        
        if(PowerUp.powerupImages.count == 0) {
            for i in 1...6 {
                PowerUp.powerupImages.append(SKTexture(imageNamed: "\(PowerUp.powerupImageNames)\(i)"))
            }
        }
        
        powerupId = type
        super.init(texture: PowerUp.powerupImages[type.rawValue-1], color: UIColor(), size: powerupSize)

        self.name = powerupName
        self.zPosition = 2
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: powerupSize)
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.angularDamping = 0
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.categoryBitMask = PowerupCategory
        self.physicsBody!.collisionBitMask = ActorCategory | ObstacleCategory
        self.physicsBody!.contactTestBitMask = ActorCategory | ObstacleCategory
    }
    
    func activate() {
        PowerUp.active = powerupId
    }
    
    func deactivate() {
        PowerUp.active = powerupType.none
    }
    
    required init(coder aDecoder: NSCoder) {
        powerupId = powerupType.extraLife
        super.init(coder: aDecoder)!
        //fatalError("init(coder:) has not been implemented")
    }
}