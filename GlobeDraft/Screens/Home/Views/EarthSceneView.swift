import SwiftUI
import SceneKit

struct EarthSceneView: UIViewRepresentable {
    let selectedCity: City?
    
    
    // MARK: - UIViewRepresentable Methods
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = UIColor.clear
        sceneView.allowsCameraControl = false
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        setupEarth(scene: scene)
        setupCamera(scene: scene)
        setupLighting(scene: scene)
        
        // Start simple rotation
        if let earthNode = scene.rootNode.childNode(withName: "earth", recursively: false) {
            let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 40)
            let repeatAction = SCNAction.repeatForever(rotationAction)
            earthNode.runAction(repeatAction, forKey: "earthRotation")
        }
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene,
              let earthNode = scene.rootNode.childNode(withName: "earth", recursively: false) else { return }
        
        earthNode.childNode(withName: "cityMarker", recursively: false)?.removeFromParentNode()
        
        if let city = selectedCity {
            // Stop all animations
            earthNode.removeAllActions()
            
            addCityMarker(to: scene, for: city)
            animateCameraToCity(scene: scene, city: city)
        } else {
            // Reset and start normal rotation
            earthNode.removeAllActions()
            resetCameraPosition(scene: scene)
            
            // Start simple rotation after reset
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let rotationAction = SCNAction.rotateBy(
                    x: 0,
                    y: CGFloat.pi * 2,
                    z: 0,
                    duration: 40
                )
                let repeatAction = SCNAction.repeatForever(rotationAction)
                earthNode.runAction(repeatAction, forKey: "earthRotation")
            }
        }
    }
    
    // MARK: - Scene Setup Methods
    
    private func setupEarth(scene: SCNScene) {
        let earthGeometry = SCNSphere(radius: 0.7)
        let earthNode = SCNNode(geometry: earthGeometry)
        earthNode.name = "earth"
        
        let earthMaterial = SCNMaterial()
        if let earthTexture = UIImage(named: "earth_texture") {
            earthMaterial.diffuse.contents = earthTexture
        } else {
            earthMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
            print("⚠️ earth_texture.jpg bulunamadı - mavi küre kullanılıyor")
        }
        earthMaterial.specular.contents = UIColor.black
        earthMaterial.shininess = 0.0
        
        earthGeometry.materials = [earthMaterial]
        scene.rootNode.addChildNode(earthNode)
    }
    
    private func setupCamera(scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 2.5)
        cameraNode.name = "camera"
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting(scene: SCNScene) {
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 800
        ambientLight.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 600
        directionalLight.light?.color = UIColor.white
        directionalLight.position = SCNVector3(5, 5, 5)
        directionalLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directionalLight)
    }
    
    
    // MARK: - City Marker Methods
    
    private func addCityMarker(to scene: SCNScene, for city: City) {
        guard let earthNode = scene.rootNode.childNode(withName: "earth", recursively: false) else { return }
        
        let markerGeometry = SCNSphere(radius: 0.015)
        let markerNode = SCNNode(geometry: markerGeometry)
        markerNode.name = "cityMarker"
        
        let markerMaterial = SCNMaterial()
        markerMaterial.diffuse.contents = UIColor.white
        markerMaterial.emission.contents = UIColor.white
        markerGeometry.materials = [markerMaterial]
        
        let surfacePosition = city.position3D
        let normalizedDirection = SCNVector3(
            surfacePosition.x / 0.7,
            surfacePosition.y / 0.7,
            surfacePosition.z / 0.7
        )
        
        markerNode.position = SCNVector3(
            surfacePosition.x + normalizedDirection.x * 0.02,
            surfacePosition.y + normalizedDirection.y * 0.02,
            surfacePosition.z + normalizedDirection.z * 0.02
        )
        
        earthNode.addChildNode(markerNode)
        
        let pulseAction = SCNAction.sequence([
            SCNAction.scale(to: 1.5, duration: 1.0),
            SCNAction.scale(to: 1.0, duration: 1.0)
        ])
        let repeatPulse = SCNAction.repeatForever(pulseAction)
        markerNode.runAction(repeatPulse)
    }
    
    // MARK: - Camera Animation Methods
    
    private func animateCameraToCity(scene: SCNScene, city: City) {
        guard let earthNode = scene.rootNode.childNode(withName: "earth", recursively: false) else { return }
        
        let cityPosition = city.position3D
        print("📍 Selected city: \(city.name) at position: \(cityPosition)")
        
        let cityDirection = SCNVector3(
            cityPosition.x / 0.7,
            cityPosition.y / 0.7,
            cityPosition.z / 0.7
        )
        
        let latitude = asin(cityDirection.y)
        let longitude = atan2(cityDirection.x, cityDirection.z)
        
        // Get current rotation to calculate shortest path
        let currentRotation = earthNode.presentation.rotation
        let currentX = currentRotation.x * currentRotation.w
        let currentY = currentRotation.y * currentRotation.w
        
        // Calculate shortest rotation difference
        var deltaX = latitude - currentX
        var deltaY = -longitude - currentY
        
        // Normalize angles to [-π, π] for shortest path
        while deltaX > Float.pi { deltaX -= 2 * Float.pi }
        while deltaX < -Float.pi { deltaX += 2 * Float.pi }
        while deltaY > Float.pi { deltaY -= 2 * Float.pi }
        while deltaY < -Float.pi { deltaY += 2 * Float.pi }
        
        print("🌍 Delta rotation: x=\(deltaX * 180 / Float.pi)°, y=\(deltaY * 180 / Float.pi)°")
        
        let rotateAction = SCNAction.rotateBy(x: CGFloat(deltaX), y: CGFloat(deltaY), z: 0, duration: 2.0)
        rotateAction.timingMode = .easeInEaseOut
        
        earthNode.runAction(rotateAction, forKey: "cityRotation")
        
        print("🌍 Earth rotating to center \(city.name)")
    }
    
    private func resetCameraPosition(scene: SCNScene) {
        guard let earthNode = scene.rootNode.childNode(withName: "earth", recursively: false) else { return }
        
        let resetAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 1.0)
        resetAction.timingMode = .easeInEaseOut
        earthNode.runAction(resetAction)
        
        print("🌍 Earth rotating back to original position")
    }
    
    // MARK: - Utility Methods
    
    private func normalize(_ vector: SCNVector3) -> SCNVector3 {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
    }
    
    private func createEarthTexture() -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            UIColor.systemGreen.setFill()
            
            let africa = UIBezierPath(ovalIn: CGRect(x: 240, y: 150, width: 60, height: 120))
            africa.fill()
            
            let europe = UIBezierPath(ovalIn: CGRect(x: 230, y: 120, width: 40, height: 30))
            europe.fill()
            
            let america = UIBezierPath(ovalIn: CGRect(x: 100, y: 100, width: 80, height: 200))
            america.fill()
        }
    }
}

