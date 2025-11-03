import Foundation
import SceneKit

struct City: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    
    var position3D: SCNVector3 {
        let radius: Float = 0.7
        let latRad = Float(latitude * .pi / 180)
        let lonRad = Float(longitude * .pi / 180)
        
        let x = radius * cos(latRad) * sin(lonRad)
        let y = radius * sin(latRad)
        let z = radius * cos(latRad) * cos(lonRad)
        
        print("🌍 \(name): lat=\(latitude), lon=\(longitude) -> x=\(x), y=\(y), z=\(z)")
        
        return SCNVector3(x, y, z)
    }
}

let sampleCities = [
    City(name: "Istanbul", country: "Turkey", latitude: 41.0082, longitude: 28.9784),
    City(name: "London", country: "United Kingdom", latitude: 51.5074, longitude: -0.1278),
    City(name: "New York", country: "United States", latitude: 40.7128, longitude: -74.0060),
    City(name: "Tokyo", country: "Japan", latitude: 35.6762, longitude: 139.6503),
    City(name: "Paris", country: "France", latitude: 48.8566, longitude: 2.3522),
    City(name: "Sydney", country: "Australia", latitude: -33.8688, longitude: 151.2093),
    City(name: "Dubai", country: "UAE", latitude: 25.2048, longitude: 55.2708),
    City(name: "Los Angeles", country: "United States", latitude: 34.0522, longitude: -118.2437),
    City(name: "Moscow", country: "Russia", latitude: 55.7558, longitude: 37.6176),
    City(name: "Cairo", country: "Egypt", latitude: 30.0444, longitude: 31.2357)
]
