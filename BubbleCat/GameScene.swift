//
//  GameScene.swift
//  BubbleCat
//
//  Created by Milo Spirig on 4/4/16.
//  Copyright (c) 2016 Milo Spirig. All rights reserved.
//

import SpriteKit

let BallCategory   : UInt32 = 0x1 << 1
let HookCategory : UInt32 = 0x1 << 2
let ActorCategory  : UInt32 = 0x1 << 3
let ObstacleCategory : UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //let backgroundMusic = SKAudioNode(fileNamed: "NewYork.mp3")
    
    let swipeAreaName = "swipe"
    let buttonAreaName = "button"
    let ballName = "ball"
    var isFingerOnSwipe = false
    
    var controlPanelHeight:CGFloat = 0
    var controlPanelWidth:CGFloat = 0
    
    var swipeNode: SKShapeNode = SKShapeNode()
    var buttonNode: SKShapeNode = SKShapeNode()
    var actorNode: SKSpriteNode = SKSpriteNode()
    var countdownNode: SKLabelNode = SKLabelNode()
    var livesNode: SKLabelNode = SKLabelNode()
    
    var walkFrames = [SKTexture]()
    var actorWalkingDirectionMultiplier : CGFloat = 1
    var isActorMoving : Bool = false
    
    var gameRunning = false
    var startCountdown = false
    var startTime:CFTimeInterval = CFTimeInterval()
    
    var timeLimit = 100
    var lives = 3
    
    override init(size: CGSize) {
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        view.showsPhysics = true
        
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVectorMake(0.0, -7);
        physicsWorld.speed = 1
        
        backgroundColor = UIColor.whiteColor()
        
        controlPanelHeight = 70
        controlPanelWidth = self.frame.width * 0.85
        
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x:self.frame.minX,y:self.frame.minY+controlPanelHeight,width:self.frame.maxX,height:self.frame.maxX-controlPanelHeight))
        physicsBody!.friction = 0
        physicsBody!.categoryBitMask = ObstacleCategory
        //physicsBody!.dynamic = false
        
        //backgroundMusic.autoplayLooped = true
        //addChild(backgroundMusic)
        
        
        let panelSize = CGSize(width:controlPanelWidth,height:controlPanelHeight)
        swipeNode = SKShapeNode(rectOfSize: panelSize)
        swipeNode.position = CGPoint(x: panelSize.width/2,y: panelSize.height/2)
        swipeNode.zPosition = 100
        swipeNode.fillColor = UIColor.redColor()
        swipeNode.physicsBody = SKPhysicsBody(rectangleOfSize: panelSize)
        swipeNode.physicsBody!.dynamic = false
        swipeNode.name = swipeAreaName
        //print(panelSize)
        addChild(swipeNode)

        
        let buttonSize = CGSize(width:self.frame.size.width - controlPanelWidth,height:controlPanelHeight)
        buttonNode = SKShapeNode(rectOfSize: buttonSize)
        buttonNode.position = CGPoint(x: controlPanelWidth + buttonSize.width/2,y: buttonSize.height/2)
        buttonNode.zPosition = 100
        buttonNode.fillColor = UIColor.blueColor()
        buttonNode.physicsBody = SKPhysicsBody(rectangleOfSize: buttonSize)
        buttonNode.physicsBody!.dynamic = false
        buttonNode.name = buttonAreaName
        //print(panelSize)
        addChild(buttonNode)
  
        
        let actorAnimatedAtlas = SKTextureAtlas(named: "BearImages")
        
        let numImages = actorAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let actorTextureName = "bear\(i)"
            walkFrames.append(actorAnimatedAtlas.textureNamed(actorTextureName))
        }
        
        actorNode = SKSpriteNode(texture: walkFrames[0])
        actorNode.size.width = 70
        actorNode.size.height = 50
        actorNode.position = CGPoint(x:self.frame.size.width/2-200, y:controlPanelHeight + actorNode.size.height / 2)

        //actorNode.physicsBody = SKPhysicsBody(rectangleOfSize: actorNode.size)
        actorNode.physicsBody = SKPhysicsBody(texture: walkFrames[0], size: actorNode.size)
        actorNode.physicsBody!.allowsRotation = false
        actorNode.physicsBody!.friction = 0
        actorNode.physicsBody!.restitution = 0
        actorNode.physicsBody!.linearDamping = 0
        actorNode.physicsBody!.angularDamping = 0
        actorNode.physicsBody!.dynamic = false
        actorNode.physicsBody!.usesPreciseCollisionDetection = true
        actorNode.physicsBody!.categoryBitMask = ActorCategory
        actorNode.physicsBody!.collisionBitMask = ObstacleCategory
        actorNode.physicsBody!.contactTestBitMask = BallCategory | ObstacleCategory
        addChild(actorNode)
    }
    
    
    func walkActor() {
        if(isActorMoving == false) {
            isActorMoving = true
            
            actorNode.runAction(SKAction.repeatActionForever(
                SKAction.animateWithTextures(walkFrames,
                    timePerFrame: 0.1,
                    resize: false,
                    restore: true)),
                                withKey:"walkingInPlace")
        }
    }
    
    func stopWalkingActor() {
        if(isActorMoving) {
            actorNode.removeActionForKey("walkingInPlace")
            isActorMoving = false
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       // Called when a touch begins
        
        if(gameRunning == false) {
            beginGame()
        }
        
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
        
        let touch:UITouch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        if let body = physicsWorld.bodyAtPoint(touchLocation) {
            if body.node!.name == swipeAreaName {
                    isFingerOnSwipe = false
                    stopWalkingActor()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first{
            let touchLocation = touch.locationInNode(self)
            
            if isFingerOnSwipe {

                if let body = physicsWorld.bodyAtPoint(touchLocation) {
                    if body.node!.name == swipeAreaName {
                        
                        let previousLocation = touch.previousLocationInNode(self)
                        
                        let swipeChange = (touchLocation.x - previousLocation.x) * 1.5
                        
                        actorWalkingDirectionMultiplier = swipeChange > 0 ? -1 : 1
                        actorNode.xScale = fabs(actorNode.xScale) * actorWalkingDirectionMultiplier
                        walkActor()
                        
                        let action = SKAction.moveByX(swipeChange, y:0, duration: 0.1)
                        
                        actorNode.runAction(action)
                    }
                }
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
            createBall((firstBody.node?.position)!, scale: (firstBody.node?.xScale)! / 1.5).physicsBody!.applyImpulse(CGVectorMake(5, 0))
            createBall((firstBody.node?.position)!, scale: (firstBody.node?.xScale)! / 1.5).physicsBody!.applyImpulse(CGVectorMake(-5, 0))
            }
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == HookCategory && secondBody.categoryBitMask == ObstacleCategory {
            
            firstBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == ActorCategory {
            
            lives -= 1
            livesNode.text = "\(lives) Lifes"
            if(lives <= 0) {
                beginGameover()
            }
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
        newballNode.physicsBody!.collisionBitMask = ActorCategory | HookCategory | ObstacleCategory
        newballNode.physicsBody!.contactTestBitMask = ActorCategory | HookCategory
        
        addChild(newballNode)
        return newballNode
    }
    
    func createShot() {
        let shotSize = CGSize(width: 10,height: 10)
        //let shotNode = SKShapeNode(rectOfSize: shotSize)
        let shotNode = SKSpriteNode(imageNamed:"anchor")
        shotNode.position = CGPoint(x: actorNode.position.x, y: actorNode.position.y+30)
        //shotNode.fillColor = UIColor.redColor()
        shotNode.physicsBody = SKPhysicsBody(rectangleOfSize: shotSize)
        shotNode.physicsBody!.allowsRotation = false
        shotNode.physicsBody!.friction = 0
        shotNode.physicsBody!.restitution = 0
        shotNode.physicsBody!.linearDamping = 0
        shotNode.physicsBody!.angularDamping = 0
        shotNode.physicsBody!.usesPreciseCollisionDetection = true
        shotNode.physicsBody?.affectedByGravity = false
        shotNode.physicsBody!.categoryBitMask = HookCategory
        shotNode.physicsBody!.collisionBitMask = 0
        shotNode.physicsBody!.contactTestBitMask = BallCategory | ObstacleCategory
        shotNode.name = "hook"
        addChild(shotNode)
        
        let rope = SKSpriteNode(imageNamed:"rope")
        rope.size.height = 50//self.view!.frame.height
        rope.position.y = -rope.size.height
        rope.position.x = 0
        rope.physicsBody = SKPhysicsBody(rectangleOfSize: rope.size)
        rope.physicsBody!.allowsRotation = false
        rope.physicsBody!.friction = 0
        rope.physicsBody!.restitution = 0
        rope.physicsBody!.linearDamping = 0
        rope.physicsBody!.angularDamping = 0
        rope.physicsBody!.usesPreciseCollisionDetection = true
        rope.physicsBody?.affectedByGravity = false
        rope.physicsBody?.dynamic = false
        rope.physicsBody!.categoryBitMask = HookCategory
        rope.physicsBody!.collisionBitMask = 0
        rope.physicsBody!.contactTestBitMask = BallCategory
        rope.name = "rope"
        shotNode.addChild(rope)
        
        /*physicsWorld.addJoint(SKPhysicsJointFixed.jointWithBodyA(shotNode.physicsBody!,
                       bodyB: rope.physicsBody!,
                       anchor: CGPointMake(shotNode.position.x, shotNode.position.y)))*/
        
        shotNode.physicsBody!.applyImpulse(CGVectorMake(0, 1.2))
        
/* 
 CGSize mergedSize = CGSizeMake(WIDTH_HERO, HEIGHT_HERO);
 UIGraphicsBeginImageContextWithOptions(mergedSize, NO, 0.0f);
 
 [textureImage1 drawInRect:CGRectMake(0, 0, WIDTH_HERO, textureImage1.size.height)];
 [textureImage2 drawInRect:CGRectMake(0, 40, WIDTH_HERO, textureImage2.size.height)];
 [textureImage3 drawInRect:CGRectMake(0, 0, WIDTH_HERO, textureImage3.size.height)];
 
 UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 [self setTexture:[SKTexture textureWithImage:mergedImage]];
 */
    }
    
    func isGameFinished() -> Bool {
        if (gameRunning && (self.childNodeWithName(ballName) == nil)) {
            //let ballNode = createBall(CGPoint(x:self.frame.size.width/2, y:self.frame.size.height/2), scale: 1.0)
            //ballNode.physicsBody!.applyImpulse(CGVectorMake(5, 0))
            print("no more balls")
            return true
        }
        return false
    }
    
    func beginGame() {
        
        countdownNode = SKLabelNode(fontNamed: "Futura-Medium")
        countdownNode.fontSize = 50;
        countdownNode.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMaxY(self.frame)*0.85)
        countdownNode.fontColor = SKColor.blackColor()
        countdownNode.name = "countDown";
        countdownNode.zPosition = 100;
        addChild(countdownNode)
        
        livesNode = SKLabelNode(fontNamed: "Futura-Medium")
        livesNode.fontSize = 50;
        livesNode.position = CGPointMake(CGRectGetMidX(self.frame)+100, CGRectGetMaxY(self.frame)*0.85)
        livesNode.fontColor = SKColor.blackColor()
        livesNode.name = "lives";
        livesNode.zPosition = 100;
        livesNode.text = "\(lives) Lifes"
        addChild(livesNode)
        
        let ballNode = createBall(CGPoint(x:self.frame.size.width/2+50, y:self.frame.size.height/2+100), scale: 2.0)
        ballNode.physicsBody!.applyImpulse(CGVectorMake(5, 0))
        
        let ballNode2 = createBall(CGPoint(x:self.frame.size.width/2-50, y:self.frame.size.height/2+100), scale: 2.0)
        ballNode2.physicsBody!.applyImpulse(CGVectorMake(-5, 0))
        
        startCountdown = true
        gameRunning = true
    }
    
    func beginGameover() {
        gameRunning = false
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)

        let newscene = GameoverScene(size: view!.bounds.size)
        newscene.scaleMode = .AspectFit

        self.scene!.view!.presentScene(newscene, transition: transition)
    }
    
    func beginNextLevel() {
        gameRunning = false
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
        
        let newscene = NextScene(size: view!.bounds.size)
        newscene.scaleMode = .AspectFit
        
        self.scene!.view!.presentScene(newscene, transition: transition)
    }
    
    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("hook", usingBlock: {
            (hookChild: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in

            //let hookChild = self.childNodeWithName("hook")
            if(hookChild != nil) {
                let ropeChild = hookChild!.childNodeWithName("rope")
                
                if(ropeChild != nil && hookChild != nil) {
                    let height = (ropeChild as! SKSpriteNode).size.height
                    ropeChild!.position.y = -height
                }
            }
        })
    }

   
    override func update(currentTime: CFTimeInterval) {
        if(isGameFinished()) {
            beginNextLevel()
        }
        
        let maxSpeed: CGFloat = 700.0
        let hyperSpeed: CGFloat = 1000.0
        
        // game countdown
        if(startCountdown) {
            startTime = currentTime
            startCountdown = false
        }
        let countDown = timeLimit - (Int)(currentTime-startTime)
        if(countDown >= 0) {
            countdownNode.text = String(countDown)
        }
        else {
            if(gameRunning) {
                beginGameover()
            }
        }
        
        // keep actor inside the x-boundary of the screen
        if(actorNode.position.x <= actorNode.size.width/2) {
            actorNode.position.x = actorNode.size.width/2
        }
        else if(actorNode.position.x >= frame.size.width-actorNode.size.width/2) {
            actorNode.position.x = frame.size.width-actorNode.size.width/2
        }
        
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

    
   /*
    func convert(point: CGPoint)->CGPoint {
        return self.view!.convertPoint(CGPoint(x: point.x, y:self.view!.frame.height-point.y), toScene:self)
    }*/
}
