//
//  StarsBackgroundView.swift
//  GlobeDraft
//
//  Created by Elif Parlak on 4.08.2025.
//

import SwiftUI

struct StarsBackgroundView: View {
    @State private var stars = generateRandomStars()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(stars, id: \.id) { star in
                    Circle()
                        .fill(.white)
                        .frame(width: star.size, height: star.size)
                        .position(
                            x: star.x * geometry.size.width,
                            y: star.y * geometry.size.height
                        )
                        .opacity(star.opacity)
                        .animation(
                            Animation.easeInOut(duration: star.twinkleDuration)
                                .repeatForever(autoreverses: true)
                                .delay(star.delay),
                            value: star.opacity
                        )
                }
            }
        }
        .onAppear {
            // Start twinkling animation
            for i in stars.indices {
                if stars[i].shouldTwinkle {
                    stars[i].opacity = 0.1
                }
            }
        }
    }
    
    static func generateRandomStars() -> [Star] {
        var stars: [Star] = []
        
        for _ in 0..<100 {
            let star = Star(
                id: UUID(),
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                size: Double.random(in: 1...3),
                color: [Color.white, Color.yellow, Color.blue].randomElement() ?? Color.white,
                opacity: Double.random(in: 0.3...1.0),
                shouldTwinkle: Bool.random(),
                twinkleDuration: Double.random(in: 1...3),
                delay: Double.random(in: 0...2)
            )
            stars.append(star)
        }
        
        return stars
    }
}
