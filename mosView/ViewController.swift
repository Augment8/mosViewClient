//
//  ViewController.swift
//  mosView
//
//  Created by eiel on 2015/11/18.
//  Copyright © 2015年 eiel. All rights reserved.
//

import UIKit
import Starscream
import SpriteKit

import SpriteKit

class GameScene: SKScene {
    var users = [NSString: SKNode]()
    let rate = 0.3

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        let square = SKSpriteNode(
            color: UIColor.whiteColor(),
            size: size
        )
        square.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        addChild(square)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    typealias Input = NSDictionary
    func updateUser(id: NSString, input: Input) {
        if let _ = users[id] {
        } else {
            let myLabel = SKLabelNode(fontNamed:"Chalkduster")
            myLabel.fontSize = 45
            myLabel.fontColor = UIColor.blackColor()
            myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
            myLabel.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 10, height: 10))
            
            self.addChild(myLabel)
            users[id] = myLabel
        }
        if let user = users[id] {
            if let name = input["name"] {
                (user as! SKLabelNode).text = name as? String
            }
            if let type = input["type"] as? String {
                switch type {
                    case "gravity":
                        if let x = input["x"] as? NSNumber,y = input["y"] as? NSNumber {
                            user.physicsBody?.applyForce(CGVector(dx: x.doubleValue * rate, dy: y.doubleValue * rate))
                    }
                    default: break
                }
            }
        }
    }
}

class ViewController: UIViewController, WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocket) {
        NSLog("websocketDidConnect")
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        NSLog("websocketDidDisconnect")
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
            NSLog("%@", json)
            _scene.updateUser(json["id"] as! NSString, input: json)
        } catch {
            NSLog("json serializa error")
        }
    }
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {

    }
    

    let socket: WebSocket = WebSocket(url: NSURL(string: "ws://au8mos.herokuapp.com")!, protocols: ["mos-view"])
    var _scene: GameScene! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
        socket.connect()
        if let scene = GameScene(fileNamed:"GameScene") {
            _scene = scene
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFit
            
            skView.presentScene(scene)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

