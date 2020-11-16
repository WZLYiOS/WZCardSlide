//
//  SwipeCardStackDataSource.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//


import Foundation


/// MARK - 卡片数据源
public protocol SwipeCardStackDataSource: AnyObject {
    
    /// 数量
    /// - Parameter cardStack: <#cardStack description#>
    func numberOfCards(in cardStack: SwipeCardStack) -> Int
    
    
    /// 卡片视图
    /// - Parameters:
    ///   - cardStack: SwipeCardStack
    ///   - index: 索引
  func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard
}
