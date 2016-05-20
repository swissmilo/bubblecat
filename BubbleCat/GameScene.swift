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
    
    static let backgroundMusic = SKAudioNode(fileNamed: "blop.mp3")
    static let popSound = SKAudioNode(fileNamed: "blop.mp3")

    static let buttonImageName = "button"
    static let buttonTex = SKTexture(imageNamed: GameScene.buttonImageName)
    static let sliderImageName = "slider"
    static let sliderTex = SKTexture(imageNamed: GameScene.sliderImageName)
    
    static let firstLevel = 1
    static var levelSelector = firstLevel
    
    let swipeAreaName = "swipe"
    let buttonAreaName = "button"
    let ballName = "ball"
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

    var actorWalkingDirectionMultiplier : CGFloat = 1
    
    var gameRunning = false
    var startCountdown = false
    var startTime:CFTimeInterval = CFTimeInterval()
    
    var timeLimit = 100
    
    var lastVelocityX:CGFloat = 0
    
    static let startLifes = 3
    static var lives = startLifes
    
    var hooks = [Hook]()
    
    override init(size: CGSize) {
        
        actorNode = Actor(actorName: "actor", actorSize: CGSize(width: 70, height: 50))
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        actorNode = Actor(actorName: "actor", actorSize: CGSize(width: 70, height: 50))
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        print("init was called")
        
        //view.showsPhysics = true
        //self.scene!.view!.paused = true
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVectorMake(0.0, -6);
        physicsWorld.speed = 0.9
 
        // If was gameover, reset lifes
        if(GameScene.lives <= 0) {
            GameScene.lives = GameScene.startLifes
        }
        
        addChild(gameNode)
        addChild(layoutNode)
        
        //GameScene.popSound.autoplayLooped = false
        //addChild(GameScene.backgroundMusic)
        //addChild(GameScene.popSound)
        
        setupLayout()
        
        actorNode.position = CGPoint(x:self.frame.size.width/2-200, y:controlPanelHeight + actorNode.size.height / 2)
        gameNode.addChild(actorNode)

        // replace spawn points from Level scene with bricks and balls
        levelLoader()
        
        // TODO should be based on playarea height
        hooks.append(Hook(hookName: "hook1", ladderHeight: self.view!.frame.height - controlPanelHeight))
        hooks.append(Hook(hookName: "hook2", ladderHeight: self.view!.frame.height - controlPanelHeight))
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
        
        // set up node for the background texture
        let backgroundSize = CGSize(width:self.frame.width,height:self.frame.height-controlPanelHeight)
        backgroundNode = SKSpriteNode()
        backgroundNode.size = backgroundSize
        backgroundNode.position = CGPoint(x: self.frame.width/2,y: controlPanelHeight+(self.frame.height-controlPanelHeight)/2)
        backgroundNode.zPosition = -1
        backgroundNode.name = "background"
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
    
        let buttonSize = CGSize(width:controlPanelHeight,height:controlPanelHeight)
        buttonNode = SKSpriteNode(texture: GameScene.buttonTex, size: buttonSize)
        buttonNode.position = CGPoint(x: controlPanelWidth + buttonSize.width/2,y: buttonSize.height/2)
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
        layoutNode.addChild(countdownNode)
        
        livesNode = SKLabelNode(fontNamed: "Futura-Medium")
        livesNode.fontSize = 50;
        livesNode.position = CGPointMake(CGRectGetMidX(self.frame)+100, CGRectGetMaxY(self.frame)*0.85)
        livesNode.fontColor = SKColor.whiteColor()
        livesNode.name = "lives";
        livesNode.zPosition = 100;
        livesNode.text = "\(GameScene.lives) Lifes"
        layoutNode.addChild(livesNode)
        
        //print("panel height is \(controlPanelHeight)")
    }
    
    func levelLoader() {
        let backgroudTex = SKTexture(imageNamed: "level\(GameScene.levelSelector)")
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
            self.gameNode.addChild(replaceBrick)
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

            self.gameNode.addChild(replace)
            spawnPoint.removeFromParent()
            
            // TODO change impulse to setting velocity?
            
            // use velocity set on physics body for setup
            replace.physicsBody!.applyImpulse(spawnPoint.physicsBody!.velocity)
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
                
                //let speed = sqrt(firstBody.velocity.dx * firstBody.velocity.dx + firstBody.velocity.dy * firstBody.velocity.dy)
                //print("Speed \(speed) and x is \(firstBody.velocity.dx)")
                //print("Speed \(speed) and y is \(firstBody.velocity.dy)")
                
                let currentBall = firstBody.node as? Ball
                
                // if the ball hits the ground also keep the Y-velocity constant (height of bounce)
                if((secondBody.node as? SKScene) != nil) {
                    if(currentBall!.position.y <= self.view!.frame.height/2) {
                        currentBall?.checkGroundVelocity()
                    }
                }
                
                if(firstBody.velocity.dx == 0) {
                    firstBody.velocity.dx = -currentBall!.lastVelocityX
                }
                else {
                    currentBall!.lastVelocityX = firstBody.velocity.dx
                }
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
            }
        }
        
        // Ball gets hit by hook
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == HookCategory {
            
            if(firstBody.node != nil) {
                let currentBall = firstBody.node as? Ball

                powerupLottery(currentBall!.position)
                
                // if hook hits a ball, subdivide into 2 unless it's the smallest size already
                if(currentBall!.sizeOfBall != Ball.ballSizes.small && currentBall!.sizeOfBall != Ball.ballSizes.mini) {
                    
                    let leftBall = Ball.divide(currentBall!)
                    leftBall.position = CGPoint(x: currentBall!.position.x-10, y: currentBall!.position.y)
                    gameNode.addChild(leftBall)
                    leftBall.physicsBody!.applyImpulse(CGVectorMake(-Ball.getPushVelocity(leftBall.sizeOfBall), 0))
                    
                    let rightBall = Ball.divide(currentBall!)
                    rightBall.position = CGPoint(x: currentBall!.position.x+10, y: currentBall!.position.y)
                    gameNode.addChild(rightBall)
                    rightBall.physicsBody!.applyImpulse(CGVectorMake(Ball.getPushVelocity(rightBall.sizeOfBall), 0))
                }
            }
            
            // after the hook hits a ball, remove it
            firstBody.node?.removeFromParent()
            if(secondBody.node?.parent?.physicsBody?.categoryBitMask == HookCategory) {
                secondBody.node?.parent?.removeFromParent()
            } else {
                secondBody.node?.removeFromParent()
            }
            
            
            //GameScene.popSound.runAction(SKAction.play())
            
            //popSound.removeAllActions()
            //popSound.runAction(SKAction.play())
        }
        
        // if a hook hits a brick, remove it only if the brick is marked as destructable
        if firstBody.categoryBitMask == HookCategory && secondBody.categoryBitMask == ObstacleCategory {
            
            if secondBody.node is Brick {
                let brick = secondBody.node as! Brick
                if(brick.isDestructable) {
                    brick.destroy()
                }
            }
            
            //print("hook ends")
            firstBody.node?.removeAllActions()
            firstBody.node?.removeFromParent()
        }
        
        // player loses one life every time they get hit by the ball
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == ActorCategory {
            
            GameScene.lives -= 1
            livesNode.text = "\(GameScene.lives) Lifes"
            if(GameScene.lives <= 0) {
                beginGameover()
            }
        }
    }
    
    func powerupLottery(point: CGPoint) {
        // 10% chance of spawning a powerup
        if(rand() % 2 == 0) {
        
            // randomly pick one of the 6 available powerups
            //let powerupType = PowerUp.randomPowerUp()
            let powerupType = PowerUp.powerupType.doubleHook
            let newPowerup = PowerUp(powerupName: "powerup", powerupSize: CGSize(width: 20,height: 20), type: powerupType)
            
            newPowerup.position = point
            gameNode.addChild(newPowerup)
        
            // only show powerup for 4 seconds
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
            GameScene.lives += 1
            livesNode.text = "\(GameScene.lives) Lifes"
        //case .shield:
        //case .doubleHook: nothing else needed
        //case .staticHook: time limit
        //case .timeStop: time limit
        case .dynamite:
            gameNode.enumerateChildNodesWithName(ballName, usingBlock: {
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
        
        // fire hook above actor
        selectedHook.position = CGPoint(x: actorNode.position.x, y: actorNode.position.y)
        gameNode.addChild(selectedHook)
        selectedHook.physicsBody!.applyImpulse(CGVectorMake(0, 1.2))
    }
    
    func isGameFinished() -> Bool {
        if (gameRunning && (gameNode.childNodeWithName(ballName) == nil)) {
            //let ballNode = createBall(CGPoint(x:self.frame.size.width/2, y:self.frame.size.height/2), scale: 1.0)
            //ballNode.physicsBody!.applyImpulse(CGVectorMake(5, 0))
            print("no more balls")
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
        if(isGameFinished()) {
            beginNextLevel()
        }
        
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
        gameNode.enumerateChildNodesWithName(ballName, usingBlock: {
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
