//
//  ARViewController.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 3/5/18.
//  Copyright © 2018 NYC DoITT. All rights reserved.
//

import ARKit
import MapKit
import SceneKit
import UIKit

protocol ARViewControllerDelegate: class {
    func requestData()
}

final class ARViewController: UIViewController {
    weak var delegate: ARViewControllerDelegate?
    
    var serviceRequests: [ServiceRequest]? {
        didSet {
            nodes.forEach { $0.removeFromParentNode() }
            nodes.removeAll()
            
            guard let serviceRequests = serviceRequests else { return }
            
            nodes.append(contentsOf: serviceRequests.map {
                sr in
                let node = self.buildBillboardNode(image: UIImage(complaintType: sr.complaintType)) //self.buildNode()
                let location = CLLocation(latitude: Double(sr.latitudeString)!, longitude: Double(sr.longitudeString)!)
                self.position(node: node, location: location)
                return node
            })
            
            DispatchQueue.main.async {
                self.nodes.forEach { self.sceneView.scene.rootNode.addChildNode($0) }
            }
        }
    }
    
    var userLocation: CLLocation? {
        didSet {
            if hasViewAppeared {
                delegate?.requestData()
            }
        }
    }

    @IBOutlet private weak var sceneView: ARSCNView!
    
    private var hasViewAppeared = false
    private let modelScene = SCNScene(named: "Art.scnassets/DiamondGem.dae")!
    private var nodes: [SCNNode] = []
    private let rootNodeName = "DiamondGem.obj"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.scene = SCNScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasViewAppeared = true
        delegate?.requestData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hasViewAppeared = false
        sceneView.session.pause()
    }
    
    // MARK: - Private Methods
    
    func buildBillboardNode(image: UIImage? = nil) -> SCNNode {
        let billboardImage: UIImage
        if image == nil {
            billboardImage = UIImage(named: "listTabBarIcon")!
        } else {
            billboardImage = image!
        }
        
        let plane = SCNPlane(width: 10, height: 10)
        plane.firstMaterial!.diffuse.contents = billboardImage
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        return node
    }

    private func buildNode() -> SCNNode {
        let uberNode = modelScene.rootNode.childNode(withName: rootNodeName, recursively: true)!
        let node = uberNode.clone()
        
        let (minBox, maxBox) = node.boundingBox
        node.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y) / 2, 0)
        
//        originalTransform = node.transform
        
        //        let arrow = makeBillboardNode(UIImage(named: "listTabBarIcon")!)
        //        arrow.position = SCNVector3Make(0, 4, 0)
        //        node.addChildNode(arrow)
        
        return node
    }
    
    private func position(node: SCNNode, location: CLLocation) {
        node.position = translate(location)
        node.scale = scale(location: location)
    }
    
    func scale(location: CLLocation) -> SCNVector3 {
        let distance = Float(location.distance(from: userLocation!))
        let scale = min( max( Float(1000/distance), 1.5 ), 3 )
        return SCNVector3(x: scale, y: scale, z: scale)
    }
    
    func translate(_ location: CLLocation) -> SCNVector3 {
        let locationTransform = transform(matrix: matrix_identity_float4x4, origin: userLocation!, target: location, distance: Float(location.distance(from: userLocation!)))
        return positionFromTransform(locationTransform)
    }
    
    func positionFromTransform(_ transform: simd_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    func transform(matrix: simd_float4x4, origin: CLLocation, target: CLLocation, distance: Float) -> simd_float4x4 {
        let bearing = bearingBetweenLocations(origin, target)
        let rotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearing))
        
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
        
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        
        return simd_mul(matrix, transformMatrix)
    }
    
    func getTranslationMatrix(_ matrix: simd_float4x4, _ translation : vector_float4) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
        var matrix = matrix
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    func bearingBetweenLocations(_ originLocation: CLLocation, _ driverLocation: CLLocation) -> Double {
        let lat1 = originLocation.coordinate.latitude.toRadians()
        let lon1 = originLocation.coordinate.longitude.toRadians()
        
        let lat2 = driverLocation.coordinate.latitude.toRadians()
        let lon2 = driverLocation.coordinate.longitude.toRadians()
        
        let longitudeDiff = lon2 - lon1
        
        let y = sin(longitudeDiff) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff);
        
        return atan2(y, x)
    }
}

// MARK: - ARSCNViewDelegate

extension ARViewController: ARSCNViewDelegate {
    
}
