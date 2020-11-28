//
//  HowTo.swift
//  soccerpkgame
//
//  Created by Owner on 8/27/1399 AP.
//

import UIKit
import QuartzCore
import SceneKit

class HowTo: UIViewController,SCNSceneRendererDelegate {

    var scnView:SCNView?
    var isGameMainMove = false

    override func viewDidLoad() {
        super.viewDidLoad()
      
        // retrieve the SCNView
        scnView = SCNView(frame: UIScreen.main.bounds)
        self.view = scnView

        // allows the user to manipulate the camera
        scnView?.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView?.showsStatistics = true
        
        // configure the view
        scnView?.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 1.0)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView?.addGestureRecognizer(tapGesture)
        
        //renderer
        scnView?.delegate = self
        
        // create a new scene
        let howToScene = SCNScene()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        howToScene.rootNode.addChildNode(cameraNode)
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)

        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.gray
        howToScene.rootNode.addChildNode(ambientLightNode)
        
        let Str1 = "遊び方"
        let strText1 = SCNText(string: Str1, extrusionDepth: 0.1)
        strText1.font = UIFont.systemFont(ofSize: 1.5)
        strText1.firstMaterial?.diffuse.contents = UIColor.blue
        let strText1Node = SCNNode(geometry: strText1)
        strText1Node.position = SCNVector3(-2.4, 1.5, 0)
        howToScene.rootNode.addChildNode(strText1Node)
        
        let Str2 = "キックメーターが高いほどボールが上がりやすい"
        let strText2 = SCNText(string: Str2, extrusionDepth: 0.1)
        strText2.font = UIFont.systemFont(ofSize: 0.6)
        strText2.firstMaterial?.diffuse.contents = UIColor.blue
        let strText2Node = SCNNode(geometry: strText2)
        strText2Node.position = SCNVector3(-6.0, 0.0, 0)
        howToScene.rootNode.addChildNode(strText2Node)
        
        let str3 = "左右で方向を決めてキックボタンでシュート"
        let strText3 = SCNText(string: str3, extrusionDepth: 0.1)
        strText3.font = UIFont.systemFont(ofSize: 0.6)
        strText3.firstMaterial?.diffuse.contents = UIColor.blue
        let strText3Node = SCNNode(geometry: strText3)
        strText3Node.name = "startnode"
        strText3Node.position = SCNVector3(-6.0, -1.5, 0.0)
        howToScene.rootNode.addChildNode(strText3Node)
        
        let str4 = "合計10本たくさんゴールを決めよう"
        let strText4 = SCNText(string: str4, extrusionDepth: 0.1)
        strText4.font = UIFont.systemFont(ofSize: 0.6)
        strText4.firstMaterial?.diffuse.contents = UIColor.blue
        let strText4Node = SCNNode(geometry: strText4)
        strText4Node.position = SCNVector3(-6.0, -3.0, 0.0)
        howToScene.rootNode.addChildNode(strText4Node)


        // set the scene to the view
        scnView?.scene = howToScene
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let gameTitle = GameTitle()
        gameTitle.modalPresentationStyle = .fullScreen
        self.present(gameTitle, animated: false, completion: nil)
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

