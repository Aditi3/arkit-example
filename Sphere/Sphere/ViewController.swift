//
//  ViewController.swift
//  Sphere
//
//  Created by Aditi Agrawal on 14/06/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var sphereArray = [SCNNode]()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        // Run the view's session
        sceneView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // MARK: - Setup Sphere Scene
    
    func setupSphere(atLocation location: ARHitTestResult) {
        
        let sphere = SCNSphere(radius: 0.2)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"art.scnassets/earth.jpeg")
        sphere.materials = [material]
        
        let sphereNode = SCNNode()
        
        sphereNode.position = SCNVector3Make(location.worldTransform.columns.3.x,
                                             location.worldTransform.columns.3.y + sphereNode.boundingSphere.radius,
                                             location.worldTransform.columns.3.z)
        sphereNode.geometry = sphere
        
        sphereArray.append(sphereNode)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        sphereNode.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 3),
                                                y: 0,
                                                z: CGFloat(randomZ * 3),
                                                duration: 0.5))
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    
    // MARK: - Remove Sphere Scene
    
    func removeSphere() {
        if !sphereArray.isEmpty {
            for sphere in sphereArray {
                sphere.removeFromParentNode()
            }
        }
    }
    
    
    // MARK: - Touch Began Delegate Method
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                removeSphere()
                setupSphere(atLocation: hitResult)
            }
        }
    }
    
    
    // MARK: - ARSCNViewDelegateMethod
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
        
    }
    
    
    // MARK: - Plane Rendering Method
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: planeAnchor.center.y, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        
        return planeNode
    }
    
}
