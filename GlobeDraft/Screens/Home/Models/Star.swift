//
//  Star.swift
//  GlobeDraft
//
//  Created by Elif Parlak on 4.08.2025.
//
import SwiftUI

struct Star {
    let id: UUID
    let x: Double
    let y: Double
    let size: Double
    let color: Color
    var opacity: Double
    let shouldTwinkle: Bool
    let twinkleDuration: Double
    let delay: Double
}
