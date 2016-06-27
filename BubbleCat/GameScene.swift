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
let PowerupCategory : UInt32 = 0x1 << 5

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    static let beginSound = SKAudioNode(fileNamed: "begin.mp3")
    static let popSound = SKAudioNode(fileNamed: "blop.mp3")
    static let breakSound = SKAudioNode(fileNamed: "break.mp3")
    static let plungerSound = SKAudioNode(fileNamed: "plunger.mp3")
    static let shotSound = SKAudioNode(fileNamed: "shot.mp3")
    static let powerupSound = SKAudioNode(fileNamed: "powerup.mp3")
    static let hitSound = SKAudioNode(fileNamed: "hit.mp3")

    static let buttonImageName = "button"
    static let buttonTex = SKTexture(imageNamed: GameScene.buttonImageName)
    static let sliderImageName = "slider"
    static let sliderTex = SKTexture(imageNamed: GameScene.sliderImageName)
    
    static let backgroudTex = SKTexture(imageNamed: "level1")
    static let lifeIconTex = SKTexture(imageNamed: "powerup_1")
    var lifeIcons = [SKSpriteNode]()
    
    static let firstLevel = 1
    static var levelSelector = firstLevel
    
    let swipeAreaName = "swipe"
    let buttonAreaName = "button"
    let ballName = "gameball"
    var isFingerOnSwipe = false
    
    var controlPanelHeight:CGFloat = 0
    var controlPanelWidth:CGFloat = 0
    
    var backgroundNode: SKSpriteNode = SKSpriteNode()
    var swipeNode: SKSpriteNode = SKSpriteNode()
    var buttonNode: SKSpriteNode = SKSpriteNode()
    var actorNode: Actor
    var countdownNode: SKLabelNode = SKLabelNode()
    var livesNode: SKLabelNode = SKLabelNode()
    
    var gameNode: SKNode = SKNode()
    var layoutNode: SKNode = SKNode()
    let shieldNode = SKNode()

    var actorWalkingDirectionMultiplier : CGFloat = 1
    
    var gameRunning = false
    var startCountdown = false
    var startTime:CFTimeInterval = CFTimeInterval()
    
    var lastBallHitTime:CFTimeInterval = CFTimeInterval()
    var updateTimeDiff:CFTimeInterval = CFTimeInterval()
    var timeLimit = 100
    var pausedTimeDifference = 0
    var lastUpdateTime:CFTimeInterval = CFTimeInterval()
    
    var unpauseActions:Bool = false
    var timeStopActiveCounter = 0
    var ballNameCounter = 1
    //var ballVelocities = [CGVector]()
    var lastVelocityX:CGFloat = 0
    
    static let startLifes = 3
    static var lives = startLifes
    
    var hooks = [Hook]()
    
    override init(size: CGSize) {
        
        // this method is not called
        actorNode = Actor(actorName: "actor", actorSize: CGSize(width: 0, height: 0))
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        actorNode = Actor(actorName: "actor", actorSize: CGSize(width: 37, height: 60))
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        // Used to pause and restart the game if the app is moving into the background
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(GameScene.pauseScene),
                                                         name: UIApplicationWillResignActiveNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(GameScene.restartScene),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)

        
        print("init was called")
        
        //view.showsPhysics = true
        //self.scene!.view!.paused = true
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVectorMake(0.0, -6);
        physicsWorld.speed = 0.8
 
        // If was gameover, reset lifes
        if(GameScene.lives <= 0) {
            GameScene.lives = GameScene.startLifes
        }
        
        addChild(gameNode)
        addChild(layoutNode)
        
        // wait until scene is complete to add sounds to prevent from crashing
        runAction(SKAction.waitForDuration(0.1), completion: {

            GameScene.popSound.autoplayLooped = false
            GameScene.beginSound.autoplayLooped = false
            GameScene.plungerSound.autoplayLooped = false
            GameScene.breakSound.autoplayLooped = false
            GameScene.shotSound.autoplayLooped = false
            GameScene.powerupSound.autoplayLooped = false
            GameScene.hitSound.autoplayLooped = false
            self.addChild(GameScene.popSound)
            self.addChild(GameScene.beginSound)
            self.addChild(GameScene.plungerSound)
            self.addChild(GameScene.breakSound)
            self.addChild(GameScene.shotSound)
            self.addChild(GameScene.powerupSound)
            self.addChild(GameScene.hitSound)
            GameScene.hitSound.runAction(SKAction.changeVolumeTo(0.2, duration: 0.1))
        })
        
        setupLayout()
        
        actorNode.position = CGPoint(x:self.frame.size.width/2-200, y:controlPanelHeight + actorNode.size.height / 2 - 5)
        gameNode.addChild(actorNode)
        gameNode.addChild(shieldNode)

        // replace spawn points from Level scene with bricks and balls
        levelLoader()
        PowerUp.active = PowerUp.powerupType.none
        
        hooks.append(Hook(hookName: "hook1", ladderHeight: self.view!.frame.height))
        hooks.append(Hook(hookName: "hook2", ladderHeight: self.view!.frame.height))
        
        GameScene.beginSound.runAction(SKAction.play())
    }
    
    func setupLayout() {
        
        let isWideScreen = view!.bounds.size.width / view!.bounds.size.height == 1.5 ? false : true

        // For devices with 4:3 screen ratio (iPad and iPhone 4), increase control panel height to maintain the dimensions of the play area
        controlPanelHeight = isWideScreen ? 70 : 70 + self.frame.height-self.frame.width/(667/375)
        controlPanelWidth = self.frame.width - controlPanelHeight
 
        // the play area has inward physical boundaries for the ball to bounce off from
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x:self.frame.minX,y:self.frame.minY+controlPanelHeight,width:self.frame.maxX,height:self.frame.maxY-controlPanelHeight))
        physicsBody!.friction = 0
        physicsBody!.restitution = 1.0
        physicsBody!.linearDamping = 0
        physicsBody!.angularDamping = 0
        physicsBody!.affectedByGravity = false
        physicsBody!.categoryBitMask = ObstacleCategory
        
        // TODO create contact areas for Floor and Walls instead of using ObstacleCategory only
        
        // set up node for the background texture
        let backgroundSize = CGSize(width:self.frame.width,height:self.frame.height)
        backgroundNode = SKSpriteNode()
        backgroundNode.texture = GameScene.backgroudTex
        backgroundNode.size = backgroundSize
        //backgroundNode.position = CGPoint(x: self.frame.width/2,y: controlPanelHeight+(self.frame.height-controlPanelHeight)/2)
        backgroundNode.position = CGPoint(x: self.frame.width/2,y: self.frame.height/2)
        backgroundNode.zPosition = -1
        backgroundNode.name = "background"
        
        let shader = SKShader(fileNamed: "underwater.fsh")
        shader.uniforms = [
            SKUniform(name: "size", floatVector3: GLKVector3Make(Float(GameScene.backgroudTex.size().width), Float(GameScene.backgroudTex.size().height), 0)),
            SKUniform(name: "customTexture", texture: GameScene.backgroudTex)
        ]
        backgroundNode.shader = shader
        
        layoutNode.addChild(backgroundNode)
        
        // texture for the entire control panel area
        let controlSize = CGSize(width:self.frame.width,height:controlPanelHeight)
        let controlNode = SKSpriteNode(texture: GameScene.sliderTex, size: controlSize)
        controlNode.position = CGPoint(x: controlSize.width/2,y: controlSize.height/2)
        controlNode.zPosition = 99
        layoutNode.addChild(controlNode)
        
        // slider itself has no texture, just a physics body to capture touch events
        let panelSize = CGSize(width:controlPanelWidth,height:controlPanelHeight)
        swipeNode = SKSpriteNode()
        swipeNode.size = panelSize
        swipeNode.position = CGPoint(x: panelSize.width/2,y: panelSize.height/2)
        swipeNode.zPosition = 100
        swipeNode.physicsBody = SKPhysicsBody(rectangleOfSize: panelSize)
        swipeNode.physicsBody!.dynamic = false
        swipeNode.name = swipeAreaName
        layoutNode.addChild(swipeNode)
    
        let buttonSize = CGSize(width:controlPanelHeight+20,height:controlPanelHeight)
        buttonNode = SKSpriteNode(texture: GameScene.buttonTex, size: buttonSize)
        buttonNode.position = CGPoint(x: controlPanelWidth + buttonSize.width/2 - 20,y: buttonSize.height/2)
        buttonNode.zPosition = 100
        buttonNode.physicsBody = SKPhysicsBody(rectangleOfSize: buttonSize)
        buttonNode.physicsBody!.dynamic = false
        buttonNode.name = buttonAreaName
        layoutNode.addChild(buttonNode)
        
        countdownNode = SKLabelNode(fontNamed: "Futura-Medium")
        countdownNode.fontSize = 50;
        countdownNode.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMaxY(self.frame)*0.85)
        countdownNode.fontColor = SKColor.whiteColor()
        countdownNode.name = "countDown";
        countdownNode.zPosition = 100;
        //layoutNode.addChild(countdownNode)
        
        livesNode = SKLabelNode(fontNamed: "Futura-Medium")
        livesNode.fontSize = 50;
        livesNode.position = CGPointMake(CGRectGetMidX(self.frame)+100, CGRectGetMaxY(self.frame)*0.85)
        livesNode.fontColor = SKColor.whiteColor()
        livesNode.name = "lives";
        livesNode.zPosition = 100;
        livesNode.text = "\(GameScene.lives) Lifes"
        //layoutNode.addChild(livesNode)
        
        
        let iconSize = CGSize(width: 30,height: 30)
        for i in 0...3 {
            lifeIcons.append(SKSpriteNode(texture: GameScene.lifeIconTex, color: UIColor(), size: iconSize))
            lifeIcons[i].zPosition = 100
            let offset = CGFloat(i)*(iconSize.width + 3)
            let xpos = 5+(iconSize.width/2)+offset
            //let ypos = CGRectGetMaxY(self.frame)-iconSize.height/2-5
            let ypos = iconSize.height/2+5
            lifeIcons[i].position = CGPointMake(xpos, ypos)
            lifeIcons[i].name = "lifeicon"
            layoutNode.addChild(lifeIcons[i])
            
            if(GameScene.lives < (i+1)) {
                lifeIcons[i].hidden = true
            }
        }
        
        //print("panel height is \(controlPanelHeight)")
    }
    
    func levelLoader() {
        //let backgroudTex = SKTexture(imageNamed: "level1")
        //backgroundNode.texture = backgroudTex
        
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
            self.gameNode.addChild(replaceBrick)
            spawnPoint.removeFromParent()
        }
        
        // seach and replace ball nodes
        enumerateChildNodesWithName("//ball[0-9]*") {
            node, stop in
            let spawnPoint = node as! SKSpriteNode
            
            // use 10,20,30,40 as placeholder for the 4 ball sizes
            assert([10,20,30,40].contains(Int(spawnPoint.size.height)))
            let replace = Ball(ballName: "\(self.ballName)\(self.ballNameCounter)", ballSize: Ball.ballSizes(rawValue: Int(spawnPoint.size.height)/10)!)
            self.ballNameCounter = self.ballNameCounter + 1
            replace.position = spawnPoint.position
            replace.setBallColor(spawnPoint.color)

            self.gameNode.addChild(replace)
            spawnPoint.removeFromParent()
            
            // TODO change impulse to setting velocity?
            
            // use velocity set on physics body for setup
            replace.physicsBody!.applyImpulse(spawnPoint.physicsBody!.velocity)
            replace.lastVelocityX = replace.physicsBody!.velocity.dx
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
                //print("Swipe began")
                isFingerOnSwipe = true
            }
            else if body.node!.name == buttonAreaName {
                
               buttonNode.runAction(SKAction.sequence([SKAction.scaleTo(0.8, duration: 0.1), SKAction.scaleTo(1.0, duration: 0.1)]))
 
                //print("Button")
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
                    actorNode.stopWalkingActor()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first{
            let touchLocation = touch.locationInNode(self)
            
            if isFingerOnSwipe {

                if let body = physicsWorld.bodyAtPoint(touchLocation) {
                    if body.node?.name == swipeAreaName {
                        
                        let previousLocation = touch.previousLocationInNode(self)
                        
                        let swipeChange = (touchLocation.x - previousLocation.x) * 1.5
                        
                        actorWalkingDirectionMultiplier = swipeChange > 0 ? -1 : 1
                        actorNode.xScale = fabs(actorNode.xScale) * actorWalkingDirectionMultiplier
                        actorNode.walkActor()
                        
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
        
        // categorize first and second body in order of the bit masks
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // the physics engine incorrectly rounds the x-velocity of the ball to zero if it hits an obstacle at a steep angle, to correct for this, we record the last x-velocity and substitute it whenever it gets set to 0
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == ObstacleCategory {
            
            if(firstBody.node != nil) {
                
                let currentBall = firstBody.node as? Ball
                
                //print("vector x: \(contact.contactNormal.dx) y: \(contact.contactNormal.dy)")
                //print("impulse: \(contact.collisionImpulse)")
                
                //let speed = sqrt(firstBody.velocity.dx * firstBody.velocity.dx + firstBody.velocity.dy * firstBody.velocity.dy)
                //print("Before \(firstBody.node?.name) xvel: \(firstBody.velocity.dx) y: \(firstBody.velocity.dy) and x pos \(firstBody.node?.position.x) and lastvel \(currentBall?.lastVelocityX)")
                //print("Speed \(speed) and y is \(firstBody.velocity.dy)")
                
                // if the ball hits the ground also keep the Y-velocity constant (height of bounce)
                if((secondBody.node as? SKScene) != nil) {
                    if(currentBall!.position.y <= controlPanelHeight+currentBall!.size.height/2+10) {
                        currentBall?.checkGroundVelocity()
                    }
                }
                
                //print("contact \(contact.contactPoint.y) target \(secondBody.node!.position.y + secondBody.node!.frame.height/2)")
                
                //if(firstBody.velocity.dx == 0) {
                if(abs(firstBody.velocity.dx) < 0.1) {
                    firstBody.velocity.dx = -currentBall!.lastVelocityX
                    
                    //print("**** REVERTED TO OLD VEL")
                    //let obstacle = secondBody.node as? SKSpriteNode
                    
                    //if(abs(contact.contactNormal.dx) > 0) {
                    /*if((contact.contactPoint.y) < (secondBody.node!.position.y + obstacle!.size.height/2)) {
                        firstBody.velocity.dx = -firstBody.velocity.dx
                        
                        //print("asset height \(obstacle!.size.height/2)")
                        //print("target pos \(secondBody.node!.position.y)")
                        print("**** REVERTED DIRECTION")
                        //print("contact \(contact.contactPoint.y) target \(secondBody.node!.position.y + obstacle!.size.height/2)")
                        //print("Before \(firstBody.node?.name) xvel: \(firstBody.velocity.dx) y: \(firstBody.velocity.dy) and x pos \(firstBody.node?.position.x) ypos \(firstBody.node?.position.y) and lastvel \(currentBall?.lastVelocityX)")
                        //firstBody.dynamic = false
                    }*/
                    
                }
                else {
                    currentBall!.lastVelocityX = firstBody.velocity.dx
                }
                
                //print("After \(firstBody.node?.name)  x: \(firstBody.velocity.dx) y: \(firstBody.velocity.dy) and x pos \(firstBody.node?.position.x)")
            }
        }
        
        // Actor picks up powerup
        if firstBody.categoryBitMask == ActorCategory && secondBody.categoryBitMask == PowerupCategory {
            
            if(secondBody.node != nil) {
                let powerupNode = secondBody.node as? PowerUp
                powerupNode?.activate()
                activatePowerup()
                
                powerupNode?.removeAllActions()
                powerupNode?.removeFromParent()
                
                GameScene.powerupSound.runAction(SKAction.play())
            }
        }
        
        // Powerup lands on obstacle - don't let it bounce
        if firstBody.categoryBitMask == ObstacleCategory && secondBody.categoryBitMask == PowerupCategory {
            
            if(secondBody.node != nil) {
                secondBody.velocity.dx = 0
                secondBody.velocity.dy = 0
            }
        }
        
        // Ball gets hit by hook
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == HookCategory {
            
            if(firstBody.node != nil) {
                let currentBall = firstBody.node as? Ball

                powerupLottery(currentBall!.position)
                
                // if hook hits a ball, subdivide into 2 unless it's the smallest size already
                if(currentBall!.sizeOfBall != Ball.ballSizes.small && currentBall!.sizeOfBall != Ball.ballSizes.mini) {
                    
                    let leftBall = Ball.divide(currentBall!, name: "\(self.ballName)\(self.ballNameCounter)")
                    self.ballNameCounter = self.ballNameCounter + 1
                    leftBall.position = CGPoint(x: currentBall!.position.x-10, y: currentBall!.position.y)
                    gameNode.addChild(leftBall)
                    leftBall.physicsBody!.applyImpulse(CGVectorMake(-Ball.getPushVelocity(leftBall.sizeOfBall), 3))
                    //print(leftBall.physicsBody!.velocity.dx)
                    leftBall.lastVelocityX = leftBall.physicsBody!.velocity.dx
                    
                    let rightBall = Ball.divide(currentBall!, name: "\(self.ballName)\(self.ballNameCounter)")
                    self.ballNameCounter = self.ballNameCounter + 1
                    rightBall.position = CGPoint(x: currentBall!.position.x+10, y: currentBall!.position.y)
                    gameNode.addChild(rightBall)
                    rightBall.physicsBody!.applyImpulse(CGVectorMake(Ball.getPushVelocity(rightBall.sizeOfBall), 3))
                    rightBall.lastVelocityX = rightBall.physicsBody!.velocity.dx
                    
                    if(self.timeStopActiveCounter > 0) {
                        leftBall.timeStopVelocity = (leftBall.physicsBody?.velocity)!
                        leftBall.physicsBody?.dynamic = false
                        rightBall.timeStopVelocity = (rightBall.physicsBody?.velocity)!
                        rightBall.physicsBody?.dynamic = false
                    }
                }
            }
            
            // after the hook hits a ball, remove it
            firstBody.node?.removeFromParent()
            
            if(secondBody.node?.parent?.physicsBody?.categoryBitMask == HookCategory) {
                secondBody.node?.parent?.removeAllActions()
                secondBody.node?.parent?.removeFromParent()
            } else {
                secondBody.node?.removeAllActions()
                secondBody.node?.removeFromParent()
            }
            
            // the pop sounds for the last ball is sometimes not played until the next scene starts - skip it
            if (gameNode.childNodeWithName("//\(self.ballName)[0-9]*") != nil) {
                GameScene.popSound.runAction(SKAction.play())
            }
            
            //popSound.removeAllActions()
            //popSound.runAction(SKAction.play())
        }
        
        // if a hook hits a brick, remove it only if the brick is marked as destructable
        if firstBody.categoryBitMask == HookCategory && secondBody.categoryBitMask == ObstacleCategory {
            
            if secondBody.node is Brick {
                let brick = secondBody.node as! Brick
                
                if(brick.isDestructable) {
                    brick.destroy()
                    firstBody.node?.removeAllActions()
                    firstBody.node?.removeFromParent()
                    powerupLottery(brick.position)
                    GameScene.breakSound.runAction(SKAction.play())
                    return
                }
            }
            
            // static hook can stick to ceiling or indestructable brick and freezes for a few seconds
            if(PowerUp.active == PowerUp.powerupType.staticHook) {

                firstBody.dynamic = false
                
                let wait = SKAction.waitForDuration(PowerUp.staticHookDuration)
                let run = SKAction.runBlock {
                    firstBody.node?.removeAllActions()
                    firstBody.node?.removeFromParent()
                }
                firstBody.node?.runAction(SKAction.sequence([wait, run]))
                GameScene.plungerSound.runAction(SKAction.play())
            }
            else {
                //print("hook ends")
                firstBody.node?.removeAllActions()
                firstBody.node?.removeFromParent()
            }
        }
        
        // player loses one life every time they get hit by the ball
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == ActorCategory {
            
            // prevent sudden gameover from physics engine, no multiple hits within less than 0.05 seconds
            if(lastUpdateTime - lastBallHitTime < 0.05) {
                return
            } else {
                lastBallHitTime = lastUpdateTime
            }
            
            // can absorb one hit with shield powerup
            if(PowerUp.shieldActive) {
                actorNode.colorBlendFactor = 0
                PowerUp.shieldActive = false
            } else {
                GameScene.lives -= 1
                //livesNode.text = "\(GameScene.lives) Lifes"
                
                if(GameScene.lives <= 0) {
                    beginGameover()
                }
                else {
                    lifeIcons[GameScene.lives].hidden = true
                    GameScene.hitSound.runAction(SKAction.play())
                }
            }
        }
    }
    
    func powerupLottery(point: CGPoint) {
        // 33% chance of spawning a powerup
        if(rand() % 3 == 0) {
        
            // randomly pick one of the 6 available powerups
            let powerupType = PowerUp.randomPowerUp()
            //let powerupType = PowerUp.powerupType.staticHook
            let newPowerup = PowerUp(powerupName: "powerup", powerupSize: CGSize(width: 20,height: 20), type: powerupType)
            
            newPowerup.position = point
            gameNode.addChild(newPowerup)
        
            // only show powerup for a limited number of seconds
            let wait = SKAction.waitForDuration(PowerUp.showTime)
            let run = SKAction.runBlock {
                newPowerup.removeAllActions()
                newPowerup.removeFromParent()
            }
            newPowerup.runAction(SKAction.sequence([wait, run]))
        }
    }
    
    
    func activatePowerup() {
        
        switch(PowerUp.active) {
        case .extraLife:
            if(GameScene.lives < 4) {
                GameScene.lives += 1
                lifeIcons[GameScene.lives-1].hidden = false
            }
            livesNode.text = "\(GameScene.lives) Lifes"
        case .shield:
            // create shader for actor
            actorNode.color = UIColor.yellowColor()
            actorNode.colorBlendFactor = 0.8
            PowerUp.shieldActive = true
            
            let wait = SKAction.waitForDuration(PowerUp.shieldDuration)
            let run = SKAction.runBlock {
                self.actorNode.colorBlendFactor = 0
                PowerUp.shieldActive = false
            }
            // remove previous timer in case player already had a shield powerup active
            shieldNode.removeAllActions()
            shieldNode.runAction(SKAction.sequence([wait, run]))
            
            
        case .timeStop:
            
            timeStopActiveCounter = timeStopActiveCounter + 1
            
            // stop all ball physics
            gameNode.enumerateChildNodesWithName("//\(self.ballName)[0-9]*", usingBlock: {
                (ball: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
                
                //self.ballVelocities.append(((ball as! Ball).physicsBody?.velocity)!)

                (ball as! Ball).timeStopVelocity = ((ball as! Ball).physicsBody?.velocity)!
                (ball as! Ball).physicsBody?.dynamic = false
            })
            
            // reset ball velocities after time starts again
            let wait = SKAction.waitForDuration(PowerUp.timeStopDuration)
            let run = SKAction.runBlock {
                
                self.timeStopActiveCounter = self.timeStopActiveCounter - 1
                
                if(self.timeStopActiveCounter == 0) {
                    self.gameNode.enumerateChildNodesWithName("//\(self.ballName)[0-9]*", usingBlock: {
                        (ball: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
                        
                        (ball as! Ball).physicsBody?.dynamic = true
                        (ball as! Ball).physicsBody?.velocity = (ball as! Ball).timeStopVelocity
                        //(ball as! Ball).physicsBody?.velocity = self.ballVelocities.removeFirst()
                    })
                }
            }
            gameNode.runAction(SKAction.sequence([wait, run]))
            
            
        case .dynamite:
            gameNode.enumerateChildNodesWithName("//\(self.ballName)[0-9]*", usingBlock: {
                (ball: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
                
                (ball as! Ball).sizeOfBall = Ball.ballSizes.small
                (ball as! Ball).size = Ball.getSize(Ball.ballSizes.small)
            })
         default: break
            
        }
    }
    
    func createShot() {
        
        let hook1 = gameNode.childNodeWithName("hook1")
        let hook2 = gameNode.childNodeWithName("hook2")
        
        var selectedHook:Hook
        
        // Can shoot up to two hooks at once with power up
        if(PowerUp.active == PowerUp.powerupType.doubleHook) {
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
        }
        // Only one hook at a time without powerup
        else {
            selectedHook = hooks[0]
            if(hook1 != nil) {
                selectedHook.removeAllActions()
                selectedHook.removeFromParent()
            }
        }
        
        if(PowerUp.active == PowerUp.powerupType.staticHook) {
            selectedHook.ropeNode.texture = Hook.tiledStraightRope
            selectedHook.ropeNode.size.width = 3
        } else {
            selectedHook.ropeNode.texture = Hook.tiledRope
            selectedHook.ropeNode.size.width = 6
        }
        
        // fire hook above actor
        selectedHook.physicsBody?.dynamic = true
        selectedHook.position = CGPoint(x: actorNode.position.x, y: actorNode.position.y)
        gameNode.addChild(selectedHook)
        selectedHook.physicsBody!.applyImpulse(CGVectorMake(0, 1.2))
        
        GameScene.shotSound.runAction(SKAction.play())
    }
    
    func isGameFinished() -> Bool {
        if (gameRunning && (gameNode.childNodeWithName("//\(self.ballName)[0-9]*") == nil)) {
            //let ballNode = createBall(CGPoint(x:self.frame.size.width/2, y:self.frame.size.height/2), scale: 1.0)
            //ballNode.physicsBody!.applyImpulse(CGVectorMake(5, 0))
            //print("no more balls")
            return true
        }
        return false
    }
    
    func beginGame() {
        
        startCountdown = true
        gameRunning = true
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
    
    func pauseScene() {
        
        scene?.paused = true
    }
    
    func restartScene() {
        scene?.paused = false
        unpauseActions = true
    }
    
    override func didSimulatePhysics() {

        // enumerate through all the hooks
        gameNode.enumerateChildNodesWithName("hook[0-9]*", usingBlock: {
            (hookChild: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in

            // fix the position of the rope to be under the hook
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
        // adjust countdown for time elapsed while game was in background
        if(unpauseActions && gameRunning) {
            pausedTimeDifference = pausedTimeDifference + (Int)(currentTime - lastUpdateTime)
            unpauseActions = false
        }
        updateTimeDiff = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if(isGameFinished()) {
            beginNextLevel()
        }
        
        // game countdown
        if(startCountdown) {
            startTime = currentTime
            lastBallHitTime = currentTime
            startCountdown = false
        }
        let countDown = timeLimit - (Int)(currentTime-startTime) + pausedTimeDifference
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
        gameNode.enumerateChildNodesWithName("//\(self.ballName)[0-9]*", usingBlock: {
            (ball: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in

            (ball as! Ball).checkBounce()
        })
        
    }

    deinit {
        // perform the deinitialization
        print("GameScene deinit was called")
    }
    
   /*
    func convert(point: CGPoint)->CGPoint {
        return self.view!.convertPoint(CGPoint(x: point.x, y:self.view!.frame.height-point.y), toScene:self)
    }*/
}
