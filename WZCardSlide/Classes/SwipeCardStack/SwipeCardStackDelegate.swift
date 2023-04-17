//
//  SwipeCardStackDelegate.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import Foundation


/// MARK - 卡栈视图委托
public protocol SwipeCardStackDelegate: AnyObject {
    
    
    /// 卡片开始动画
    /// - Parameter cardStack: SwipeCardStack
    func cardStackDidBeginAnimating(_ cardStack: SwipeCardStack)
    
    
    /// 卡片动画结束
    /// - Parameter cardStack: SwipeCardStack
    func cardStackDidEndAnimating(_ cardStack: SwipeCardStack)
    
    
    /// 选中当前卡片
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - index: 索引
   func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int)
    
    
    
    ///  卡片移除完成
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - index: index
    ///   - direction: direction
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection)
    
    
    /// 卡片恢复完成委托
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - index: index
    ///   - direction: direction
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection)
    
    
    /// 所有卡片移除
    /// - Parameter cardStack: SwipeCardStack
    func didSwipeAllCards(_ cardStack: SwipeCardStack)
    
    /// 卡片是否可以移动
    /// - Parameter cardStack: SwipeCardStack
    func cardStackIsCanMove(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int) -> Bool
}

/// MARK - SwipeCardStackDelegate
extension SwipeCardStackDelegate {
    
    func cardStackDidBeginAnimating(_ cardStack: SwipeCardStack) {}
    func cardStackDidEndAnimating(_ cardStack: SwipeCardStack) {}
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {}
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {}
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {}
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {}
}
