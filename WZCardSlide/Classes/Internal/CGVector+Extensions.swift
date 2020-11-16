//
//  CardLayoutProvidable.swift
//  CGVector+Extensions
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import CoreGraphics

/// MARK - CGVector
extension CGVector {
    
    static prefix func + (vector: CGVector) -> CGVector {
        return vector
    }
    
    static prefix func - (vector: CGVector) -> CGVector {
        return CGVector(dx: -vector.dx, dy: -vector.dy)
    }
    
    static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
    
    static func - (lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
    
    static func * (scalar: CGFloat, vector: CGVector) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
    
    static func * (scalar: Int, vector: CGVector) -> CGVector {
        return vector * CGFloat(scalar)
    }
    
    static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
    
    static func * (vector: CGVector, scalar: Int) -> CGVector {
        return vector * CGFloat(scalar)
    }
    
    static func / (vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
    }
    
    static func / (vector: CGVector, scalar: Int) -> CGVector {
        return vector / CGFloat(scalar)
    }
    
    static func += (lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs + rhs
    }
    
    static func -= (lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs - rhs
    }
    
    static func *= (vector: inout CGVector, scalar: CGFloat) {
        vector = vector * scalar
    }
    
    static func *= (vector: inout CGVector, scalar: Int) {
        vector = vector * scalar
    }
    
    static func /= (vector: inout CGVector, scalar: CGFloat) {
        vector = vector / scalar
    }
    
    static func /= (vector: inout CGVector, scalar: Int) {
        vector = vector / scalar
    }
    
    static func * (lhs: CGVector, rhs: CGVector) -> CGFloat {
        return lhs.dx * rhs.dx + lhs.dy * rhs.dy
    }
    
    // MARK: - Miscellaneous
    init(from origin: CGPoint = .zero, to target: CGPoint) {
        self = CGVector(dx: target.x - origin.x,
                        dy: target.y - origin.y)
    }
    
    init(_ size: CGSize) {
        self = CGVector(dx: size.width, dy: size.height)
    }
    
    var length: CGFloat {
        return hypot(self.dx, self.dy)
    }
    
    var normalized: CGVector {
        return self / self.length
    }
}

// MARK: - Functions
func abs(_ vector: CGVector) -> CGFloat {
    return vector.length
}
