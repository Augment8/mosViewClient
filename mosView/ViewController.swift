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

class User {
    var isStealth = false
    let node: SKNode
    
    init(node: SKNode) {
        self.node = node
    }
}

class GameScene: SKScene {
    var users = [NSString: User]()
    let rate: Double = 1

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

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    typealias Input = NSDictionary
    func updateUser(id: NSString, input: Input) {
        if let _ = users[id] {
        } else {
            let user = SKNode()
            let r: CGFloat = 10.0
            user.physicsBody =  SKPhysicsBody.init(circleOfRadius: r)
            user.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
            addChild(user)

            let name = SKLabelNode(fontNamed:"Chalkduster")
            name.name = "name"
            name.fontSize = 20
            name.fontColor = UIColor.blackColor()
            name.position = CGPoint(x:0, y:-40)
            user.addChild(name)
            
            let path = CGPathCreateMutable();
            CGPathAddArc(path, nil, 0, 0, r, 0, CGFloat(M_PI * 2), true);
            let circle = SKShapeNode(path: path)
            circle.name = "object"
            circle.strokeColor = UIColor.blackColor()
            circle.position = CGPointMake(0,0)
            user.addChild(circle)
            
            users[id] = User(node: user)
        }
        if let user = users[id] {
            if let name = input["name"] {
                if let nameNode = user.node.childNodeWithName("name") {
                    (nameNode as! SKLabelNode).text = name as? String
                }
            }
            if let type = input["type"] as? String {
                switch type {
                    case "gravity":
                        if let x = input["x"] as? NSNumber,y = input["y"] as? NSNumber {
                            user.node.physicsBody?.applyForce(CGVector(dx: x.doubleValue * rate, dy: y.doubleValue * rate))
                        }
                    case "touchstart":
                        user.isStealth = true
                        if let objNode = user.node.childNodeWithName("object") as! SKShapeNode? {
                            objNode.strokeColor = UIColor.clearColor()
                        }
                        if let objNode = user.node.childNodeWithName("name") as! SKLabelNode? {
                            objNode.fontColor = UIColor.clearColor()
                        }
                    case "touchend":
                        user.isStealth = false
                        if let objNode = user.node.childNodeWithName("object") as! SKShapeNode? {
                            objNode.strokeColor = UIColor.blackColor()
                        }
                        if let objNode = user.node.childNodeWithName("name") as! SKLabelNode? {
                            objNode.fontColor = UIColor.blackColor()
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

