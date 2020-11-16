//
//  CardStackAnimatable.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import Foundation


/// MARK - 卡片动画协议
protocol CardStackAnimatable {
    
    
    /// 重置
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    func animateReset(_ cardStack: SwipeCardStack,
                      topCard: SwipeCard)
    
    
    /// 转变
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - distance: distance
    ///   - animated: animated
    ///   - completion: completion
    func animateShift(_ cardStack: SwipeCardStack,
                      withDistance distance: Int,
                      animated: Bool,
                      completion: ((Bool) -> Void)?)
    
    
    /// 刷卡动画
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    ///   - direction: SwipeDirection
    ///   - forced: forced
    ///   - animated: animated
    ///   - completion: completion
    func animateSwipe(_ cardStack: SwipeCardStack,
                      topCard: SwipeCard,
                      direction: SwipeDirection,
                      forced: Bool,
                      animated: Bool,
                      completion: ((Bool) -> Void)?)
    
    
    
    /// 撤销动画
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    ///   - animated: animated
    ///   - completion: completion
    func animateUndo(_ cardStack: SwipeCardStack,
                     topCard: SwipeCard,
                     animated: Bool,
                     completion: ((Bool) -> Void)?)
    
    
    /// 移除所有卡片动画
    /// - Parameter cardStack: SwipeCardStack
    func removeAllCardAnimations(_ cardStack: SwipeCardStack)
    
    
    /// 移除背景卡片动画
    /// - Parameter cardStack: SwipeCardStack
    func removeBackgroundCardAnimations(_ cardStack: SwipeCardStack)
}



/// MARK - 卡片堆栈的背景卡片动画器
class CardStackAnimator: CardStackAnimatable {
    
    
    /// 重置
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    func animateReset(_ cardStack: SwipeCardStack,
                      topCard: SwipeCard) {
        removeBackgroundCardAnimations(cardStack)
        
        Animator.animateKeyFrames(withDuration: resetDuration(cardStack, topCard: topCard),
                                  options: .allowUserInteraction,
                                  animations: { [weak self] in
                                    self?.addCancelSwipeAnimationKeyFrames(cardStack) },
                                  completion: nil)
    }
    
    /// 转变
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - distance: distance
    ///   - animated: animated
    ///   - completion: completion
    func animateShift(_ cardStack: SwipeCardStack,
                      withDistance distance: Int,
                      animated: Bool,
                      completion: ((Bool) -> Void)?) {
        removeAllCardAnimations(cardStack)
        
        if !animated {
            for (position, value) in cardStack.visibleCards.enumerated() {
                value.card.transform = cardStack.transform(forCardAtPosition: position)
            }
            completion?(true)
            return
        }
        
        // 将背景卡放在旧的位置
        for (position, value) in cardStack.visibleCards.enumerated() {
            value.card.transform = cardStack.transform(forCardAtPosition: position + distance)
        }
        
        // 动画背景卡到新的位置
        Animator.animateKeyFrames(withDuration: shiftDuration(cardStack),
                                  animations: { [weak self] in
                                    self?.addShiftAnimationKeyFrames(cardStack) },
                                  completion: completion)
    }
    
