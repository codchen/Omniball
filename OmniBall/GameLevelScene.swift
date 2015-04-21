//
//  GameLevelScene.swift
//  OmniBall
//
//  Created by Fang on 3/15/15.
//  Copyright (c) 2015 Xiaoyu Chen. All rights reserved.
//

import Foundation
import SpriteKit

class GameLevelScene: GameScene {
    var destPosList: [CGPoint] = []
    var whichPos = 0
    let btnComeBack = SKSpriteNode(imageNamed: "circle")
    
    override func didMoveToView(view: SKView){
        super.didMoveToView(view)
        enumerateChildNodesWithName("destHeart*") {node, _ in
            self.destPosList.append(node.position)
            node.physicsBody = nil
        }
//        println("\(destPosList.count)")
    }
    
    var currentLevel = 0
    
    override func setupDestination(origin: Bool) {
        destPointer = childNodeWithName("destPointer") as SKSpriteNode
        destPointer.zPosition = -5
        destPointer.physicsBody!.allowsRotation = false
        destPointer.physicsBody!.dynamic = false
        destPointer.physicsBody!.pinned = false
        //destHeart = childNodeWithName("destHeart") as SKShapeNode
        destHeart = SKShapeNode(circleOfRadius: 200)
        destHeart.zPosition = -10
        destHeart.position = destPointer.position
        destPointer.physicsBody?.categoryBitMask = physicsCategory.wall
        addChild(destHeart)
    }
    
    override func setupHUD() {
        super.setupHUD()
        let totalSlaveNum = ((1 + slaveNum) * (connection.maxLevel + 1))/2
        let startPos = CGPoint(x: 100, y: size.height - 300)
        for var i = 0; i < totalSlaveNum; ++i {
            let minion = SKSpriteNode(imageNamed: "80x80_star_slot")
            minion.position = startPos + CGPoint(x: CGFloat(i) * (minion.size.width), y: 0)
            minion.position = hudLayer.convertPoint(minion.position, fromNode: self)
            hudMinions.append(minion)
            hudLayer.addChild(minion)
            collectedMinions.append(false)
        }
                
        for peer in connection.peersInGame.peers {
            var peerScore: Int = peer.score
            while peerScore > 0 {
                addHudStars(peer.playerID)
                peerScore--
            }
        }
    
        btnComeBack.name = "comeBack"
        btnComeBack.position = CGPoint(x: size.width - 100, y: 300)
        btnComeBack.position = hudLayer.convertPoint(btnComeBack.position, fromNode: self)
        btnComeBack.setScale(1.5)
        hudLayer.addChild(btnComeBack)
    }
    
    override func setupNeutral() {
        enumerateChildNodesWithName("neutral*"){ node, _ in
            let neutralNode = node as SKSpriteNode
            neutralNode.size = CGSize(width: 110, height: 110)
            neutralNode.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "staro"), size: CGSize(width: 110, height: 110))
            neutralNode.physicsBody?.dynamic = false
            neutralNode.physicsBody!.restitution = 1
            neutralNode.physicsBody!.linearDamping = 0
            neutralNode.physicsBody!.categoryBitMask = physicsCategory.target
            neutralNode.physicsBody!.contactTestBitMask = physicsCategory.Me
            self.neutralBalls[neutralNode.name!] = NeutralBall(node: neutralNode, lastCapture: 0)
        }
    }
    
    override func addHudStars(id: UInt16) {
        var startIndex = 0
        let player = getPlayerByID(id)!
        while collectedMinions[startIndex] {
            startIndex++
        }
        collectedMinions[startIndex] = true
        hudMinions[startIndex].texture = SKTexture(imageNamed: getSlaveImageName(player.color, false))

    }
    
    override func checkGameOver() {
        
        if remainingSlave == 0 && currentLevel == connection.maxLevel {
            var maxScore: Int = connection.peersInGame.getMaxScore()
            println("in checking game over")
            println("maxscore: \(maxScore), me score: \(connection.me.score)")
            if maxScore == connection.me.score {
                gameOver = true
                connection.sendGameOver()
                println("Game Over?")
                gameOver(won: true)
            }
        }
    }
    
    override func scored() {
        super.scored()
        self.remainingSlave--
        addHudStars(myNodes.id)
        if remainingSlave == 0 {
            checkGameOver()
            if (gameOver == false && connection.controller.currentLevel < connection.maxLevel){
                connection.sendPause()
                paused()
            }
        }
    }
    
    override func paused(){
        player.stop()
        physicsWorld.speed = 0
        let levelScene = LevelXScene(size: self.size, level: currentLevel + 1)
        levelScene.scaleMode = self.scaleMode
        levelScene.controller = connection.controller
        levelScene.connection = connection
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        view?.presentScene(levelScene, transition: reveal)
        
    }
    
    override func changeDest(){
        whichPos++
        destPointer.position = destPosList[whichPos % destPosList.count]
        destHeart.position = destPosList[whichPos % destPosList.count]
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let loc = touch.locationInNode(self)
        myNodes.touchesBegan(loc)
        if btnComeBack.containsPoint(hudLayer.convertPoint(loc, fromNode: self)) {
            println("pressed button")
            anchorPoint = CGPoint(x: -myNodes.players[0].position.x/size.width + 0.5,
                y: -myNodes.players[0].position.y/size.height + 0.5)
            hudLayer.position = CGPoint(x: -anchorPoint.x * size.width, y: -anchorPoint.y * size.height)
        }
        else if btnExit.containsPoint(hudLayer.convertPoint(loc, fromNode: self)) {
            println("we got btnexit")
            var alert = UIAlertController(title: "Exit Game", message: "Are you sure you want to exit game?", preferredStyle: UIAlertControllerStyle.Alert)
            let yesAction = UIAlertAction(title: "Yes", style: .Default) { action in
                self.connection.sendExit()
                self.connection.exitGame()
                UIView.transitionWithView(self.view!, duration: 0.5,
                    options: UIViewAnimationOptions.TransitionFlipFromBottom,
                    animations: {
                        self.view!.removeFromSuperview()
                        self.connection.controller.clearCurrentView()
                    }, completion: nil)
                
            }
            alert.addAction(yesAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            connection.controller.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
