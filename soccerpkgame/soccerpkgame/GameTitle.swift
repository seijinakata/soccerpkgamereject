//
//  GameTitle.swift
//  soccerpkgame
//
//  Created by Owner on 8/21/1399 AP.
//

import UIKit
import QuartzCore
import SceneKit

let userdefaults = UserDefaults.standard


class GameTitle: UIViewController,SCNSceneRendererDelegate {

    var scnView:SCNView?
    
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
        
        let topscore = "topscore"
        //userdefaults.removeObject(forKey: topscore)
        if(userdefaults.object(forKey: topscore) == nil){
            userdefaults.set(-9999, forKey: topscore)
            userdefaults.synchronize()
        }
        
        // create a new scene
        let GameTitleScene = SCNScene()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        GameTitleScene.rootNode.addChildNode(cameraNode)
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 7)

        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.gray
        GameTitleScene.rootNode.addChildNode(ambientLightNode)
        
        let titleStr = "SOCCER PK GAME"
        let titleText = SCNText(string: titleStr, extrusionDepth: 0.1)
        titleText.font = UIFont.systemFont(ofSize: 1.0)
        titleText.firstMaterial?.diffuse.contents = UIColor.blue
        let titletextNode = SCNNode(geometry: titleText)
        titletextNode.name = "titlenode"
        titletextNode.position = SCNVector3(-4.5, 1.5, 0)
        GameTitleScene.rootNode.addChildNode(titletextNode)
        
        let scoreStr = "GOAL"
        let scoreText = SCNText(string: scoreStr, extrusionDepth: 0.1)
        scoreText.font = UIFont.systemFont(ofSize: 1.0)
        scoreText.firstMaterial?.diffuse.contents = UIColor.blue
        let scoretextNode = SCNNode(geometry: scoreText)
        scoretextNode.position = SCNVector3(-1.6, 0.0, 0)
        scoretextNode.name = "goal"
        GameTitleScene.rootNode.addChildNode(scoretextNode)
        
        let tempscore = userdefaults.integer(forKey: topscore)
        let str = tempscore.description
        let text = SCNText(string: str, extrusionDepth: 0.01)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.firstMaterial?.diffuse.contents = UIColor.blue
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(x: -0.5, y: -1.0, z: 0)
        textNode.name = "shootsuccessnumber"
        if tempscore != -9999{
            GameTitleScene.rootNode.addChildNode(textNode)
        }
        
        let startStr = "START"
        let startText = SCNText(string: startStr, extrusionDepth: 0.1)
        startText.font = UIFont.systemFont(ofSize: 1.0)
        startText.firstMaterial?.diffuse.contents = UIColor.blue
        let starttextNode = SCNNode(geometry: startText)
        starttextNode.name = "startnode"
        //-0.1は文字をタッチパネルの後ろにするため
        starttextNode.position = SCNVector3(-4.8, -3.0, -0.1)
        GameTitleScene.rootNode.addChildNode(starttextNode)
        
        //startbody
        let startGeom = SCNPlane(width: 3.5, height: 1.5)
        let startPlane = SCNNode(geometry: startGeom)
        startPlane.position = SCNVector3(-3.3, -1.6, 0)
        startPlane.name = "start"
        startGeom.firstMaterial?.diffuse.contents = UIColor.clear
        startGeom.firstMaterial?.isDoubleSided = true
        GameTitleScene.rootNode.addChildNode(startPlane)
        
        let howtoStr = "HOW TO"
        let howtoText = SCNText(string: howtoStr, extrusionDepth: 0.1)
        howtoText.font = UIFont.systemFont(ofSize: 1.0)
        howtoText.firstMaterial?.diffuse.contents = UIColor.blue
        let howtotextNode = SCNNode(geometry: howtoText)
        howtotextNode.position = SCNVector3(1.0, -3.0, -0.1)
        howtotextNode.name = "howtonode"
        GameTitleScene.rootNode.addChildNode(howtotextNode)
        
        //howtobody
        let howtoGeom = SCNPlane(width: 4.5, height: 1.5)
        let howtoPlane = SCNNode(geometry: howtoGeom)
        howtoPlane.position = SCNVector3(3.0, -1.6, 0)
        howtoPlane.name = "howto"
        howtoGeom.firstMaterial?.diffuse.contents = UIColor.clear
        howtoGeom.firstMaterial?.isDoubleSided = true
        GameTitleScene.rootNode.addChildNode(howtoPlane)

        // set the scene to the view
        scnView?.scene = GameTitleScene
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView!.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
        let result = hitResults[0]
        let hitresultNode = result.node
            if hitresultNode.name == "start"{
                let gameMain = GameMain()
                gameMain.modalPresentationStyle = .fullScreen
                self.present(gameMain, animated: false, completion: nil)
            }
            if hitresultNode.name == "howto"{
                let howTo = HowTo()
                howTo.modalPresentationStyle = .fullScreen
                self.present(howTo, animated: false, completion: nil)
            }
        }
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
