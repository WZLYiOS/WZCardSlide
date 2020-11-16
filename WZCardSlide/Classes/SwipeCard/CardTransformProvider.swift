//
//  CardTransformProvider.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - 卡片变化提供者协议
protocol CardTransformProvidable {
    
    
    /// 覆盖百分比
    /// - Parameters:
    ///   - card: SwipeCard
    ///   - direction: SwipeDirection
    func overlayPercentage(for card: SwipeCard, direction: SwipeDirection) -> CGFloat
    
    
    /// 旋转角度
    /// - Parameter card: SwipeCard
    func rotationAngle(for card: SwipeCard) -> CGFloat
    
    
    /// Y旋转方向
    /// - Parameter card: SwipeCard
    func rotationDirectionY(for card: SwipeCard) -> CGFloat
    
    
    /// 变化
    /// - Parameter card: SwipeCard
    func transform(for card: SwipeCard) -> CGAffineTransform
}


/// MARK - 卡片变化提供者管理类
class CardTransformProvider: CardTransformProvidable {
    

    /// 覆盖百分比
    /// - Parameters:
    ///   - card: SwipeCard
    ///   - direction: SwipeDirection
    ///   - return: CGFloat
    func overlayPercentage(for card: SwipeCard, direction: SwipeDirection) -> CGFloat {
        
        if direction != card.activeDirection() { return 0 }
        let totalPercentage = card.swipeDirections.reduce(0) { sum, direction in
            return sum + card.dragPercentage(on: direction)
        }
        let actualPercentage = 2 * card.dragPercentage(on: direction) - totalPercentage
        return max(0, min(actualPercentage, 1))
    }
    
    
    /// 旋转角度
    /// - Parameter card: SwipeCard
    /// - return: 角度
    func rotationAngle(for card: SwipeCard) -> CGFloat {
        
        let superviewTranslation = card.panGestureRecognizer.translation(in: card.superview)
        let rotationStrength = min(superviewTranslation.x / UIScreen.main.bounds.width, 1)
        return rotationDirectionY(for: card)
            * rotationStrength
            * abs(card.animationOptions.maximumRotationAngle)
    }
    
    
    /// Y旋转方向
    /// - Parameter card: SwipeCard
    /// - return: CGFloat
    func rotationDirectionY(for card: SwipeCard) -> CGFloat {
        if let touchPoint = card.touchLocation {
            return (touchPoint.y < card.bounds.height / 2) ? 1 : -1
        }
        return 0
    }
    
    
    /// 变化
    /// - Parameter card: SwipeCard
    /// - return: CGAffineTransform
    func transform(for card: SwipeCard) -> CGAffineTransform {
        
        let dragTranslation = card.panGestureRecognizer.translation(in: card)
        let translation = CGAffineTransform(translationX: dragTranslation.x,
                                            y: dragTranslation.y)
        let rotation = CGAffineTransform(rotationAngle: rotationAngle(for: card))
        return translation.concatenating(rotation)
    }
}
