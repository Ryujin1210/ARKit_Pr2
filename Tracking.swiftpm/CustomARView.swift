//
//  CustomARView.swift
//  Tracking
//
//  Created by YU WONGEUN on 2023/04/05.
//

import Foundation
import SwiftUI
import ARKit
import SceneKit

struct CustomARView: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    
    var view: ARSCNView
    var options: [Any] = []
    
    func makeUIView(context: Context) -> ARSCNView {
        view.session.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.view)
    }
}

class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    
    private var trackingView: ARSCNView
    private var sphereNode: SCNNode!
    private var cubeNode: SCNNode!
    
    init(_ view: ARSCNView) {
        
        self.trackingView = view
        super.init()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking을 지원하는 기종이 아닙니다.")
        }
        let configuration = ARFaceTrackingConfiguration()
        self.trackingView.session.run(configuration)
        self.trackingView.delegate = self
        
        let geo3 = SCNSphere(radius: 0.5)
        geo3.segmentCount = 16
        sphereNode = SCNNode(geometry: geo3)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.99)
        sphereNode.geometry?.firstMaterial?.fillMode = .lines
        
        sphereNode.simdPosition = SIMD3(x: 0, y: 1, z:-6)
        self.trackingView.scene.rootNode.addChildNode(sphereNode)
        
        let colorNames: [UIColor] = [UIColor.red, .blue, .green, .purple, .orange, .brown]
        var colorMaterials: [SCNMaterial] = []
        for colors in colorNames {
            let newMaterial = SCNMaterial()
            newMaterial.diffuse.contents = colors
            colorMaterials.append(newMaterial)
        }
        
        let geo2 = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        cubeNode = SCNNode(geometry: geo2)
        cubeNode.geometry?.materials = colorMaterials
        cubeNode.position = SCNVector3(x: 0, y: 0, z: -10)
        
        self.trackingView.scene.rootNode.addChildNode(cubeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        DispatchQueue.main.async { [self] in
            
            self.cubeNode.simdOrientation = simd_quatf(faceAnchor.leftEyeTransform)// .orientation
            // MARK: - 머리 움직임을 배제 하기 위해
            
            
            
            // 여기는 눈 각도가 0.3 보다 낮으면 원점으로 돌아옴
            if faceAnchor.blendShapes[.eyeLookInLeft]!.doubleValue < 0.3 &&
                faceAnchor.blendShapes[.eyeLookInRight]!.doubleValue < 0.3 &&
                faceAnchor.blendShapes[.eyeLookUpLeft]!.doubleValue < 0.3 &&
                faceAnchor.blendShapes[.eyeLookDownLeft]!.doubleValue < 0.3 {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                sphereNode.simdPosition = SIMD3(x: 0, y: 0, z: -6)
                SCNTransaction.commit()
            }
            
            // 눈 각도가 움직임으로 0.3 이상 움직일 때
            if faceAnchor.blendShapes[.eyeLookInLeft]!.doubleValue > 0.3 {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                sphereNode.simdPosition = SIMD3(x: -3, y: 0, z: -6)
                SCNTransaction.commit()
            }
            
            if faceAnchor.blendShapes[.eyeLookInRight]!.doubleValue > 0.3 {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                sphereNode.simdPosition = SIMD3(x: 3, y: 0, z: -6)
                SCNTransaction.commit()
            }
            
            if faceAnchor.blendShapes[.eyeLookUpLeft]!.doubleValue > 0.3 {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                sphereNode.simdPosition = SIMD3(x: 0, y: 3, z: -6)
                SCNTransaction.commit()
            }
            
            if faceAnchor.blendShapes[.eyeLookDownLeft]!.doubleValue > 0.3 {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                sphereNode.simdPosition = SIMD3(x: 0, y: -3, z: -6)
                SCNTransaction.commit()
            }
            
            // 
            if faceAnchor.blendShapes[.eyeLookInLeft]!.doubleValue > 0.2 &&
                faceAnchor.blendShapes[.eyeLookDownLeft]!.doubleValue > 0.2 {
                sphereNode.simdPosition = SIMD3(x: -2, y: -1, z: -6)
            }
            if faceAnchor.blendShapes[.eyeLookInLeft]!.doubleValue > 0.2 &&
                faceAnchor.blendShapes[.eyeLookUpLeft]!.doubleValue > 0.2 {
                sphereNode.simdPosition = SIMD3(x: -2, y: 1, z: -6)
            }
            if faceAnchor.blendShapes[.eyeLookInRight]!.doubleValue > 0.2 &&
                faceAnchor.blendShapes[.eyeLookDownLeft]!.doubleValue > 0.2 {
                sphereNode.simdPosition = SIMD3(x: 2, y: -1, z: -6)
            }
            if faceAnchor.blendShapes[.eyeLookInRight]!.doubleValue > 0.2 &&
                faceAnchor.blendShapes[.eyeLookUpLeft]!.doubleValue > 0.2 {
                sphereNode.simdPosition = SIMD3(x: 2, y: 1, z: -6)
            }
            
        }
    }
}
