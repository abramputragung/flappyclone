//
//  GameScene.swift
//  FlappyClone
//
//  Created by Abraham Sidabutar on 2/17/16.
//  Copyright (c) 2016 Abraham Sidabutar. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let ghost: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
    static let score: UInt32 = 0x1 << 4
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground = SKSpriteNode()
    var ghost = SKSpriteNode()
    
    var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    
    var scoreLbl = SKLabelNode()
    
    var died = Bool()
    
    var restartBTN = SKSpriteNode()
    
    func restartScene() {
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene() {
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLbl.text = "\(score)"
        scoreLbl.fontName = "04b_19"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 60
        self.addChild(scoreLbl)
        
        ground = SKSpriteNode(imageNamed: "Ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: self.frame.width / 2, y: 0 + ground.frame.height / 2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.ghost
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.dynamic = false
        
        ground.zPosition = 3
        
        self.addChild(ground)
        
        ghost = SKSpriteNode(imageNamed: "Ghost")
        ghost.size = CGSize(width: 60, height: 70)
        ghost.position = CGPoint(x: self.frame.width / 2 - ghost.frame.width, y: self.frame.height / 2)
        
        ghost.physicsBody = SKPhysicsBody(circleOfRadius: ghost.frame.height / 2)
        ghost.physicsBody?.categoryBitMask = PhysicsCategory.ghost
        ghost.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        ghost.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.score
        ghost.physicsBody?.affectedByGravity = false
        ghost.physicsBody?.dynamic = true
        
        ghost.zPosition = 2
        
        
        self.addChild(ghost)

    }
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        createScene()
        
    }
    
    func createBTN() {
        
        restartBTN = SKSpriteNode(imageNamed: "RestartBtn")
        restartBTN.size = CGSizeMake(200, 100)
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        
        restartBTN.runAction(SKAction.scaleTo(1.0, duration: 0.3))
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.score && secondBody.categoryBitMask == PhysicsCategory.ghost {
            
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
            
        
        } else if firstBody.categoryBitMask == PhysicsCategory.ghost && secondBody.categoryBitMask == PhysicsCategory.score {
            
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        }
        
        else if firstBody.categoryBitMask == PhysicsCategory.ghost && secondBody.categoryBitMask == PhysicsCategory.wall || firstBody.categoryBitMask == PhysicsCategory.wall && secondBody.categoryBitMask == PhysicsCategory.ghost {
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({ (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            }))
            
            if died == false{
                died = true
                createBTN()
            }
        }
        
        else if firstBody.categoryBitMask == PhysicsCategory.ghost && secondBody.categoryBitMask == PhysicsCategory.ground || firstBody.categoryBitMask == PhysicsCategory.ground && secondBody.categoryBitMask == PhysicsCategory.ghost {
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({ (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            }))
            
            if died == false{
                died = true
                createBTN()
            }
        }

    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */

        if  gameStarted == false {
            
            gameStarted = true
            
            ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.runBlock ({
                () in
                
                self.createWalls()
                
            })
            
            let delay = SKAction.waitForDuration(1.5)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(spawnDelay)
            self.runAction(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.008 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes,removePipes])
            
            ghost.physicsBody?.velocity = CGVectorMake(0, 0)
            ghost.physicsBody?.applyImpulse(CGVectorMake(0, 90))
            
            
        } else {
            if died == true {
                
            } else {
                
                ghost.physicsBody?.velocity = CGVectorMake(0, 0)
                ghost.physicsBody?.applyImpulse(CGVectorMake(0, 90))
               
            }
            
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if died == true {
                if restartBTN.containsPoint(location){
                    restartScene()
                }
                
            }
        }
  
    }
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 350)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.ghost
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.addChild(scoreNode)
        
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted == true {
            if died == false {
                enumerateChildNodesWithName("background", usingBlock: ({
                    (node, error) in
                    
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                    }
                    
                }))
            }
        }
    }
}
