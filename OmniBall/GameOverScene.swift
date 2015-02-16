//
//  GameOverScene.swift
//  try
//
//  Created by Jiafang Jiang on 1/30/15.
//  Copyright (c) 2015 Xiaoyu Chen. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    let won: Bool
    var replayBtn: SKSpriteNode!
    var controller: ViewController!
    var connection: ConnectionManager!
    
    init(size: CGSize, won: Bool) {
        self.won = won
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        connection = controller.connectionManager
        
        var layer: SKSpriteNode
        if (won){
            layer = SKSpriteNode(imageNamed: "2048x1536_you_win")
        } else {
            layer = SKSpriteNode(imageNamed: "2048x1536_you_lose")
            
        }
        layer.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(layer)
        
        replayBtn = SKSpriteNode(imageNamed: "50x50_ball")
        replayBtn.name = "replay"
        replayBtn.position = CGPoint(x: size.width - 300, y: 300)
        addChild(replayBtn)
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        let touch = touches.anyObject() as UITouch
        let loc = touch.locationInNode(self)
        if replayBtn.containsPoint(loc) && connection.gameState == .WaitingForStart{

                let myScene = GameScene.unarchiveFromFile("GameScene") as GameScene
                myScene.connection = controller.connectionManager
                myScene.scaleMode = self.scaleMode
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(myScene, transition: reveal)
            
        } else if replayBtn.containsPoint(loc) && connection.gameState == .Done{
            connection.generateRandomNumber()
        }
        
    }

    override func className() -> String{
        return "GameOverScene"
    }
    
}