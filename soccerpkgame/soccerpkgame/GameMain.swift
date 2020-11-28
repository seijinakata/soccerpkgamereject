//
//  GameMain.swift
//  soccerpkgame
//
//  Created by Owner on 8/21/1399 AP.
//

import UIKit
import QuartzCore
import SceneKit

class GameMain: UIViewController,SCNSceneRendererDelegate,SCNPhysicsContactDelegate {

    enum GameMainState:Int{
        case GameMainPlay
        case GameMainFault
        case GameMainSuccess
    }
    
    var gameMainState = GameMainState.GameMainPlay
    var isgameMainRendererWait = false
    
    var isballfootCollision = false
    var isballfloorCollision = false
    var isballOver = false
    var isGoalSuccess = false
    var isKick = false
    var isBallMove = false
    
    var mankickTime = 0
    let shootMax = 10
    var shootCounter = 0
    var playerRaius:Float = 0.0
    var manKickSpeed:CGFloat = 0.0
    var manKickSpeedPercent:CGFloat = 0.55
    var Shoot = 0
    var goalSuccess = 0
    
    var GameMainScene:SCNScene?
    var scnView:SCNView?
    //初期に戻すため
    var ballNodeBase:SCNNode! = SCNNode()
    var playerNodeBase:SCNNode! = SCNNode()
    var keeperNodeBase:SCNNode! = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()
          // retrieve the SCNView
          scnView = SCNView(frame: UIScreen.main.bounds)
          self.view = scnView

          // allows the user to manipulate the camera
          //scnView?.allowsCameraControl = true
          
          // show statistics such as fps and timing information
          //scnView?.showsStatistics = true
          
