//
//  SwipeCardDelegate.swift
//  SwipeView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import Foundation


/// MARK - SwipeCardDelegate
protocol SwipeCardDelegate: AnyObject {
    
    /// 开始滑动
    /// - Parameter card: SwipeCard
    func card(didBeginSwipe card: SwipeCard)
    
    
    /// 取消滑动
    /// - Parameter card: SwipeCard
    func card(didCancelSwipe card: SwipeCard)
    
    
    /// 结束刷卡
    /// - Parameter card: SwipeCard
    func card(endSwiping card: SwipeCard)
    
    
    /// 继续刷
    /// - Parameter card: SwipeCard
    func card(didContinueSwipe card: SwipeCard)
    
    
    /// 刷卡
    /// - Parameters:
    ///   - card: SwipeCard
    ///   - direction: direction
    func card(didSwipe card: SwipeCard, with direction: SwipeDirection)
    
    
    /// 点击卡片
    /// - Parameter card: SwipeCard
    func card(didTap card: SwipeCard)
}
