//
//  CardStackLayoutProvidable.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - 卡栈布局提供者协议
protocol CardStackLayoutProvidable {
    
    /// 创建卡片容器布局
    /// - Parameter cardStack: SwipeCardStack
    func createCardContainerFrame(for cardStack: SwipeCardStack) -> CGRect
    
    
    /// 创建卡片布局
    /// - Parameter cardStack: SwipeCardStack
    func createCardFrame(for cardStack: SwipeCardStack) -> CGRect
}



/// MARK - 卡堆栈布局提供者类
class CardStackLayoutProvider: CardStackLayoutProvidable {
    
    /// 创建卡片容器布局
    /// - Parameter cardStack: SwipeCardStack
    /// - return: CGRect
    func createCardContainerFrame(for cardStack: SwipeCardStack) -> CGRect {
        let insets = cardStack.cardStackInsets
        let width = cardStack.bounds.width - (insets.left + insets.right)
        let height = cardStack.bounds.height - (insets.top + insets.bottom)
        return CGRect(x: insets.left, y: insets.top, width: width, height: height)
    }
    
    /// 创建卡片布局
    /// - Parameter cardStack: SwipeCardStack
    /// - return: CGRect
    func createCardFrame(for cardStack: SwipeCardStack) -> CGRect {
        let containerSize = createCardContainerFrame(for: cardStack).size
        return CGRect(origin: .zero, size: containerSize)
    }
}