          // configure the view
          scnView?.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 1.0)
          
          // add a tap gesture recognizer
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
          scnView?.addGestureRecognizer(tapGesture)

          //renderer
          scnView?.delegate = self
        
        Shoot = 0
        goalSuccess = 0
        gameMainState = GameMainState.GameMainPlay
        isgameMainRendererWait = false

        // create a new scene
        GameMainScene = SCNScene()
        GameMainScene?.physicsWorld.contactDelegate = self

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        GameMainScene?.rootNode.addChildNode(cameraNode)
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 3, z: -4)
        cameraNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:Float.pi)
        cameraNode.camera?.zFar = 50
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.gray
        GameMainScene?.rootNode.addChildNode(ambientLightNode)
        
        //floor
        let floorGround = SCNFloor();
        floorGround.reflectivity = 0.0
        floorGround.firstMaterial?.diffuse.contents = "art.scnassets/background/grass.jpg"
        floorGround.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(10, 10, 0)
        let floorNode = SCNNode();
        floorNode.geometry = floorGround
        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        floorNode.name = "groundfloor"
        let floorBody = SCNPhysicsBody(type: .static, shape: nil)
        floorBody.restitution = 0.0
        floorBody.friction = 1.0
        floorBody.contactTestBitMask = 0b0100
        floorNode.physicsBody = floorBody
        GameMainScene?.rootNode.addChildNode(floorNode)
        
        //rightfloorover
        let leftfloorGeom = SCNBox(width: 140.0, height: 0.5, length: 140.0, chamferRadius: 0)
        let leftfloorPlane = SCNNode(geometry: leftfloorGeom)
        leftfloorPlane.position.x = -76
        leftfloorPlane.position.y = 0.0
        leftfloorPlane.position.z = 50.0
        leftfloorPlane.name = "rightfloorplane"
        let leftfloorBody =  SCNPhysicsBody(type: .static, shape: nil)
        leftfloorBody.contactTestBitMask = 0b0001
        leftfloorBody.collisionBitMask = 0b0000
        leftfloorPlane.physicsBody = leftfloorBody
        leftfloorGeom.firstMaterial?.diffuse.contents = UIColor.clear
        GameMainScene?.rootNode.addChildNode(leftfloorPlane)
        
        //leftfloorover
        let rightfloorGeom = SCNBox(width: 140.0, height: 0.5, length: 140.0, chamferRadius: 0)
        let rightfloorPlane = SCNNode(geometry: rightfloorGeom)
        rightfloorPlane.position.x = 76
        rightfloorPlane.position.y = 0.0
        rightfloorPlane.position.z = 50.0
        rightfloorPlane.name = "leftfloorplane"
        let rightfloorBody =  SCNPhysicsBody(type: .static, shape: nil)
        rightfloorBody.contactTestBitMask = 0b0001
        rightfloorBody.collisionBitMask = 0b0000
        rightfloorPlane.physicsBody = rightfloorBody
        rightfloorGeom.firstMaterial?.diffuse.contents = UIColor.clear
        GameMainScene?.rootNode.addChildNode(rightfloorPlane)
        
        //backfloorover
        let backfloorGeom = SCNBox(width: 140.0, height: 0.5, length: 140.0, chamferRadius: 0)
        let backfloorPlane = SCNNode(geometry: backfloorGeom)
        backfloorPlane.position.x = 0
        backfloorPlane.position.y = 0.0
        backfloorPlane.position.z = 85.0
        backfloorPlane.name = "backfloorplane"
        let backfloorBody =  SCNPhysicsBody(type: .static, shape: nil)
        backfloorBody.contactTestBitMask = 0b0010
        backfloorBody.collisionBitMask = 0b0000
        backfloorPlane.physicsBody = backfloorBody
        backfloorGeom.firstMaterial?.diffuse.contents = UIColor.clear
        GameMainScene?.rootNode.addChildNode(backfloorPlane)
        
        //background
        let earthSphere = SCNSphere(radius: 40)
        earthSphere.firstMaterial?.diffuse.contents = "art.scnassets/background/sky.jpg"
        earthSphere.firstMaterial?.isDoubleSided = true
        let earthSphereNode = SCNNode(geometry: earthSphere)
        earthSphereNode.position = SCNVector3(x: 0, y: 0, z: 0)
        GameMainScene?.rootNode.addChildNode(earthSphereNode)
        
        //kickbutton
        let kickButton = SCNScene(named: "art.scnassets/background/kickbutton.scn")
        let kickButtonNode:SCNNode! = kickButton?.rootNode.childNode(withName: "kickbutton", recursively: true)
        kickButtonNode.position = SCNVector3(x: -1.7, y: 1.5, z: -1.0)
        kickButtonNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:3.14)
        kickButtonNode.name = "kickbutton"
        GameMainScene?.rootNode.addChildNode(kickButtonNode)
        
        //rightarrowButton
        let rightarrowButton = SCNScene(named: "art.scnassets/background/rightarrow.scn")
        let rightarrowButtonNode:SCNNode! = rightarrowButton?.rootNode.childNode(withName: "rightarrow", recursively: true)
        rightarrowButtonNode.position = SCNVector3(x: 1.7, y: 2.5, z: -1.0)
        rightarrowButtonNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:Float.pi)
        rightarrowButtonNode.name = "rightarrow"
        GameMainScene?.rootNode.addChildNode(rightarrowButtonNode)
        
        //leftarrowButton
        let leftarrowButton = SCNScene(named: "art.scnassets/background/leftarrow.scn")
        let leftarrowButtonNode:SCNNode! = leftarrowButton?.rootNode.childNode(withName: "leftarrow", recursively: true)
        leftarrowButtonNode.position = SCNVector3(x: 1.8, y: 1.3, z: -1.1)
        leftarrowButtonNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:Float.pi)
        leftarrowButtonNode.name = "leftarrow"
        GameMainScene?.rootNode.addChildNode(leftarrowButtonNode)
        
        //goaltext
        let prePower = GameMainScene?.rootNode.childNode(withName: "powerplane", recursively: true)
         prePower?.removeFromParentNode()
        let str = "GOAL"
        let text = SCNText(string: str, extrusionDepth: 0.01)
        text.font = UIFont.systemFont(ofSize: 0.4)
        text.firstMaterial?.diffuse.contents = UIColor.blue
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(x: -1.0, y: 2.1, z: -1.0)
        textNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:3.14)
        GameMainScene?.rootNode.addChildNode(textNode)
        
        //powertext
        let powerStr = "POWER"
        let powerText = SCNText(string: powerStr, extrusionDepth: 0.01)
        powerText.font = UIFont.systemFont(ofSize: 0.3)
        powerText.firstMaterial?.diffuse.contents = UIColor.blue
        let powerTextNode = SCNNode(geometry: powerText)
        powerTextNode.position = SCNVector3(x: 2.2, y: 2.7, z: -1.0)
        powerTextNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:3.14)
        GameMainScene?.rootNode.addChildNode(powerTextNode)
        
        //goal
        let goalPost = SCNScene(named: "art.scnassets/background/goal.scn")!
        //postset
        let postUp = goalPost.rootNode.childNode(withName: "postup", recursively: true)!
        let postLeft = goalPost.rootNode.childNode(withName: "postleftside", recursively: true)!
        let postRight = goalPost.rootNode.childNode(withName: "postrightside", recursively: true)!
        let postBack = goalPost.rootNode.childNode(withName: "postback", recursively: true)!
        let postupBody = SCNPhysicsBody(type: .static, shape: nil)
        let postleftBody = SCNPhysicsBody(type: .static, shape: nil)
        let postrightBody = SCNPhysicsBody(type: .static, shape: nil)
        let postbackBody = SCNPhysicsBody(type: .static, shape: nil)
        postUp.physicsBody = postupBody
        postLeft.physicsBody = postleftBody
        postRight.physicsBody = postrightBody
        postBack.physicsBody = postbackBody
        postUp.position =  SCNVector3(0.0, 0.0, 8.0)
        postUp.rotation = SCNVector4(0,1,0,Float.pi)
        GameMainScene?.rootNode.addChildNode(postUp)
        
        gameinit(loadFirst: true)
        
        //goalsuccess
        let goalSuccess = SCNScene(named: "art.scnassets/background/goalsuccess.scn")!
        let postSuccessNode = goalSuccess.rootNode.childNode(withName: "goalsuccess", recursively: true)!
        let postSuccessBody = SCNPhysicsBody(type: .static, shape: nil)
        postSuccessBody.contactTestBitMask = 0b0010
        postSuccessBody.collisionBitMask = 0b0000
        postSuccessNode.physicsBody = postSuccessBody
        postSuccessNode.position =  SCNVector3(0.0, -0.8, 16.0)
        postSuccessNode.name = "goalsuccess"
        GameMainScene?.rootNode.addChildNode(postSuccessNode)
        
        //rendererを強制的に動かすため
        let rendererGeom = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        rendererGeom.firstMaterial?.diffuse.contents = UIColor.clear
        let rendererPlane = SCNNode(geometry: rendererGeom)
        rendererPlane.position = SCNVector3(0.0, 3.0, 0.0)
        GameMainScene?.rootNode.addChildNode(rendererPlane)
        rendererPlane.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // set the scene to the view
        scnView?.scene = GameMainScene
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if gameMainState == GameMainState.GameMainPlay{
            if isKick == false{
                shootCounter += 1
                if shootCounter >= 6{
                    manKickSpeed += 0.1
                    if manKickSpeed > 1.5 * manKickSpeedPercent{
                        manKickSpeed = 1.0 * manKickSpeedPercent
                    }
                    //powerbar
                    let prePower = GameMainScene?.rootNode.childNode(withName: "powerplane", recursively: true)
                    prePower?.removeFromParentNode()
                    let powerPercentage = manKickSpeed - (1.0 * manKickSpeedPercent)
                    let powerLength = 12 * powerPercentage
                        if powerPercentage > 0.0{
                            let powerGeom = SCNPlane(width: powerLength, height: 0.5)
                            let powerPlane = SCNNode(geometry: powerGeom)
                            powerPlane.position = SCNVector3(1.3-powerLength/2.0,4.0,0.0)
                            powerPlane.name = "powerplane"
                            powerGeom.firstMaterial?.diffuse.contents = UIColor.red
                            powerGeom.firstMaterial?.isDoubleSided = true
                            GameMainScene?.rootNode.addChildNode(powerPlane)
                         }
                    shootCounter = 0
                }
            }else{
                let soccerBall = GameMainScene?.rootNode.childNode(withName: "soccerball", recursively: true)
                //蹴りミス対策
                if isBallMove == false{
                    if soccerBall!.presentation.position.z < -1.0 && soccerBall!.physicsBody!.velocity.z < 0.0{
                        gamereset()
                        return
                        
                    }
                    if soccerBall!.physicsBody!.velocity.y < 0.0 && soccerBall!.physicsBody!.velocity.z < 9.0{
                        soccerBall!.position = SCNVector3(0.0, 0.05, 0.5)
                        return
                        
                    }
                    //蹴った結果初期値より場所速さが上になったらボールが動いたとみなす
                    if soccerBall!.physicsBody!.velocity.z >= 9.0 && soccerBall!.physicsBody!.velocity.y > 4.0{
                        isBallMove = true
                        isballfloorCollision = false
                    }
                }
                if isGoalSuccess == true && isgameMainRendererWait == false{
                    //goaltext
                    let str = "GOAL"
                    let text = SCNText(string: str, extrusionDepth: 0.01)
                    text.font = UIFont.systemFont(ofSize: 1)
                    text.firstMaterial?.diffuse.contents = UIColor.yellow
                    let textNode = SCNNode(geometry: text)
                    textNode.name = "faultsuccess"
                    textNode.position = SCNVector3(x: 1.3, y: 1, z: -2.0)
                    textNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:3.14)
                    GameMainScene?.rootNode.addChildNode(textNode)
                    gameMainState = GameMainState.GameMainSuccess
                    isgameMainRendererWait = true
                    return
                }
                if isballOver == true && isgameMainRendererWait == false{
                    //faulttext
                    let str = "FAIL"
                    let text = SCNText(string: str, extrusionDepth: 0.01)
                    text.font = UIFont.systemFont(ofSize: 1)
                    text.firstMaterial?.diffuse.contents = UIColor.yellow
                    let textNode = SCNNode(geometry: text)
                    textNode.name = "faultsuccess"
                    textNode.position = SCNVector3(x: 1.0, y: 1, z: -2.0)
                    textNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:3.14)
                    GameMainScene?.rootNode.addChildNode(textNode)
                    gameMainState = GameMainState.GameMainFault
                    isgameMainRendererWait = true
                    return
                }

                if isballfloorCollision == true && isBallMove == true && isgameMainRendererWait == false{
                    let soccerBall = GameMainScene?.rootNode.childNode(withName: "soccerball", recursively: true)
                    //0.15は見た目ボールが止まって見える
                    if soccerBall!.physicsBody!.velocity.z <= 0.15{
                        //faulttext
                        let str = "FAIL"
                        let text = SCNText(string: str, extrusionDepth: 0.01)
                        text.font = UIFont.systemFont(ofSize: 1)
                        text.firstMaterial?.diffuse.contents = UIColor.yellow
                        let textNode = SCNNode(geometry: text)
                        textNode.name = "faultsuccess"
                        textNode.position = SCNVector3(x: 1.0, y: 1, z: -2.0)
                        textNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:3.14)
                        GameMainScene?.rootNode.addChildNode(textNode)
                        gameMainState = GameMainState.GameMainFault
                        isgameMainRendererWait = true
                        return
                    }
                }
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if gameMainState == GameMainState.GameMainPlay{
            if isKick == true{
                if isballfootCollision == false{
                    if(nodeA.name == "soccerball" && nodeB.name == "footplane") || (nodeB.name == "soccerball" && nodeA.name == "footplane"){
                        var sign:Float = 0.0
                            if arc4random()%2 == 1{
                                sign = 1.0
                            }else{
                                sign = -1.0
                            }
                        let degree = sign * Float(arc4random()%(10-2+1)+2)
                        let radius = Float(arc4random()%(40000-20000+1)+20000)
                        let keeperblock = GameMainScene?.rootNode.childNode(withName: "keeperblock", recursively: true)
                        let moveX = sin(Float.pi/degree) * radius + keeperblock!.position.x
                        let moveY = cos(Float.pi/abs(degree)) * radius + keeperblock!.position.y
                        keeperblock?.rotation = SCNVector4(0, 0, 1, -Float.pi/degree)
                        keeperblock?.physicsBody?.applyForce(SCNVector3(moveX, moveY, 0), asImpulse: true)
                               
                        //motionjoin
                        let keeper = GameMainScene?.rootNode.childNode(withName: "keeper", recursively: true)
                            DispatchQueue.main.async {
                                let keeperJump = SCNAnimationPlayer.loadAnimation(fromSceneNamed: "art.scnassets/character/keeper/jump.scn")
                                keeper?.addAnimationPlayer(keeperJump, forKey: "keeperjump")
                                keeperJump.speed = 6.0
                                keeper?.animationPlayer(forKey: "keeperjump")?.animation.repeatCount = 1
                                keeper?.animationPlayer(forKey: "keepercrouch")?.stop()
                                keeper?.animationPlayer(forKey: "keeperjump")?.stop()
                                keeper?.animationPlayer(forKey: "keeperjump")?.play()
                            }
                        let soccerBall = GameMainScene?.rootNode.childNode(withName: "soccerball", recursively: true)
                        let ballBody = SCNPhysicsBody(type: .dynamic ,shape: nil)
                        ballBody.mass = 0.9
                        ballBody.restitution = 0.4
                        ballBody.friction = 1.0
                        ballBody.contactTestBitMask = 0b1111
                        soccerBall?.physicsBody = ballBody
                        isballfootCollision = true
                    }
                }
                if isballfloorCollision == false && isBallMove == true{
                    if(nodeA.name == "soccerball" && nodeB.name == "groundfloor") || (nodeB.name == "soccerball" && nodeA.name == "groundfloor"){
                        isballfloorCollision = true
                    }
                }
                if isballOver == false{
                    if(nodeA.name == "soccerball" && nodeB.name == "leftfloorplane") || (nodeB.name == "soccerball" && nodeA.name == "leftfloorplane"){
                        isballOver = true
                    }
                    if(nodeA.name == "soccerball" && nodeB.name == "rightfloorplane") || (nodeB.name == "soccerball" && nodeA.name == "rightfloorplane"){
                        isballOver = true
                    }
                    if(nodeA.name == "soccerball" && nodeB.name == "backfloorplane") || (nodeB.name == "soccerball" && nodeA.name == "backfloorplane"){
                        isballOver = true
                    }
                }
                if isGoalSuccess == false{
                    if(nodeA.name == "soccerball" && nodeB.name == "goalsuccess") || (nodeB.name == "soccerball" && nodeA.name == "goalsuccess"){
                       isGoalSuccess = true
                   }
                }
            }
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView!.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            let hitresultNode = result.node
            if gameMainState == GameMainState.GameMainPlay{
                if isKick == false{
                    if(hitresultNode.name == "kickbutton"){
                    isKick = true
                    //motionjoin
                       let playerNode =  GameMainScene?.rootNode.childNode(withName: "player", recursively: true)
                       let mankick = SCNAnimationPlayer.loadAnimation(fromSceneNamed: "art.scnassets/character/player/playerkick.scn")
                       playerNode?.addAnimationPlayer(mankick, forKey: "kick")
                       playerNode?.animationPlayer(forKey: "kick")?.stop()
                       playerNode?.animationPlayer(forKey: "kick")?.speed = manKickSpeed
                       playerNode?.animationPlayer(forKey: "kick")?.animation.repeatCount = 1
                       playerNode?.animationPlayer(forKey: "kick")?.play()
                       let keeperCrouch = SCNAnimationPlayer.loadAnimation(fromSceneNamed: "art.scnassets/character/keeper/crouch.scn")
                           keeperCrouch.speed = 3.0
                           let keeper = GameMainScene?.rootNode.childNode(withName: "keeper", recursively: true)
                           //motionjoin
                           keeper?.addAnimationPlayer(keeperCrouch, forKey: "keepercrouch")
                           keeper?.animationPlayer(forKey: "keepercrouch")?.stop()
                           keeper?.animationPlayer(forKey: "keepercrouch")?.animation.repeatCount = 1
                           keeper?.animationPlayer(forKey: "keepercrouch")?.play()
                    }
                    if(hitresultNode.name == "rightarrow"){
                        playerRaius += Float.pi/20
                        if playerRaius >= Float.pi/6{
                            playerRaius = Float.pi/6
                        }
                    }
                    if(hitresultNode.name == "leftarrow"){
                        playerRaius -= Float.pi/20
                        if playerRaius <= -Float.pi/8{
                            playerRaius = -Float.pi/8
                        }
                    }
                    if(hitresultNode.name == "rightarrow" || hitresultNode.name == "leftarrow"){
                        let playerNode = GameMainScene?.rootNode.childNode(withName: "player", recursively: true)
                        let ballNode:SCNNode! = GameMainScene?.rootNode.childNode(withName: "soccerball", recursively: true)
                        let moveZ = cos(playerRaius)*(-0.50) + ballNode.position.z
                        let moveX  = sin(playerRaius)*(-0.50) + ballNode.position.x
                        playerNode?.position.x = moveX
                        playerNode?.position.z = moveZ
                        playerNode?.rotation = SCNVector4(0, 1, 0, playerRaius)
                    }
                }
            }else if gameMainState == GameMainState.GameMainFault{
                let faultSuccess:SCNNode! = GameMainScene?.rootNode.childNode(withName: "faultsuccess", recursively: true)
                faultSuccess.removeFromParentNode()
                Shoot += 1
                if Shoot >= shootMax{
                    let temptopscore = userdefaults.integer(forKey: "topscore")
                    if goalSuccess > temptopscore {
                        userdefaults.set(goalSuccess, forKey: "topscore")
                    }
                    let gameTitle = GameTitle()
                    gameTitle.modalPresentationStyle = .fullScreen
                    self.present(gameTitle, animated: false, completion: nil)
                    isgameMainRendererWait = false
                }else{
                    gamereset()
                    gameMainState = GameMainState.GameMainPlay
                    isgameMainRendererWait = false
                }
            }else if gameMainState == GameMainState.GameMainSuccess{
                let faultSuccess:SCNNode! = GameMainScene?.rootNode.childNode(withName: "faultsuccess", recursively: true)
                faultSuccess.removeFromParentNode()
                Shoot += 1
                goalSuccess += 1
                if Shoot >= shootMax{
                    let temptopscore = userdefaults.integer(forKey: "topscore")
                    if goalSuccess > temptopscore {
                        userdefaults.set(goalSuccess, forKey: "topscore")
                    }
                    let gameTitle = GameTitle()
                    gameTitle.modalPresentationStyle = .fullScreen
                    self.present(gameTitle, animated: false, completion: nil)
                    isgameMainRendererWait = false
                }else{
                    gamereset()
                    gameMainState = GameMainState.GameMainPlay
                    isgameMainRendererWait = false
                }
            }
        }
    }
    
    func gameinit(loadFirst:Bool){
        //loadoneonly
        if loadFirst == true{
            let ballscene = SCNScene(named: "art.scnassets/soccerball.scn")!
            ballNodeBase = ballscene.rootNode.childNode(withName: "soccerball", recursively: true)
            let manbody = SCNScene(named: "art.scnassets/character/player/player.scn")!
            playerNodeBase = manbody.rootNode.childNode(withName: "body", recursively: true)!
            let keeperSCN = SCNScene(named: "art.scnassets/character/keeper/keeper.scn")!
            keeperNodeBase = keeperSCN.rootNode.childNode(withName: "body", recursively: true)!
        }
        isKick = false
        isballfootCollision = false
        isballfloorCollision = false
        isballOver = false
        isGoalSuccess = false
        isBallMove = false
        
        playerRaius = 0.0
        mankickTime = 0
        manKickSpeed = (CGFloat(arc4random()%(15-10+1)+10)/10.0) * manKickSpeedPercent
        
        if manKickSpeed > 1.5 * manKickSpeedPercent{
            manKickSpeed = 1.0 * manKickSpeedPercent
        }
        
        //kicknumber
        let kickStr = String(Shoot)
        let kickNumberStr = kickStr + "/" + String(shootMax)
        let kickText = SCNText(string: kickNumberStr, extrusionDepth: 0.01)
        kickText.font = UIFont.systemFont(ofSize: 0.4)
        kickText.firstMaterial?.diffuse.contents = UIColor.blue
        let kickTextNode = SCNNode(geometry: kickText)
        kickTextNode.position = SCNVector3(x: -1.0, y: 2.65, z: -1.0)
        kickTextNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:3.14)
        kickTextNode.name = "kicknumber"
        GameMainScene?.rootNode.addChildNode(kickTextNode)
        
        //shootsuccessnumber
        let str = String(goalSuccess)
        let text = SCNText(string: str, extrusionDepth: 0.01)
        text.font = UIFont.systemFont(ofSize: 0.4)
        text.firstMaterial?.diffuse.contents = UIColor.blue
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(x: -1.5, y: 1.5, z: -1.0)
        textNode.rotation = SCNVector4(x: 0.0, y: 1, z: 0.1,w:3.14)
        textNode.name = "shootsuccessnumber"
        GameMainScene?.rootNode.addChildNode(textNode)
        
        //ball
        let ballNode = ballNodeBase.clone()
        let ballSphere = SCNSphere(radius: 0.17)
        ballSphere.firstMaterial?.diffuse.contents = UIColor.clear
        let soccerBallNode = SCNNode(geometry: ballSphere)
        soccerBallNode.name = "soccerball"
        soccerBallNode.position = SCNVector3(0.0, 0.05, 0.5)
        ballNode.position = SCNVector3(0, -0.005, 0.0)
        let ballBody = SCNPhysicsBody(type: .static ,shape: nil)
        ballBody.contactTestBitMask = 0b1111
        soccerBallNode.physicsBody = ballBody
        GameMainScene?.rootNode.addChildNode(soccerBallNode)
        soccerBallNode.addChildNode(ballNode)
        
        // retrieve the man node
        let playerNode = playerNodeBase.clone()
        playerNode.name = "player"
        playerNode.position = SCNVector3(0.0, 1.0, 0.0)
        GameMainScene?.rootNode.addChildNode(playerNode)
        
        let foot = GameMainScene?.rootNode.childNode(withName: "playerfoot_R", recursively: true)!
        //足につけた当たり判定用の羽子板
        let footGeom = SCNBox(width: 1.0, height: 3.0, length: 5.0, chamferRadius: 0)
        let footPlane = SCNNode(geometry: footGeom)
        footPlane.rotation = SCNVector4(0,1,-0.1,(Float.pi*0.5))
        footPlane.position.x = 0.7//jouge
        footPlane.position.y = 0.0//yoko
        footPlane.position.z = 0.4//oku
        footPlane.name = "footplane"
        footPlane.physicsBody?.contactTestBitMask = 0b0001
        footGeom.firstMaterial?.diffuse.contents = UIColor.clear
        footGeom.firstMaterial?.isDoubleSided = true
        foot?.addChildNode(footPlane)
        footPlane.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        
        // retrieve the keeper node画像だけ本体は上のGeom
        let keeperNode = keeperNodeBase.clone()
        //keeper本体
        let bodyGeom = SCNBox(width: 1.7, height: 3.0, length: 1.0, chamferRadius: 0)
        let bodyPlane = SCNNode(geometry: bodyGeom)
        bodyPlane.name = "keeperblock"
        let keeperBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        keeperBody.mass = 5000
        keeperBody.restitution = 0.1
        keeperBody.friction = 1.0
        keeperBody.contactTestBitMask = 0b0010
        bodyPlane.physicsBody = keeperBody
        bodyGeom.firstMaterial?.diffuse.contents = UIColor.clear
        GameMainScene?.rootNode.addChildNode(bodyPlane)
        bodyPlane.position = SCNVector3(0.0, 0.5, 5.0)
        keeperNode.name = "keeper"
        keeperNode.rotation = SCNVector4(0,1,0,Float.pi)
        keeperNode.position = SCNVector3(0,-0.3,0)
        bodyPlane.addChildNode(keeperNode)
    }
    
    func gamereset(){
        let soccerBall = GameMainScene?.rootNode.childNode(withName: "soccerball", recursively: true)
        soccerBall?.removeFromParentNode()
        let playerNode = GameMainScene?.rootNode.childNode(withName: "player", recursively: true)
        playerNode?.removeFromParentNode()
        let keeperNode = GameMainScene?.rootNode.childNode(withName: "keeperblock", recursively: true)
        keeperNode?.removeFromParentNode()
        let shootsuccessnumberNode = GameMainScene?.rootNode.childNode(withName: "shootsuccessnumber", recursively: true)
        shootsuccessnumberNode?.removeFromParentNode()
        let kickNumberNode = GameMainScene?.rootNode.childNode(withName: "kicknumber", recursively: true)
        kickNumberNode?.removeFromParentNode()
        gameinit(loadFirst: false)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}

extension SCNAnimationPlayer {
    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: sceneName )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
}
