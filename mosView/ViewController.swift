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

class Team {
    let color: UIColor
    
    init(color: UIColor) {
        self.color = color
    }
}

class User {
    var isStealth = false
    let team: Team
    let node: SKNode
    
    init(node: SKNode, team: Team) {
        self.node = node
        self.team = team
    }
}

class GameScene: SKScene {
    var isInit = false
    var users = [NSString: User]()
    var redTeam = Team(color: UIColor(hue: 0.14, saturation: 1, brightness: 1, alpha: 1))
    var redTeamMembers = [User]()
    var blueTeam = Team(color: UIColor(hue: 0.54, saturation: 1, brightness: 1, alpha: 1))
    var blueTeamMembers = [User]()
    let rate: Double = 0.6
    let width: CGFloat = 600.0
    let field = SKSpriteNode(
        color: UIColor.whiteColor(),
        size: CGSize(width: 600, height: 600)
    )
    var fieldColor = [[SKSpriteNode]]()
    var redCount: Int = 0
    var redLabel: SKLabelNode = SKLabelNode()
    var blueLabel: SKLabelNode = SKLabelNode()
    var blueCount: Int = 0

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        physicsWorld.gravity = CGVectorMake(0, 0)
        field.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        physicsBody = SKPhysicsBody(edgeLoopFromRect: field.frame)
        addChild(field)
        
        blueLabel = SKLabelNode(fontNamed:"Chalkduster")
        blueLabel.name = "blue"
        blueLabel.fontColor = blueTeam.color
        blueLabel.position = CGPoint(x: 100, y: 500)
        addChild(blueLabel)
        
        redLabel = SKLabelNode(fontNamed:"Chalkduster")
        redLabel.name = "red"
        redLabel.fontColor = redTeam.color
        redLabel.position = CGPoint(x: 100, y: 200)
        addChild(redLabel)
        
        let mapSize = 20
        let mapTipWidth = width / CGFloat(mapSize)
        for i in 0..<mapSize {
            fieldColor.append([])
            for j in 0..<mapSize {
                let node: SKSpriteNode = SKSpriteNode(color:UIColor.whiteColor(), size: CGSizeMake(mapTipWidth, mapTipWidth))
                node.position = CGPoint(x: mapTipWidth * CGFloat(i) - 300 + 15, y:  mapTipWidth * CGFloat(j) - 300 + 15
                )
                fieldColor[i].append(node)
                field.addChild(node)
            }
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if !isInit {
            return
        }
        for user: User in users.values {
            NSLog("user %lf %lf", user.node.position.x, user.node.position.y)
            let dx = user.node.position.x - 215
            let dy = user.node.position.y - 95
            let x = dx / 30
            let y = dy / 30
            // NSLog("px: %lf py: %lf, x: %d, y: %d", dx, dy, Int(x) ,Int(y))

            if x < 20 && x >= 0 && y < 20 && y >= 0{
                fieldColor[Int(x)][Int(y)].color = user.team.color
            }
        }

        blueCount = 0
        redCount = 0
        for i in 0..<20 {
            for j in 0..<20  {
                let color = fieldColor[i][j].color
                if color.description == blueTeam.color.description {
                    blueCount += 1
                } else if color.description == redTeam.color.description {
                    redCount += 1
                }
            }
        }
        let bluePer = Int(CGFloat(blueCount) / 4)
        blueLabel.text = String(format: "blue %d%%", bluePer)
        let redPer = Int(CGFloat(redCount) / 4)
        redLabel.text = String(format: "yellow %d%%", redPer)
        NSLog("blue: %d, red: %d", blueCount, redCount)
        
        /*
        let node: SKSpriteNode = fieldColor[Int(rand() % 20)][Int(rand() % 20)]
        switch rand() % 3 {
        case 1:
            node.color = redTeam.color
        case 2:
            node.color = blueTeam.color
        default:
            node.color = UIColor.whiteColor()
        }
*/
    }
    typealias Input = NSDictionary
    func updateUser(id: NSString, input: Input) {
        if let _ = users[id] {
        } else {
            let user = SKNode()
            let r: CGFloat = 15.0
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
            
            if redTeamMembers.count < blueTeamMembers.count {
                let u = User(node: user, team: redTeam)
                users[id] = u
                redTeamMembers.append(u)
                circle.fillColor = redTeam.color
            } else {
                let u = User(node: user, team: blueTeam)
                users[id] = u
                blueTeamMembers.append(u)
                circle.fillColor = blueTeam.color
            }
            isInit = true
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
                            user.node.physicsBody?.applyImpulse(CGVector(dx: x.doubleValue * rate, dy: y.doubleValue * rate))
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
//            NSLog("%@", json)
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

