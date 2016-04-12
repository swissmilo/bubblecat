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
        case mini = 1, small=2, medium=3, large=4
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
    
    func checkBounce() {
        
        // TODO: Check bounce height and x-velocity to be constant per ball type
        
        let maxSpeed: CGFloat = 600.0
        let hyperSpeed: CGFloat = 900.0
        
        let speed = sqrt(physicsBody!.velocity.dx * physicsBody!.velocity.dx + physicsBody!.velocity.dy * physicsBody!.velocity.dy)
        
        if speed > hyperSpeed {
            //print(speed)
            physicsBody!.velocity.dx /= 2
            physicsBody!.velocity.dx /= 2
        }
        
        if speed > maxSpeed {
            //print(speed)
            physicsBody!.linearDamping = 0.4
        }
        else {
            physicsBody!.linearDamping = 0.0
        }
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
            case ballSizes.mini: return CGSize(width: 15,height: 15)
            case ballSizes.small: return CGSize(width: 25,height: 25)
            case ballSizes.medium: return CGSize(width: 45,height: 45)
            case ballSizes.large: return CGSize(width: 60,height: 60)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        sizeOfBall = Ball.ballSizes.mini
        super.init(coder: aDecoder)!
        //fatalError("init(coder:) has not been implemented")
    }
}