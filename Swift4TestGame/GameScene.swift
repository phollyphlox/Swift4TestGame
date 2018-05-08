//
//  GameScene.swift
//  Swift4TestGame
//
//  Created by Apple28 on 5/2/18.
//  Copyright © 2018 Apple28. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var plane = SKSpriteNode()
    var background = SKSpriteNode()
    var ground = SKSpriteNode()
    var labelHolder = SKSpriteNode()
    let planeGroup:UInt32 = 1 << 0
    let objectGroup:UInt32 = 1 << 1
    let gapGroup:UInt32 = 1 << 2
    var gameOver = false
    var score = 0
    var movingObjects = SKNode()
    var scoreLabel = SKLabelNode()
    var startLabel = SKLabelNode()
    var gameLabel = SKLabelNode()
    var contactQueue = [SKPhysicsContact]()
    
    func makeBackground(){
        let backgroundImage = SKTexture(imageNamed: "background.png")
        let moveBackground = SKAction.moveBy(x: -backgroundImage.size().width, y: 0, duration: 9)
        let replaceBackground = SKAction.moveBy(x: backgroundImage.size().width, y: 0, duration: 0)
        let moveBackgroundForever = SKAction.repeatForever(SKAction.sequence([moveBackground, replaceBackground]))
        
        for x in 0..<3{
            let i = CGFloat(x)
            background = SKSpriteNode(texture: backgroundImage)
            background.name = "background"
            background.position = CGPoint(x: backgroundImage.size().width * i, y: -self.frame.midY)
            background.size.height = self.frame.height
            background.run(moveBackgroundForever)
            background.zPosition = -1
            movingObjects.addChild(background)
        }
    }
    
    
    func makePlane() {
        let planeImage = SKTexture(imageNamed: "planeRed1.png")
        let planeImage2 = SKTexture(imageNamed: "planeRed2.png")
        let planeImage3 = SKTexture(imageNamed: "planeRed3.png")
        let animation = SKAction.animate(with: [planeImage, planeImage2, planeImage3], timePerFrame: 0.1)
        let makePlaneFly = SKAction.repeatForever(animation)
        
        plane = SKSpriteNode(texture: planeImage)
        plane.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        plane.run(makePlaneFly)
        
        plane.physicsBody = SKPhysicsBody(texture: plane.texture!, size: plane.texture!.size())
        plane.physicsBody?.isDynamic = true
        plane.physicsBody?.allowsRotation = false
        plane.physicsBody?.affectedByGravity = false
        plane.physicsBody?.categoryBitMask = planeGroup
        plane.physicsBody?.collisionBitMask = objectGroup
        plane.physicsBody?.contactTestBitMask = gapGroup | objectGroup
        plane.zPosition = 10 //Makes plane always on top because zed position is higher than other images which have a zed position of 0 by default
        
        self.addChild(plane)
    }
    
    @objc func makeRocks() {
        if(gameOver == false ){
            let rock1Image = SKTexture(imageNamed: "rockDownSnow.png")
            let rock1 = SKSpriteNode(texture: rock1Image)
            let rock2Image = SKTexture(imageNamed: "rockGrass.png")
            let rock2 = SKSpriteNode(texture: rock2Image)
            let coinImage = SKTexture(imageNamed: "Star_Coin.png")
            let gapCoin = SKSpriteNode(texture: coinImage)
            let gapHeight = plane.size.height
            let rock1Offset = arc4random() % UInt32(self.frame.size.height / 4)
            let rock2Offset = arc4random() % UInt32(self.frame.size.height / 4)
            let addRocks = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: TimeInterval(self.frame.size.width / 100))
            let removeRocks = SKAction.removeFromParent()
            let moveRocks = SKAction.sequence([addRocks, removeRocks])
            
            rock1.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + rock1Image.size().height / 2 + gapHeight / 2 + CGFloat(rock1Offset))
            rock1.run(moveRocks)
            rock1.physicsBody = SKPhysicsBody(rectangleOf: rock1.size)
            rock1.physicsBody?.isDynamic = false
            rock1.physicsBody?.categoryBitMask = objectGroup
            rock1.zPosition = 1
            movingObjects.addChild(rock1)
            
            rock2.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY - rock2Image.size().height / 2 - gapHeight / 2 - CGFloat(rock2Offset))
            rock2.run(moveRocks)
            rock2.physicsBody = SKPhysicsBody(rectangleOf: rock1.size)
            rock2.physicsBody?.isDynamic = false
            rock2.physicsBody?.categoryBitMask = objectGroup
            rock2.zPosition = 1
            movingObjects.addChild(rock2)
            
             n
            gapCoin.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + CGFloat(rock1Offset) - CGFloat(rock2Offset))
            gapCoin.physicsBody = SKPhysicsBody(rectangleOf: gapCoin.size)
            gapCoin.run(moveRocks)
            gapCoin.physicsBody?.isDynamic = false
            gapCoin.physicsBody?.categoryBitMask = gapGroup
            movingObjects.addChild(gapCoin)
        }
    }
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        self.addChild(movingObjects)
        movingObjects.isPaused = true
        movingObjects.speed = 0
        makeBackground()
        
        //make ground
       let ground = SKNode()
        ground.position = CGPoint(x: 0, y: -self.frame.height/2 + 1)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = objectGroup
        self.addChild(ground)
 
        //create score label
        self.addChild(labelHolder)
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/3)
        scoreLabel.zPosition = 9 //zed position is higher than rocks so the score can not be covered by rocks
        self.addChild(scoreLabel)
        
        startLabel.fontName = "Helvetica"
        startLabel.fontSize = 30
        startLabel.text = "Tap to Play"
        startLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        startLabel.zPosition = 11
        self.addChild(startLabel)
        
        makePlane()
        
        //sets the timer for the intervals when new rocks appear on the scene
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.makeRocks), userInfo: nil, repeats: true)
        
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //Called when sprites come in contact with another sprite
        contactQueue.append(contact)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if(gameOver == false){
            startLabel.removeFromParent()
            plane.physicsBody?.affectedByGravity = true
            plane.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            plane.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 30))
            movingObjects.isPaused = false
            movingObjects.speed = 1
        }else{
            score = 0
            scoreLabel.text = "0"
            movingObjects.removeAllChildren()
            makeBackground()
            plane.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            labelHolder.removeAllChildren()//this removes only the game over label
            plane.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            gameOver = false
            movingObjects.speed = 1
            
        }
    }
    
    func handle(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
            return
        }
       
       if (contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup){
            score += 1
            scoreLabel.text = "\(score)"
            if contact.bodyA.categoryBitMask == gapGroup {
                contact.bodyA.node!.removeFromParent()
            } else {
                contact.bodyB.node!.removeFromParent()
            }
       } else {
            if gameOver == false{
                gameOver = true
                movingObjects.speed = 0
                gameLabel.fontName = "Helvetica"
                gameLabel.fontSize = 30
                gameLabel.text = "Game Over! Tap to play again."
                gameLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                gameLabel.zPosition = 10
                labelHolder.addChild(gameLabel)
        }
    }
}
    
    func processContacts(forUpdate currenTime: CFTimeInterval) {
        for contact in contactQueue {
            handle(contact)
            if let index = contactQueue.index(of: contact) {
                contactQueue.remove(at: index)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
         processContacts(forUpdate: currentTime)
        }
        
    }

