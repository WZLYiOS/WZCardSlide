//
//  CardStackTransformProvidable.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - 卡栈变化协议
public protocol CardStackTransformProvidable {
    
    /// 背景卡拖动变换
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    ///   - currentPosition: currentPosition
    func backgroundCardDragTransform(for cardStack: SwipeCardStack,
                                     topCard: SwipeCard,
                                     currentPosition: Int) -> CGAffineTransform
    
    
    /// 背景卡变换百分比
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    func backgroundCardTransformPercentage(for cardStack: SwipeCardStack, topCard: SwipeCard) -> CGFloat
}


/// MARK - 卡栈变化提供者
public class CardStackTransformProvider: CardStackTransformProvidable {
    
    
    /// 背景卡拖动变换
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    ///   - currentPosition: currentPosition
    ///   - return: CGAffineTransform
    public func backgroundCardDragTransform(for cardStack: SwipeCardStack,
                                            topCard: SwipeCard,
                                            currentPosition: Int) -> CGAffineTransform {
        let percentage = backgroundCardTransformPercentage(for: cardStack, topCard: topCard)
        
        let currentScale = cardStack.scaleFactor(forCardAtPosition: currentPosition)
        let nextScale = cardStack.scaleFactor(forCardAtPosition: currentPosition - 1)
        
        let scaleX = (1 - percentage) * currentScale.x + percentage * nextScale.x
        let scaleY = (1 - percentage) * currentScale.y + percentage * nextScale.y
        
        return CGAffineTransform(scaleX: scaleX, y: scaleY)
    }
    
    
    /// 背景卡变换百分比
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    ///   - return: CGFloat
    public func backgroundCardTransformPercentage(for cardStack: SwipeCardStack, topCard: SwipeCard) -> CGFloat {
        let panTranslation = topCard.panGestureRecognizer.translation(in: cardStack)
        let minimumSideLength = min(cardStack.bounds.width, cardStack.bounds.height)
        return max(min(2 * abs(panTranslation.x) / minimumSideLength, 1),
                   min(2 * abs(panTranslation.y) / minimumSideLength, 1))
    }
}
