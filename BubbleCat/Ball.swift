//
//  Ball.swift
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
    var lastVelocityX: CGFloat = 0
    var timeStopVelocity: CGVector = CGVector()
    
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
        self.physicsBody!.contactTestBitMask = ActorCategory | HookCategory | ObstacleCategory
    }
    
    func setBallColor(color:UIColor) {
        
        self.color = color
        
        self.colorBlendFactor = 1.0
        self.alpha = 0.6
        
        self.blendMode = SKBlendMode.Alpha
        
        /*let colorRGB = CoreImage.CIColor(color: color)
        
        let shader = SKShader(fileNamed: "alphachannel.fsh")
        shader.uniforms = [
            SKUniform(name: "size", floatVector3: GLKVector3Make(Float(Ball.ballTex.size().width), Float(Ball.ballTex.size().height), 0)),
            SKUniform(name: "color", floatVector3: GLKVector3Make(Float(colorRGB.red), Float(colorRGB.green), Float(colorRGB.blue)))
        ]
        self.shader = shader*/
        
        /*let cropMask = SKCropNode()
        cropMask.maskNode = SKSpriteNode(texture: Ball.ballTex)
        cropMask.alpha = 1
        self.addChild(cropMask)
        
        
        let colorNode = SKSpriteNode(color: color, size: self.size)
        colorNode.colorBlendFactor = 1.0
        //colorNode.alpha = 0
        colorNode.blendMode = SKBlendMode.Add
        cropMask.addChild(colorNode)*/
        
        //self.color = color
        //self.colorBlendFactor = 1.0
        //self.blendMode = SKBlendMode.Add
        // let action = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1, duration: 1)
    }
    
    func checkBounce() {
        
        // TODO: Check bounce height and x-velocity to be constant per ball type
        
        // if ball is going too fast because it hits a sharp corner, slow it down into an acceptable range
        let maxSpeed: CGFloat = 500.0
        let hyperSpeed: CGFloat = 800.0
        
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
    
    func checkGroundVelocity() {
        physicsBody?.velocity.dy = getMinVelocityY()
    }
    
    static func divide(ball: Ball, name:String) -> Ball {
        assert(ball.sizeOfBall != ballSizes.mini)
        let newBall = Ball(ballName: name, ballSize: ballSizes(rawValue: ball.sizeOfBall.rawValue - 1)!)
        newBall.setBallColor(ball.color)
        return newBall
    }
    
    func getMinVelocityY() -> CGFloat {
        switch sizeOfBall {
        case ballSizes.mini: return 380
        case ballSizes.small: return 420
        case ballSizes.medium: return 500
        case ballSizes.large: return 600
        }
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