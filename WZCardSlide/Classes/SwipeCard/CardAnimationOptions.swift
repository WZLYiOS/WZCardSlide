//
//  CardAnimatableOptions.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - 卡片动画可选协议
public protocol CardAnimatableOptions {
    
    /// 卡的最大旋转角度，以弧度为单位
    var maximumRotationAngle: CGFloat { get }
    
    /// 反向滑动平移后应用于覆盖的淡入动画的持续时间
    var relativeReverseSwipeOverlayFadeDuration: Double { get }
    
    /// 在滑动平移之前应用于覆盖的淡入动画的持续时间
    var relativeSwipeOverlayFadeDuration: Double { get }
    
    /// 取消滑动时应用的弹簧状动画的阻尼系数
    var resetSpringDamping: CGFloat { get }
    
    /// 总重置持续时间，以秒为单位
    var totalResetDuration: TimeInterval { get }
    
    /// 反向滑动动画的总持续时间，以秒为单位
    var totalReverseSwipeDuration: TimeInterval { get }
    
    /// 滑动动画的总持续时间，以秒为单位
    var totalSwipeDuration: TimeInterval { get }
}


/// MARK - CardAnimationOptions
public final class CardAnimationOptions: CardAnimatableOptions {
    
    /// 单利
    public static let `default`: CardAnimationOptions = CardAnimationOptions()
    
    
    /// 卡的最大旋转角度，以弧度为单位 范围: [0, CGFloat.pi/2], 默认: CGFloat.pi/10
    public let maximumRotationAngle: CGFloat
    
    
    /// 反向滑动平移后应用于覆盖的淡入动画的持续时间 范围:`[0, 1]` 默认: 0.15
    public let relativeReverseSwipeOverlayFadeDuration: Double
    
    
    /// 在滑动平移之前应用于覆盖的淡入动画的持续时间 范围:`[0, 1]` 默认: 0.15
    public let relativeSwipeOverlayFadeDuration: Double
    
    
    /// 取消滑动时应用的弹簧状动画的阻尼系数  范围:`[0, 1]` 默认: 0.5
    public let resetSpringDamping: CGFloat
    
    
    /// 总重置持续时间，以秒为单位 默认: `0.6`
    public let totalResetDuration: TimeInterval
    
    
    /// 反向滑动动画的总持续时间，以秒为单位 默认: `0.25
    public let totalReverseSwipeDuration: TimeInterval
    
    
    /// 滑动动画的总持续时间，以秒为单位 默认: `0.7`
    public let totalSwipeDuration: TimeInterval
    
    
    /// 初始化
    public init(maximumRotationAngle: CGFloat = .pi / 10,
                relativeReverseSwipeOverlayFadeDuration: Double = 0.15,
                relativeSwipeOverlayFadeDuration: Double = 0.15,
                resetSpringDamping: CGFloat = 0.5,
                totalResetDuration: TimeInterval = 0.6,
                totalReverseSwipeDuration: TimeInterval = 0.25,
                totalSwipeDuration: TimeInterval = 0.7) {
        
        self.maximumRotationAngle = max(-.pi / 2, min(maximumRotationAngle, .pi / 2))
        self.relativeReverseSwipeOverlayFadeDuration = max(0, min(relativeReverseSwipeOverlayFadeDuration, 1))
        self.relativeSwipeOverlayFadeDuration = max(0, min(relativeSwipeOverlayFadeDuration, 1))
        self.resetSpringDamping = max(0, min(resetSpringDamping, 1))
        self.totalResetDuration = max(0, totalResetDuration)
        self.totalReverseSwipeDuration = max(0, totalReverseSwipeDuration)
        self.totalSwipeDuration = max(0, totalSwipeDuration)
    }
}
