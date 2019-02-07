//
//  ViewController.swift
//  ARRuler
//
//  Created by Mathew Sayed on 7/2/19.
//  Copyright © 2019 Mathew Sayed. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // track all nodes in the screen scene
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTouchPoints()
    
        guard let touchLocation = touches.first?.location(in: sceneView) else {
            fatalError("could not render touch location")
        }
        
        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
        
        guard let hitResult = hitTestResults.first else { return }
        addDot(at: hitResult)
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let dotNode = SCNNode(geometry: dotGeometry)
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        // pythagoras variation points for 3D object
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        // distance = √ ((x2 - x2)^2 + (y2 - y1)^2 + (z2 - z1)^2)
        let distance = sqrt(pow(a,2) + pow(b,2) + pow(c, 2))
        
        updateText(text: String(format: "%.2f", distance) + "m", atPosition: end.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        removeTextPoint()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textNode = SCNNode(geometry: textGeometry)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    @IBAction func refreshScreen(_ sender: UIBarButtonItem) {
        removeTextPoint()
        removeTouchPoints()
    }
    
    func removeTouchPoints() {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
    }
    
    func removeTextPoint() {
        textNode.removeFromParentNode()
    }
    
}
