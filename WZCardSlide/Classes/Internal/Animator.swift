//
//  CardLayoutProvidable.swift
//  Animator
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit

/// MARK - 包装UIView animation
enum Animator {
    
    static func addKeyFrame(withRelativeStartTime relativeStartTime: Double = 0.0,
                            relativeDuration: Double = 1.0,
                            animations: @escaping () -> Void) {
        UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                           relativeDuration: relativeDuration,
                           animations: animations)
    }
    
    static func addFadeKeyFrame(to view: UIView?,
                                withRelativeStartTime relativeStartTime: Double = 0.0,
                                relativeDuration: Double = 1.0,
                                alpha: CGFloat) {
        UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                           relativeDuration: relativeDuration) {
            view?.alpha = alpha
        }
    }
    
    static func addTransformKeyFrame(to view: UIView?,
                                     withRelativeStartTime relativeStartTime: Double = 0.0,
                                     relativeDuration: Double = 1.0,
                                     transform: CGAffineTransform) {
        UIView.addKeyframe(withRelativeStartTime: relativeStartTime,
                           relativeDuration: relativeDuration) {
            view?.transform = transform
        }
    }
    
    static func animateKeyFrames(withDuration duration: TimeInterval,
                                 delay: TimeInterval = 0.0,
                                 options: UIView.KeyframeAnimationOptions = [],
                                 animations: @escaping (() -> Void),
                                 completion: ((Bool) -> Void)? = nil) {
        UIView.animateKeyframes(withDuration: duration,
                                delay: delay,
                                options: options,
                                animations: animations,
                                completion: completion)
    }
    
    static func animateSpring(withDuration duration: TimeInterval,
                              delay: TimeInterval = 0.0,
                              usingSpringWithDamping damping: CGFloat,
                              initialSpringVelocity: CGFloat = 0.0,
                              options: UIView.AnimationOptions,
                              animations: @escaping () -> Void,
                              completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: initialSpringVelocity,
                       options: options,
                       animations: animations,
                       completion: completion)
    }
}
