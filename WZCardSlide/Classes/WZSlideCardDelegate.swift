//
//  WZSlideCardDelegate.swift
//  WZCardSlide_Example
//
//  Created by qiuqixiang on 2020/3/24.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

// MARK -  数据协议
public protocol WZSlideCardViewProtocol{

    /// 原始view
    func getContentView() -> UIView
    
    /// 是否占位图
    var isEmptyView: Bool { get }
}

// MARK - 数据源协议
public protocol WZSlideCardDataSource: class {
    
    /// 获取数据源数量
    /// - Parameter dragCard: 容器
    func numberOfCount(_ dragCard: WZSlideCardView) -> Int
    
    /// 每个索引对应的卡片
    /// - Parameters:
    ///   - dragCard: 容器
    ///   - index: 索引
    func dragCard(_ dragCard: WZSlideCardView, indexOfCard index: Int) -> WZSlideCardViewProtocol
}

// MARK - 卡片代理
public protocol WZSlideCardDelegate: class {
    
    /// 点击顶层卡片的回调
    /// - Parameter dragCard: 容器
    /// - Parameter index: 点击的顶层卡片的索引
    /// - Parameter card: 点击的定测卡片
    func dragCard(_ dragCard: WZSlideCardView, didSelectIndexAt index: Int, with card: WZSlideCardViewProtocol)
    
    
    /// 滑动中回调
    /// - Parameters:
    ///   - dragCard: 容器
    ///   - card: 当前卡片
    ///   - index: 当前Inde
    ///   - direction: 当前方向
    func dragCard(_ dragCard: WZSlideCardView, currentCard card: UIView, withIndex index: Int, withCenterY y: CGFloat, withCenterX X: CGFloat)
    
    /// 开始滑动某个卡片
    /// - Parameters:
    ///   - dragCard: 容器
    ///   - card: 卡片
    ///   - index: 当前Index
    func beganDragCard(_ dragCard: WZSlideCardView, currentCard card: UIView, withIndex index: Int)
    
    /// 停止移动 是否滑出屏幕
    /// - Parameters:
    ///   - dragCard: 容器
    ///   - card: 当前卡片
    ///   - index: 当前index
    ///   - isMove: 是否移除
    func endDragCard(_ dragCard: WZSlideCardView, currentCard card: UIView, withIndex index: Int, withMove isMove: Bool)
}
