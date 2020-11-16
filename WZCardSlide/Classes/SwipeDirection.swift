//
//  CardAnimationOptions.swift
//  SwipeDirection
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - 表示物理拖动方向的类型
public enum SwipeDirection: Int, CustomStringConvertible {
    
    case left, right, up, down
    
    /// 返回所有方向
    public static let allDirections: [SwipeDirection] = [left, up, right, down]
    
    /// 用单位向量表示的 “滑动方向”
    public var vector: CGVector {
        switch self {
        case .left:
            return CGVector(dx: -1, dy: 0)
        case .right:
            return CGVector(dx: 1, dy: 0)
        case .up:
            return CGVector(dx: 0, dy: -1)
        case .down:
            return CGVector(dx: 0, dy: 1)
        }
    }
    
    /// “滑动方向” 的文本表示。
    public var description: String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
        case .up:
            return "up"
        case .down:
            return "down"
        }
    }
}
