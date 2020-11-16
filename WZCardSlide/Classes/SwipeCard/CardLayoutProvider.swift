//
//  CardLayoutProvidable.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - 卡片布局协议
protocol CardLayoutProvidable {
    
    /// 创建内容布局
    /// - Parameter card: SwipeCard
    func createContentFrame(for card: SwipeCard) -> CGRect
    
    
    /// 创建底部布局
    /// - Parameter card: SwipeCard
    func createFooterFrame(for card: SwipeCard) -> CGRect
    
    
    /// 创建覆盖容器布局
    /// - Parameter card: SwipeCard
    func createOverlayContainerFrame(for card: SwipeCard) -> CGRect
}


/// MARK - 卡片布局提供者
class CardLayoutProvider: CardLayoutProvidable {
    
    
    /// 创建内容布局
    /// - Parameter card: SwipeCard
    /// - Returns: CGRect
    func createContentFrame(for card: SwipeCard) -> CGRect {
        
        if let footer = card.footer, footer.isOpaque {
            return CGRect(x: 0,
                          y: 0,
                          width: card.bounds.width,
                          height: card.bounds.height - card.footerHeight)
        }
        return card.bounds
    }
    
    
    /// 创建底部布局
    /// - Parameter card: SwipeCard
    /// - Returns: CGRect
    func createFooterFrame(for card: SwipeCard) -> CGRect {
        return CGRect(x: 0,
                      y: card.bounds.height - card.footerHeight,
                      width: card.bounds.width,
                      height: card.footerHeight)
    }
    
    
    /// 创建覆盖容器布局
    /// - Parameter card: SwipeCard
    /// - Returns: CGRect
    func createOverlayContainerFrame(for card: SwipeCard) -> CGRect {
        if card.footer != nil {
            return CGRect(x: 0,
                          y: 0,
                          width: card.bounds.width,
                          height: card.bounds.height - card.footerHeight)
        }
        return card.bounds
    }
}
