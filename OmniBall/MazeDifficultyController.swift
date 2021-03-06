//
//  mazeDifficultyController.swift
//  OmniBall
//
//  Created by Xiaoyu Chen on 4/23/15.
//  Copyright (c) 2015 Xiaoyu Chen. All rights reserved.
//

import Foundation
import SpriteKit

class MazeDifficultyController: DifficultyController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func easy(sender: AnyObject) {
        transitToGame("HiveMaze")
        //self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func hard(sender: AnyObject) {
        transitToGame("HiveMaze2")
        //self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}