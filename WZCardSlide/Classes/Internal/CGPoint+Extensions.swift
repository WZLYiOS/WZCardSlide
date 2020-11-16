//
//  CardLayoutProvidable.swift
//  CGPoint+Extensions
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import CoreGraphics

/// MARK - CGPoint
extension CGPoint {
    
    init(_ vector: CGVector) {
        self = CGPoint(x: vector.dx, y: vector.dy)
    }
}
