//
//  Ball.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/9/16.
//  Copyright © 2016 Milo Spirig. All rights reserved.
//

//
//  Hook.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/9/16.
//  Copyright © 2016 Milo Spirig. All rights reserved.
//

import Foundation
import SpriteKit

class Ball : SKSpriteNode
{
    static let ballImageName = "ball"
    static let ballTex = SKTexture(imageNamed: Ball.ballImageName)
    var sizeOfBall: ballSizes
    
    enum ballSizes : Int {
        case mini = 0, small, medium, large
    }
    
    init(ballName:String, ballSize:ballSizes) {

        sizeOfBall = ballSize
        super.init(texture: Ball.ballTex, color: UIColor(), size: Ball.getSize(ballSize))
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 1
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.angularDamping = 0
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.name = ballName
        
        self.physicsBody!.categoryBitMask = BallCategory
        self.physicsBody!.collisionBitMask = ActorCategory | HookCategory | ObstacleCategory
        self.physicsBody!.contactTestBitMask = ActorCategory | HookCategory
    }
    
    func setBallColor(color:UIColor) {
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    static func divide(ball: Ball) -> Ball {
        assert(ball.sizeOfBall != ballSizes.mini)
        let newBall = Ball(ballName: ball.name!, ballSize: ballSizes(rawValue: ball.sizeOfBall.rawValue - 1)!)
        newBall.setBallColor(ball.color)
        return newBall
    }
    
    static func getPushVelocity(ballSize:ballSizes) -> CGFloat {
        switch ballSize {
        case ballSizes.mini: return 1
        case ballSizes.small: return 3
        case ballSizes.medium: return 5
        case ballSizes.large: return 10
        }
    }
    
    static func getSize(ballSize:ballSizes) -> CGSize {
        switch ballSize {
            case ballSizes.mini: return CGSize(width: 10,height: 10)
            case ballSizes.small: return CGSize(width: 20,height: 20)
            case ballSizes.medium: return CGSize(width: 45,height: 45)
            case ballSizes.large: return CGSize(width: 60,height: 60)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}