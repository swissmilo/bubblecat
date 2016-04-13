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
    static let popSound = SKAudioNode(fileNamed: "blop.mp3")

    static let buttonImageName = "button"
    static let buttonTex = SKTexture(imageNamed: GameScene.buttonImageName)
    static let sliderImageName = "slider"
    static let sliderTex = SKTexture(imageNamed: GameScene.sliderImageName)
    
    let swipeAreaName = "swipe"
    let buttonAreaName = "button"
    let ballName = "ball"
    var isFingerOnSwipe = false
    
    var controlPanelHeight:CGFloat = 0
    var controlPanelWidth:CGFloat = 0
    
    var backgroundNode: SKSpriteNode = SKSpriteNode()
    var swipeNode: SKSpriteNode = SKSpriteNode()
    var buttonNode: SKSpriteNode = SKSpriteNode()
    var actorNode: SKSpriteNode = SKSpriteNode()
    var countdownNode: SKLabelNode = SKLabelNode()
    var livesNode: SKLabelNode = SKLabelNode()
    var gameNode: SKNode = SKNode()
    
    var walkFrames = [SKTexture]()
    var tiledRope = SKTexture()
    var actorWalkingDirectionMultiplier : CGFloat = 1
    var isActorMoving : Bool = false
    
    var gameRunning = false
    var startCountdown = false
    var startTime:CFTimeInterval = CFTimeInterval()
    
    var timeLimit = 100
    var lives = 3
    
    var hooks = [Hook]()
    
    override init(size: CGSize) {
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        print("init was called")
        
        //view.showsPhysics = true
        //self.scene!.view!.paused = true
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVectorMake(0.0, -7);
        physicsWorld.speed = 1
        
        //backgroundColor = UIColor.whiteColor()
        /*
        controlPanelHeight = 70
        controlPanelWidth = self.frame.width * 0.85
        
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x:self.frame.minX,y:self.frame.minY+controlPanelHeight,width:self.frame.maxX,height:self.frame.maxY-controlPanelHeight))
        /*print("x: \(self.frame.minX)")
        print("y: \(self.frame.minY+controlPanelHeight)")
        print("height: \(self.frame.maxX-controlPanelHeight-50)")
        print("height2: \(self.frame.height)")
        print("width: \(self.frame.maxX)")*/
        physicsBody!.friction = 0
        physicsBody!.categoryBitMask = ObstacleCategory
        //physicsBody!.dynamic = false
        
        //backgroundMusic.autoplayLooped = true
        //addChild(backgroundMusic)
        popSound.autoplayLooped = false
        addChild(popSound)

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
        */
        
        setupLayout()
        
        let actorAnimatedAtlas = SKTextureAtlas(named: "BearImages")
        
        let numImages = actorAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let actorTextureName = "bear\(i)"
            walkFrames.append(actorAnimatedAtlas.textureNamed(actorTextureName))
        }
        
        actorNode = SKSpriteNode(texture: walkFrames[0])
        actorNode.size.width = 70
        actorNode.size.height = 50
        actorNode.zPosition = 1
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
        
        //let spawnPoint = childNodeWithName("brick1") as! SKSpriteNode
        
        // replace spawn points from Level scene with brick
        levelLoader()
        
        /*let oneBrick = Brick(brickName: "brick", brickSize: CGSize(width: 100, height:30), destructable: true)
        oneBrick.position = CGPoint(x:self.frame.size.width/2+50, y:self.frame.size.height/2)
        oneBrick.zRotation = CGFloat(M_PI_4)*2;
        addChild(oneBrick)*/
        
        hooks.append(Hook(hookName: "hook1", ladderHeight: self.view!.frame.height - controlPanelHeight))
        hooks.append(Hook(hookName: "hook2", ladderHeight: self.view!.frame.height - controlPanelHeight))
    }
    
    func setupLayout() {
        
        let isWideScreen = view!.bounds.size.width / view!.bounds.size.height == 1.5 ? false : true

        // For devices with 4:3 screen ratio (iPad and iPhone 4), increase control panel height to maintain the dimensions of the play area
        controlPanelHeight = isWideScreen ? 70 : 70 + self.frame.height-self.frame.width/(667/375)
        controlPanelWidth = self.frame.width - controlPanelHeight
        
        //print(controlPanelWidth)
        //print(controlPanelHeight)
        
        //print(self.frame.width)
        //print(view!.bounds.size.width)
        
        // the play area has inward physical boundaries for the ball to bounce off from
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x:self.frame.minX,y:self.frame.minY+controlPanelHeight,width:self.frame.maxX,height:self.frame.maxY-controlPanelHeight))
        physicsBody!.friction = 0
        physicsBody!.categoryBitMask = ObstacleCategory
        
        // set up node for the background texture
        let backgroundSize = CGSize(width:self.frame.width,height:self.frame.height-controlPanelHeight)
        backgroundNode = SKSpriteNode()
        backgroundNode.size = backgroundSize
        backgroundNode.position = CGPoint(x: self.frame.width/2,y: controlPanelHeight+(self.frame.height-controlPanelHeight)/2)
        backgroundNode.zPosition = -1
        backgroundNode.name = "background"
        addChild(backgroundNode)
    
        // texture for the entire control panel area
        let controlSize = CGSize(width:self.frame.width,height:controlPanelHeight)
        let controlNode = SKSpriteNode(texture: GameScene.sliderTex, size: controlSize)
        controlNode.position = CGPoint(x: controlSize.width/2,y: controlSize.height/2)
        controlNode.zPosition = 99
        addChild(controlNode)
        
        // slider itself has no texture, just a physics body to capture touch events
        let panelSize = CGSize(width:controlPanelWidth,height:controlPanelHeight)
        swipeNode = SKSpriteNode()
        swipeNode.size = panelSize
        swipeNode.position = CGPoint(x: panelSize.width/2,y: panelSize.height/2)
        swipeNode.zPosition = 100
        swipeNode.physicsBody = SKPhysicsBody(rectangleOfSize: panelSize)
        swipeNode.physicsBody!.dynamic = false
        swipeNode.name = swipeAreaName
        addChild(swipeNode)
    
        let buttonSize = CGSize(width:controlPanelHeight,height:controlPanelHeight)
        buttonNode = SKSpriteNode(texture: GameScene.buttonTex, size: buttonSize)
        buttonNode.position = CGPoint(x: controlPanelWidth + buttonSize.width/2,y: buttonSize.height/2)
        buttonNode.zPosition = 100
        buttonNode.physicsBody = SKPhysicsBody(rectangleOfSize: buttonSize)
        buttonNode.physicsBody!.dynamic = false
        buttonNode.name = buttonAreaName
        addChild(buttonNode)
    }
    
    func levelLoader() {
        let backgroudTex = SKTexture(imageNamed: "level1")
        backgroundNode.texture = backgroudTex
        
        // search and replace nodes from the spritescene file that start with brick
        enumerateChildNodesWithName("//brick[0-9]*") {
            node, stop in
            let spawnPoint = node as! SKSpriteNode
            // use z-level as flag for brick type: indestructable = 0, destructable = 1
            let isDestructable = (spawnPoint.zPosition == 1 ? false : true)
            let replaceBrick = Brick(brickName: "brick", brickSize: spawnPoint.size, destructable: isDestructable)
            replaceBrick.position = spawnPoint.position
            replaceBrick.zRotation = spawnPoint.zRotation
            replaceBrick.setBrickColor(spawnPoint.color)
            spawnPoint.parent!.addChild(replaceBrick)
            spawnPoint.removeFromParent()
        }
        
        // seach and replace ball nodes
        enumerateChildNodesWithName("//ball[0-9]*") {
            node, stop in
            let spawnPoint = node as! SKSpriteNode
            
            // use 10,20,30,40 as placeholder for the 4 ball sizes
            assert([10,20,30,40].contains(Int(spawnPoint.size.height)))
            let replace = Ball(ballName: "ball", ballSize: Ball.ballSizes(rawValue: Int(spawnPoint.size.height)/10)!)
            replace.position = spawnPoint.position
            replace.setBallColor(spawnPoint.color)

            spawnPoint.parent!.addChild(replace)
            spawnPoint.removeFromParent()
            
            // use velocity set on physics body for setup
            replace.physicsBody!.applyImpulse(spawnPoint.physicsBody!.velocity)
        }
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
        
        //if(self.scene!.view!.paused == true) {
        //    self.scene!.view!.paused = false
        //}
        
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
            
            if(firstBody.node != nil) {
                let currentBall = firstBody.node as? Ball

                if(currentBall!.sizeOfBall != Ball.ballSizes.mini) {
                    let leftBall = Ball.divide(currentBall!)
                    leftBall.position = CGPoint(x: currentBall!.position.x-10, y: currentBall!.position.y)
                    addChild(leftBall)
                    leftBall.physicsBody!.applyImpulse(CGVectorMake(-Ball.getPushVelocity(leftBall.sizeOfBall), 0))
                    
                    let rightBall = Ball.divide(currentBall!)
                    rightBall.position = CGPoint(x: currentBall!.position.x+10, y: currentBall!.position.y)
                    addChild(rightBall)
                    rightBall.physicsBody!.applyImpulse(CGVectorMake(Ball.getPushVelocity(rightBall.sizeOfBall), 0))
                    
                //createBall((firstBody.node?.position)!, scale: (firstBody.node?.xScale)! / 1.5).physicsBody!.applyImpulse(CGVectorMake(5, 0))
                //createBall((firstBody.node?.position)!, scale: (firstBody.node?.xScale)! / 1.5).physicsBody!.applyImpulse(CGVectorMake(-5, 0))
                }
            }
            
            firstBody.node?.removeFromParent()
            if(secondBody.node?.parent?.physicsBody?.categoryBitMask == HookCategory) {
                secondBody.node?.parent?.removeFromParent()
            } else {
                secondBody.node?.removeFromParent()
            }
            
            //let sound = SKAudioNode(fileNamed: "blop.mp3")
            //sound.autoplayLooped = false
            //addChild(sound)
            //sound.runAction(SKAction.play())
            
            //popSound.removeAllActions()
            //popSound.runAction(SKAction.play())
        }
        
        if firstBody.categoryBitMask == HookCategory && secondBody.categoryBitMask == ObstacleCategory {
            
            if secondBody.node is Brick {
                let brick = secondBody.node as! Brick
                if(brick.isDestructable) {
                    brick.destroy()
                }
            }
            
            print("hook ends")
            firstBody.node?.removeAllActions()
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
    
    /*func createBall(ballposition: CGPoint, scale:CGFloat) -> SKSpriteNode {
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
    }*/
    
    func createShot() {
        
        let hook1 = childNodeWithName("hook1")
        let hook2 = childNodeWithName("hook2")
        
        // Can only shoot up to two hooks at once
        var selectedHook:Hook
        if(hook1 == nil) {
            selectedHook = hooks[0]
        } else if(hook2 == nil) {
            selectedHook = hooks[1]
        }
        else {
            // If both hooks have been fired already, reset the first one fired
            selectedHook = (hook1 as! Hook).position.y > (hook2 as! Hook).position.y ? (hook1 as! Hook) : (hook2 as! Hook)
            selectedHook.removeAllActions()
            selectedHook.removeFromParent()
        }
        
        // fire hook above actor
        selectedHook.position = CGPoint(x: actorNode.position.x, y: actorNode.position.y)
        addChild(selectedHook)
        selectedHook.physicsBody!.applyImpulse(CGVectorMake(0, 1.2))
        
        // keep track of the two in move
    /*
        let shotSize = CGSize(width: 10,height: 10)
        //let shotNode = SKShapeNode(rectOfSize: shotSize)
        let shotNode = SKSpriteNode(imageNamed:"anchor")
        shotNode.size = shotSize
        shotNode.position = CGPoint(x: actorNode.position.x, y: actorNode.position.y+actorNode.size.height)
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
        //addChild(shotNode)
        
        let rope = SKSpriteNode(texture: tiledRope)
        rope.size.height = self.view!.frame.height - controlPanelHeight
        rope.position.y = -rope.size.height/2
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
        //shotNode.addChild(rope)
        
        /*let flip1 = SKAction.scaleXTo(1, duration: 0.0)
        let wait = SKAction.waitForDuration(0.2)
        let flip2 = SKAction.scaleXTo(-1, duration: 0.0)
        let sequence = SKAction.sequence([flip1, wait, flip2])
        shotNode.runAction(SKAction.repeatActionForever(sequence))*/
        
        /*physicsWorld.addJoint(SKPhysicsJointFixed.jointWithBodyA(shotNode.physicsBody!,
                       bodyB: rope.physicsBody!,
                       anchor: CGPointMake(shotNode.position.x, shotNode.position.y)))*/
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
        countdownNode.fontColor = SKColor.whiteColor()
        countdownNode.name = "countDown";
        countdownNode.zPosition = 100;
        addChild(countdownNode)
        
        livesNode = SKLabelNode(fontNamed: "Futura-Medium")
        livesNode.fontSize = 50;
        livesNode.position = CGPointMake(CGRectGetMidX(self.frame)+100, CGRectGetMaxY(self.frame)*0.85)
        livesNode.fontColor = SKColor.whiteColor()
        livesNode.name = "lives";
        livesNode.zPosition = 100;
        livesNode.text = "\(lives) Lifes"
        addChild(livesNode)
        
        /*let firstBall = Ball(ballName: "ball", ballSize: Ball.ballSizes.large)
        firstBall.setBallColor(UIColor.redColor())
        firstBall.position = CGPoint(x:self.frame.size.width/2+50, y:self.frame.size.height/2+100)
        addChild(firstBall)
        firstBall.physicsBody!.applyImpulse(CGVectorMake(Ball.getPushVelocity(firstBall.sizeOfBall), 0))*/
        
        /*let secondBall = Ball(ballName: "ball", ballSize: Ball.ballSizes.large)
        secondBall.setBallColor(UIColor.blueColor())
        secondBall.position = CGPoint(x:self.frame.size.width/2-50, y:self.frame.size.height/2+100)
        addChild(secondBall)
        secondBall.physicsBody!.applyImpulse(CGVectorMake(-5, 0))*/
        
        //let ballNode = createBall(CGPoint(x:self.frame.size.width/2+50, y:self.frame.size.height/2+100), scale: 2.0)
        //ballNode.physicsBody!.applyImpulse(CGVectorMake(5, 0))
        
        //let ballNode2 = createBall(CGPoint(x:self.frame.size.width/2-50, y:self.frame.size.height/2+100), scale: 2.0)
        //ballNode2.physicsBody!.applyImpulse(CGVectorMake(-5, 0))
        
        startCountdown = true
        gameRunning = true
        //self.scene!.view!.paused = false
    }
    
    func beginGameover() {
        gameRunning = false
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)

        let newscene = GameoverScene(size: view!.bounds.size)
        newscene.scaleMode = .AspectFit

        self.scene?.removeAllChildren()
        self.scene?.removeAllActions()
        self.scene!.view!.presentScene(newscene, transition: transition)
    }
    
    func beginNextLevel() {
        gameRunning = false
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
        
        let newscene = NextScene(size: view!.bounds.size)
        newscene.scaleMode = .AspectFit
        
        self.scene?.removeAllChildren()
        self.scene?.removeAllActions()
        self.scene!.view!.presentScene(newscene, transition: transition)
    }
    
    override func didSimulatePhysics() {
        // put them in umbrella node called hooks
        
        self.enumerateChildNodesWithName("hook1", usingBlock: {
            (hookChild: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in

            //let hookChild = self.childNodeWithName("hook")
            if(hookChild != nil) {
                let ropeChild = hookChild!.childNodeWithName("rope")
                
                if(ropeChild != nil && hookChild != nil) {
                    let height = (ropeChild as! SKSpriteNode).size.height
                    
                    ropeChild!.position.y = -height / 2
                }
            }
        })
        
        self.enumerateChildNodesWithName("hook2", usingBlock: {
            (hookChild: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            
            //let hookChild = self.childNodeWithName("hook")
            if(hookChild != nil) {
                let ropeChild = hookChild!.childNodeWithName("rope")
                
                if(ropeChild != nil && hookChild != nil) {
                    let height = (ropeChild as! SKSpriteNode).size.height
                    
                    ropeChild!.position.y = -height / 2
                }
            }
        })
    }

   
    override func update(currentTime: CFTimeInterval) {
        if(isGameFinished()) {
            beginNextLevel()
        }
        
        //let maxSpeed: CGFloat = 600.0
        //let hyperSpeed: CGFloat = 900.0
        
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

            (ball as! Ball).checkBounce()
            /*let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
            
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
            }*/
            
        })
        
    }

    deinit {
        // perform the deinitialization
        print("deinit was called")
    }
    
   /*
    func convert(point: CGPoint)->CGPoint {
        return self.view!.convertPoint(CGPoint(x: point.x, y:self.view!.frame.height-point.y), toScene:self)
    }*/
}
