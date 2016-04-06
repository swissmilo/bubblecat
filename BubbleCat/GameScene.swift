//
//  GameScene.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/4/16.
//  Copyright (c) 2016 Milo Spirig. All rights reserved.
//

import SpriteKit

let BallCategory   : UInt32 = 0x1 << 0
let HookCategory : UInt32 = 0x1 << 1
let ActorCategory  : UInt32 = 0x1 << 2
let ObstacleCategory : UInt32 = 0x1 << 3

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //let backgroundMusic = SKAudioNode(fileNamed: "NewYork.mp3")
    
    let swipeAreaName = "swipe"
    let buttonAreaName = "button"
    let ballName = "ball"
    var isFingerOnSwipe = false
    
    let controlPanelHeight:CGFloat = 75
    let controlPanelWidth:CGFloat = 600
    
    var swipeNode: SKShapeNode
    var buttonNode: SKShapeNode
    var actorNode: SKSpriteNode
    
    override init(size: CGSize) {
        
        swipeNode = SKShapeNode()
        buttonNode = SKShapeNode()
        actorNode = SKSpriteNode()
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        view.showsPhysics = true
        
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVectorMake(0.0, -9.8);
        physicsWorld.speed = 1
        
        backgroundColor = UIColor.whiteColor()
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x:self.frame.minX,y:self.frame.minY+controlPanelHeight,width:self.frame.maxX,height:self.frame.maxX-controlPanelHeight))
        physicsBody!.friction = 0
        physicsBody!.categoryBitMask = ObstacleCategory
        //physicsBody!.dynamic = false
        
        //backgroundMusic.autoplayLooped = true
        //addChild(backgroundMusic)
        
        
        let panelSize = CGSize(width:controlPanelWidth,height:controlPanelHeight)
        swipeNode = SKShapeNode(rectOfSize: panelSize)
        swipeNode.position = CGPoint(x: panelSize.width/2,y: panelSize.height/2)
        swipeNode.fillColor = UIColor.redColor()
        swipeNode.physicsBody = SKPhysicsBody(rectangleOfSize: panelSize)
        swipeNode.physicsBody!.dynamic = false
        swipeNode.name = swipeAreaName
        //print(panelSize)
        addChild(swipeNode)

        
        let buttonSize = CGSize(width:self.frame.size.width - controlPanelWidth,height:controlPanelHeight)
        buttonNode = SKShapeNode(rectOfSize: buttonSize)
        buttonNode.position = CGPoint(x: controlPanelWidth + buttonSize.width/2,y: buttonSize.height/2)
        buttonNode.fillColor = UIColor.blueColor()
        buttonNode.physicsBody = SKPhysicsBody(rectangleOfSize: buttonSize)
        buttonNode.physicsBody!.dynamic = false
        buttonNode.name = buttonAreaName
        //print(panelSize)
        addChild(buttonNode)
  
        actorNode = SKSpriteNode(imageNamed:"actor")
        actorNode.position = CGPoint(x:self.frame.size.width/2-200, y:controlPanelHeight + actorNode.size.height / 2)
        
        actorNode.physicsBody = SKPhysicsBody(rectangleOfSize: actorNode.size)
        actorNode.physicsBody!.allowsRotation = false
        actorNode.physicsBody!.friction = 0
        actorNode.physicsBody!.restitution = 0
        actorNode.physicsBody!.linearDamping = 0
        actorNode.physicsBody!.angularDamping = 0
        actorNode.physicsBody!.dynamic = false
        actorNode.physicsBody!.usesPreciseCollisionDetection = true
        actorNode.physicsBody!.categoryBitMask = ActorCategory
        
        addChild(actorNode)
        
        
        let ballNode = createBall(CGPoint(x:self.frame.size.width/2, y:self.frame.size.height/2), scale: 1.0)
        ballNode.physicsBody!.applyImpulse(CGVectorMake(5, 0))
      
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       // Called when a touch begins
        
        let touch:UITouch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        if let body = physicsWorld.bodyAtPoint(touchLocation) {
            if body.node!.name == swipeAreaName {
                print("Swipe began")
                isFingerOnSwipe = true
            }
            else if body.node!.name == buttonAreaName {
                print("Button")
                createShot()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        isFingerOnSwipe = false
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first{
            
            if isFingerOnSwipe {

                let touchLocation = touch.locationInNode(self)
                let previousLocation = touch.previousLocationInNode(self)
                
                let swipeChange = (touchLocation.x - previousLocation.x)
                
                let action = SKAction.moveByX(swipeChange, y:0, duration: 0.1)
                
                actorNode.runAction(action)
            }
            
        }
        super.touchesMoved(touches, withEvent: event)
    }

    func didBeginContact(contact: SKPhysicsContact) {

        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        

        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == HookCategory {
            
            if((firstBody.node?.xScale)! > 0.9) {
            createBall((firstBody.node?.position)!, scale: (firstBody.node?.xScale)! / 2.0).physicsBody!.applyImpulse(CGVectorMake(5, 0))
            createBall((firstBody.node?.position)!, scale: (firstBody.node?.xScale)! / 2.0).physicsBody!.applyImpulse(CGVectorMake(-5, 0))
            }
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == HookCategory && secondBody.categoryBitMask == ObstacleCategory {
            
            firstBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == ActorCategory {
            
            print("game over")
            /*if let mainView = view {
                let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
                mainView.presentScene(gameOverScene)
            }*/
        }
    }
    
    func createBall(ballposition: CGPoint, scale:CGFloat) -> SKSpriteNode {
        let newballNode = SKSpriteNode(imageNamed:"ball")
        newballNode.xScale = scale
        newballNode.yScale = scale
        newballNode.position = ballposition
        
        newballNode.physicsBody = SKPhysicsBody(circleOfRadius: newballNode.size.width/2)
        newballNode.physicsBody!.allowsRotation = false
        newballNode.physicsBody!.friction = 0
        newballNode.physicsBody!.restitution = 1
        newballNode.physicsBody!.linearDamping = 0
        newballNode.physicsBody!.angularDamping = 0
        newballNode.physicsBody!.usesPreciseCollisionDetection = true
        newballNode.name = ballName
        
        newballNode.physicsBody!.categoryBitMask = BallCategory
        newballNode.physicsBody!.contactTestBitMask = ActorCategory | HookCategory
        
        addChild(newballNode)
        return newballNode
    }
    
    func createShot() {
        let shotSize = CGSize(width: 10,height: 10)
        let shotNode = SKShapeNode(rectOfSize: shotSize)
        shotNode.position = CGPoint(x: actorNode.position.x, y: actorNode.position.y+30)
        shotNode.fillColor = UIColor.redColor()
        shotNode.physicsBody = SKPhysicsBody(rectangleOfSize: shotSize)
        shotNode.physicsBody!.allowsRotation = false
        shotNode.physicsBody!.friction = 0
        shotNode.physicsBody!.restitution = 0
        shotNode.physicsBody!.linearDamping = 0
        shotNode.physicsBody!.angularDamping = 0
        shotNode.physicsBody!.usesPreciseCollisionDetection = true
        shotNode.physicsBody?.affectedByGravity = false
        shotNode.physicsBody!.categoryBitMask = HookCategory
        shotNode.physicsBody!.contactTestBitMask = BallCategory | ObstacleCategory
        shotNode.name = "hook"
        addChild(shotNode)
        
        shotNode.physicsBody!.applyImpulse(CGVectorMake(0, 2))
    }
    
    func isGameOver() -> Bool {
        if (self.childNodeWithName(ballName) == nil) {
            return false
        }
        else {
            
            print("win")
            return true
        }
    }

   
    override func update(currentTime: CFTimeInterval) {
        isGameOver()
        
        let maxSpeed: CGFloat = 700.0
        let hyperSpeed: CGFloat = 1000.0
        
        //let ball = self.childNodeWithName(ballName) as! SKSpriteNode
        self.enumerateChildNodesWithName(ballName, usingBlock: {
            (ball: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in

            let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
            
            if speed > hyperSpeed {
                //print(speed)
                ball.physicsBody!.velocity.dx /= 2
                ball.physicsBody!.velocity.dx /= 2
            }
            
            if speed > maxSpeed {
                //print(speed)
                ball.physicsBody!.linearDamping = 0.4
            }
            else {
                ball.physicsBody!.linearDamping = 0.0
            }
            
        })
        
    }
}
