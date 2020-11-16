//
//  CardStackAnimatableOptions.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import Foundation


/// MARK - 卡片动画可选协议
public protocol CardStackAnimatableOptions {
    
    /// 取消后应用于背景卡的动画持续时间
    var resetDuration: TimeInterval? { get }
    
    /// 卡叠移位动画的持续时间
    var shiftDuration: TimeInterval { get }
    
    /// 刷卡后应用于背景卡的动画持续时间
    var swipeDuration: TimeInterval? { get }
    
    /// “撤销”后应用到背景卡上的动画持续时间
    var undoDuration: TimeInterval? { get }
}


/// MARK - CardStackAnimationOptions
public final class CardStackAnimationOptions: CardStackAnimatableOptions {
    
    /// 取消后应用于背景卡的动画持续时间
    public let resetDuration: TimeInterval?
    
    /// 卡叠移位动画的持续时间
    public let shiftDuration: TimeInterval
    
    /// 刷卡后应用于背景卡的动画持续时间
    public let swipeDuration: TimeInterval?
    
    
    /// “撤销”后应用到背景卡上的动画持续时间
    public let undoDuration: TimeInterval?
    
    public init(resetDuration: TimeInterval? = nil,
                shiftDuration: TimeInterval = 0.1,
                swipeDuration: TimeInterval? = nil,
                undoDuration: TimeInterval? = nil) {
        
        if let resetDuration = resetDuration {
            self.resetDuration = max(0, resetDuration)
        } else {
            self.resetDuration = nil
        }
        
        self.shiftDuration = max(0, shiftDuration)
        if let swipeDuration = swipeDuration {
            self.swipeDuration = max(0, swipeDuration)
        } else {
            self.swipeDuration = nil
        }
        
        if let undoDuration = undoDuration {
            self.undoDuration = max(0, undoDuration)
        } else {
            self.undoDuration = nil
        }
    }
}
