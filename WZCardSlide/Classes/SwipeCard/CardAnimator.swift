//
//  CardAnimatable.swift
//  SwipeView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - 卡片动画
protocol CardAnimatable {
    
    
    /// 调用此方法将在卡片上触发一个类似spring的动画，最终返回到,它是原来的位置
    /// - Parameter card: SwipeCard
    func animateReset(on card: SwipeCard)
    
    
    /// 调用此方法将触发卡上的反向滑动(即撤销)动画
    /// - Parameters:
    ///   - card: SwipeCard
    ///   - direction: SwipeDirection
    ///   - completion: completion
    func animateReverseSwipe(on card: SwipeCard,
                             from direction: SwipeDirection,
                             completion: ((Bool) -> Void)?)
    
    
    /// 调用此方法将触发卡上的滑动动画
    /// - Parameters:
    ///   - card: SwipeCard
    ///   - direction: SwipeDirection
    ///   - forced: forced
    ///   - completion: completion
    func animateSwipe(on card: SwipeCard,
                      direction: SwipeDirection,
                      forced: Bool,
                      completion: ((Bool) -> Void)?)
    
    /// 调用这个方法将删除卡片及其层上的任何活动动画
    /// - Parameters:
    ///   - card: SwipeCard
    func removeAllAnimations(on card: SwipeCard)
}


/// MARK - CardAnimator
class CardAnimator: CardAnimatable {
    
    
    // MARK: - Main Methods
    func animateReset(on card: SwipeCard) {
        removeAllAnimations(on: card)
        
        Animator.animateSpring(withDuration: card.animationOptions.totalResetDuration,
                               usingSpringWithDamping: card.animationOptions.resetSpringDamping,
                               options: [.curveLinear, .allowUserInteraction],
                               animations: {
                                if let direction = card.activeDirection(),
                                   let overlay = card.overlay(forDirection: direction) {
                                    overlay.alpha = 0
                                }
                                card.transform = .identity
                               })
    }
    
    func animateReverseSwipe(on card: SwipeCard,
                             from direction: SwipeDirection,
                             completion: ((Bool) -> Void)?) {
        removeAllAnimations(on: card)
        
        // recreate swipe
        Animator.animateKeyFrames(withDuration: 0.0,
                                  animations: { [weak self] in
                                    self?.addSwipeAnimationKeyFrames(card,
                                                                     direction: direction,
                                                                     forced: true)
                                  })
        
        // reverse swipe
        Animator.animateKeyFrames(withDuration: card.animationOptions.totalReverseSwipeDuration,
                                  options: .calculationModeLinear,
                                  animations: { [weak self] in
                                    self?.addReverseSwipeAnimationKeyFrames(card, direction: direction)},
                                  completion: completion)
    }
    
    func animateSwipe(on card: SwipeCard,
                      direction: SwipeDirection,
                      forced: Bool,
                      completion: ((Bool) -> Void)?) {
        removeAllAnimations(on: card)
        
        let duration = swipeDuration(card, direction: direction, forced: forced)
        Animator.animateKeyFrames(withDuration: duration,
                                  options: .calculationModeLinear,
                                  animations: { [weak self] in
                                    self?.addSwipeAnimationKeyFrames(card,
                                                                     direction: direction,
                                                                     forced: forced) },
                                  completion: completion)
    }
    
    func removeAllAnimations(on card: SwipeCard) {
        card.layer.removeAllAnimations()
        card.swipeDirections.forEach {
            card.overlay(forDirection: $0)?.layer.removeAllAnimations()
        }
    }
    
    // MARK: - Animation Keyframes
    
    func addReverseSwipeAnimationKeyFrames(_ card: SwipeCard, direction: SwipeDirection) {
        let relativeOverlayDuration = relativeReverseSwipeOverlayFadeDuration(card, direction: direction)
        
        // transform
        Animator.addTransformKeyFrame(to: card,
                                      relativeDuration: 1 - relativeOverlayDuration,
                                      transform: .identity)
        
        // overlays
        for swipeDirection in card.swipeDirections {
            card.overlay(forDirection: direction)?.alpha = swipeDirection == direction ? 1.0 : 0.0
        }
        
        let overlay = card.overlay(forDirection: direction)
        Animator.addFadeKeyFrame(to: overlay,
                                 withRelativeStartTime: 1 - relativeOverlayDuration,
                                 relativeDuration: relativeOverlayDuration,
                                 alpha: 0.0)
    }
    