    /// 刷卡动画
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    ///   - direction: SwipeDirection
    ///   - forced: forced
    ///   - animated: animated
    ///   - completion: completion
    func animateSwipe(_ cardStack: SwipeCardStack,
                      topCard: SwipeCard,
                      direction: SwipeDirection,
                      forced: Bool,
                      animated: Bool,
                      completion: ((Bool) -> Void)?) {
        removeBackgroundCardAnimations(cardStack)
        
        if !animated {
            for (position, value) in cardStack.visibleCards.enumerated() {
                cardStack.layoutCard(value.card, at: position)
            }
            completion?(true)
            return
        }
        
        let delay = swipeDelay(for: topCard, forced: forced)
        
        let duration = swipeDuration(cardStack,
                                     topCard: topCard,
                                     direction: direction,
                                     forced: forced)
        // 没有背景卡可供动画使用，所以我们只是延迟调用completion block
        if cardStack.visibleCards.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + duration) {
                completion?(true)
            }
            return
        }
        
        Animator.animateKeyFrames(withDuration: duration,
                                  delay: delay,
                                  animations: { [weak self] in
                                    self?.addSwipeAnimationKeyFrames(cardStack) },
                                  completion: completion)
    }
    
    /// 撤销动画
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - topCard: SwipeCard
    ///   - animated: animated
    ///   - completion: completion
    func animateUndo(_ cardStack: SwipeCardStack,
                     topCard: SwipeCard,
                     animated: Bool,
                     completion: ((Bool) -> Void)?) {
        removeBackgroundCardAnimations(cardStack)
        
        if !animated {
            for (position, card) in cardStack.backgroundCards.enumerated() {
                cardStack.layoutCard(card, at: position + 1)
            }
            completion?(true)
            return
        }
        
        // 将背景卡放在旧的位置
        for (position, card) in cardStack.backgroundCards.enumerated() {
            card.transform = cardStack.transform(forCardAtPosition: position)
        }
        
        // 动画背景卡到新的位置
        Animator.animateKeyFrames(withDuration: undoDuration(cardStack, topCard: topCard),
                                  animations: { [weak self] in
                                    self?.addUndoAnimationKeyFrames(cardStack) },
                                  completion: completion)
    }
    
    /// 移除所有卡片动画
    /// - Parameter cardStack: SwipeCardStack
    func removeBackgroundCardAnimations(_ cardStack: SwipeCardStack) {
        cardStack.backgroundCards.forEach { $0.removeAllAnimations() }
    }
    
    /// 移除背景卡片动画
    /// - Parameter cardStack: SwipeCardStack
    func removeAllCardAnimations(_ cardStack: SwipeCardStack) {
        cardStack.visibleCards.forEach { $0.card.removeAllAnimations() }
    }
    
    
    
    // MARK: - Animation Keyframes
    func addCancelSwipeAnimationKeyFrames(_ cardStack: SwipeCardStack) {
        for (position, card) in cardStack.backgroundCards.enumerated() {
            let transform = cardStack.transform(forCardAtPosition: position + 1)
            Animator.addTransformKeyFrame(to: card, transform: transform)
        }
    }
    
    func addShiftAnimationKeyFrames(_ cardStack: SwipeCardStack) {
        for (position, value) in cardStack.visibleCards.enumerated() {
            let transform = cardStack.transform(forCardAtPosition: position)
            Animator.addTransformKeyFrame(to: value.card, transform: transform)
        }
    }
    
    func addSwipeAnimationKeyFrames(_ cardStack: SwipeCardStack) {
        for (position, value) in cardStack.visibleCards.enumerated() {
            Animator.addKeyFrame {
                cardStack.layoutCard(value.card, at: position)
            }
        }
    }
    
    func addUndoAnimationKeyFrames(_ cardStack: SwipeCardStack) {
        for (position, card) in cardStack.backgroundCards.enumerated() {
            Animator.addKeyFrame {
                cardStack.layoutCard(card, at: position + 1)
            }
        }
    }
    
    // MARK: - Animation Calculations
    func resetDuration(_ cardStack: SwipeCardStack, topCard: SwipeCard) -> TimeInterval {
        return cardStack.animationOptions.resetDuration
            ??  topCard.animationOptions.totalResetDuration / 2
    }
    
    func shiftDuration(_ cardStack: SwipeCardStack) -> TimeInterval {
        return cardStack.animationOptions.shiftDuration
    }
    
    func swipeDelay(for topCard: SwipeCard, forced: Bool) -> TimeInterval {
        let duration = topCard.animationOptions.totalSwipeDuration
        let relativeOverlayDuration = topCard.animationOptions.relativeSwipeOverlayFadeDuration
        let delay = duration * TimeInterval(relativeOverlayDuration)
        return forced ? delay : 0
    }
    
    func swipeDuration(_ cardStack: SwipeCardStack,
                       topCard: SwipeCard,
                       direction: SwipeDirection,
                       forced: Bool) -> TimeInterval {
        if let swipeDuration = cardStack.animationOptions.swipeDuration {
            return swipeDuration
        }
        
        if forced {
            return topCard.animationOptions.totalSwipeDuration / 2
        }
        
        let velocityFactor = topCard.dragSpeed(on: direction) / topCard.minimumSwipeSpeed(on: direction)
        
        // 刷卡低于最低刷卡速度
        if velocityFactor < 1.0 {
            return topCard.animationOptions.totalSwipeDuration / 2
        }
        
        // 刷卡的最低刷卡速度->返回相对持续时间
        return 1.0 / (2.0 * TimeInterval(velocityFactor))
    }
    
    func undoDuration(_ cardStack: SwipeCardStack, topCard: SwipeCard) -> TimeInterval {
        return cardStack.animationOptions.undoDuration
            ?? topCard.animationOptions.totalReverseSwipeDuration / 2
    }
}