    func addSwipeAnimationKeyFrames(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) {
        let relativeOverlayDuration = relativeSwipeOverlayFadeDuration(card,
                                                                       direction: direction,
                                                                       forced: forced)
        
        // overlays
        for swipeDirection in card.swipeDirections.filter({ $0 != direction }) {
            card.overlay(forDirection: swipeDirection)?.alpha = 0.0
        }
        
        let overlay = card.overlay(forDirection: direction)
        Animator.addFadeKeyFrame(to: overlay,
                                 relativeDuration: relativeOverlayDuration,
                                 alpha: 1.0)
        
        if forced == true {
            
            switch direction {
            case .right:
                Animator.addKeyFrame {
                    card.transform = CGAffineTransform(rotationAngle: 0.1001667222883702)
                        .concatenating(CGAffineTransform(translationX: UIScreen.main.bounds.size.width / 3, y: 64))
                }
            case .left:
                Animator.addKeyFrame {
                    card.transform = CGAffineTransform(rotationAngle: -0.1001667222883702)
                        .concatenating(CGAffineTransform(translationX: -UIScreen.main.bounds.size.width / 3, y: 64))
                }
            default:
                break
            }
        }
        
        
        // transform
        let transform = swipeTransform(card, direction: direction, forced: forced)
        Animator.addTransformKeyFrame(to: card,
                                      withRelativeStartTime: relativeOverlayDuration,
                                      relativeDuration: 1 - relativeOverlayDuration,
                                      transform: transform)
    }
    
    // MARK: - Animation Calculations
    
    func relativeReverseSwipeOverlayFadeDuration(_ card: SwipeCard,
                                                 direction: SwipeDirection) -> Double {
        let overlay = card.overlay(forDirection: direction)
        if overlay != nil {
            return card.animationOptions.relativeReverseSwipeOverlayFadeDuration
        }
        return 0.0
    }
    
    func relativeSwipeOverlayFadeDuration(_ card: SwipeCard,
                                          direction: SwipeDirection,
                                          forced: Bool) -> Double {
        let overlay = card.overlay(forDirection: direction)
        if forced && overlay != nil {
            return card.animationOptions.relativeSwipeOverlayFadeDuration
        }
        return 0.0
    }
    
    func swipeDuration(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) -> TimeInterval {
        if forced {
            return card.animationOptions.totalSwipeDuration
        }
        
        let velocityFactor = card.dragSpeed(on: direction) / card.minimumSwipeSpeed(on: direction)
        
        // card swiped below the minimum swipe speed
        if velocityFactor < 1.0 {
            return card.animationOptions.totalSwipeDuration
        }
        
        // card swiped at least the minimum swipe speed -> return relative duration
        return 1.0 / TimeInterval(velocityFactor)
    }
    
    func swipeRotationAngle(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) -> CGFloat {
        if direction == .up || direction == .down { return 0.0 }
        
        let rotationDirectionY: CGFloat = direction == .left ? -1.0 : 1.0
        
        if forced {
            return 2 * rotationDirectionY * card.animationOptions.maximumRotationAngle
        }
        
        guard let touchPoint = card.touchLocation else {
            return 2 * rotationDirectionY * card.animationOptions.maximumRotationAngle
        }
        
        if (direction == .left && touchPoint.y < card.bounds.height / 2)
            || (direction == .right && touchPoint.y >= card.bounds.height / 2) {
            return -2 * card.animationOptions.maximumRotationAngle
        }
        
        return 2 * card.animationOptions.maximumRotationAngle
    }
    
    func swipeTransform(_ card: SwipeCard, direction: SwipeDirection, forced: Bool) -> CGAffineTransform {
        let dragTranslation = CGVector(to: card.panGestureRecognizer.translation(in: card.superview))
        var actualTranslation: CGPoint!
        var rotationAngle: CGFloat!
        if forced && (direction == .left || direction == .right) {
            if direction == .left {
                actualTranslation = CGPoint(x: -1566.6753059285948, y: 894.1695417396584)
                rotationAngle = -0.6283185307179586
            } else {
                actualTranslation = CGPoint(x: 1566.6753059285948, y: 894.1695417396584)
                rotationAngle = 0.6283185307179586
            }
        } else {
            let normalizedDragTranslation = forced ? direction.vector : dragTranslation.normalized
            actualTranslation = CGPoint(swipeTranslation(card,
                                                         direction: direction,
                                                         directionVector: normalizedDragTranslation))
            rotationAngle = swipeRotationAngle(card, direction: direction, forced: forced)
        }
        return CGAffineTransform(rotationAngle: rotationAngle)
            .concatenating(CGAffineTransform(translationX: actualTranslation.x, y: actualTranslation.y))
    }
    
    func swipeTranslation(_ card: SwipeCard, direction: SwipeDirection, directionVector: CGVector) -> CGVector {
        
        let cardDiagonalLength = CGVector(card.bounds.size).length
        let maxScreenLength = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let minimumOffscreenTranslation = CGVector(dx: maxScreenLength + cardDiagonalLength,
                                                   dy: maxScreenLength + cardDiagonalLength)
        return CGVector(dx: directionVector.dx * minimumOffscreenTranslation.dx,
                        dy: directionVector.dy * minimumOffscreenTranslation.dy)
    }
}
