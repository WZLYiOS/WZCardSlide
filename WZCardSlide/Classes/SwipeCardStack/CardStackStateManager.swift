//
//  CardStackStateManagable.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import Foundation


/// MARK - Swipe
struct Swipe: Equatable {
    var index: Int
    var direction: SwipeDirection
}


/// MARK- 卡栈状态可管理协议
protocol CardStackStateManagable {
    
    /// 尚未被滑动的数据源索引
    var remainingIndices: [Int] { get }
    
    /// 包含卡片堆栈的刷卡历史记录的数组
    var swipes: [Swipe] { get }
    
    /// 索引总数
    var totalIndexCount: Int { get }
    
    
    /// 插入
    /// - Parameters:
    ///   - index: 索引
    ///   - position: 位置
    func insert(_ index: Int, at position: Int)
    
    
    /// 删除
    /// - Parameter index: 索引
    func delete(_ index: Int)
    
    
    /// 删除
    /// - Parameter indices: 索引数组
    func delete(_ indices: [Int])
    
    
    /// 删除位置
    /// - Parameter position: 位置
    func delete(indexAtPosition position: Int)
    
    
    /// 删除位置
    /// - Parameter positions: 位置数组
    func delete(indicesAtPositions positions: [Int])
    
    
    /// 刷卡方向
    /// - Parameter direction: 距离
    func swipe(_ direction: SwipeDirection)
    
    
    /// 恢复
    func undoSwipe() -> Swipe?
    
    
    /// 转变
    /// - Parameter distance: distance
    func shift(withDistance distance: Int)
    
    
    /// 重置
    /// - Parameter numberOfCards: 数量
    func reset(withNumberOfCards numberOfCards: Int)
}

/// MARK - 卡栈状态可管理类
class CardStackStateManager: CardStackStateManagable {
    
    /// 尚未被滑动的数据源索引
    var remainingIndices: [Int] = []
    
    /// 包含卡片堆栈的刷卡历史记录的数组
    var swipes: [Swipe] = []
    
    
    /// 总的数量
    var totalIndexCount: Int {
        return remainingIndices.count + swipes.count
    }
    
    
    
    /// 插入数据
    /// - Parameters:
    ///   - index: 索引
    ///   - position: 位置
    func insert(_ index: Int, at position: Int) {
        // 将所有大于或等于索引的存储索引加1
        remainingIndices = remainingIndices.map { $0 >= index ? $0 + 1 : $0 }
        swipes = swipes.map { $0.index >= index ? Swipe(index: $0.index + 1, direction: $0.direction) : $0 }
        
        remainingIndices.insert(index, at: position)
    }
    
    
    /// 删除
    /// - Parameter index: 索引
    func delete(_ index: Int) {
        
        swipes.removeAll { return $0.index == index }
        
        if let position = remainingIndices.firstIndex(of: index) {
            remainingIndices.remove(at: position)
        }
        remainingIndices = remainingIndices.map { $0 >= index ? $0 - 1 : $0 }
        swipes = swipes.map { $0.index >= index ? Swipe(index: $0.index - 1, direction: $0.direction) : $0 }
    }
    
    
    /// 删除索引
    /// - Parameter indices: 索引数组
    func delete(_ indices: [Int]) {
        var remainingIndices = indices.removingDuplicates()
        
        while !remainingIndices.isEmpty {
            let index = remainingIndices[0]
            delete(index)
            
            remainingIndices.remove(at: 0)
            remainingIndices = remainingIndices.map { $0 >= index ? $0 - 1 : $0 }
        }
    }
    
    
    /// 删除位置
    /// - Parameter position: 位置
    func delete(indexAtPosition position: Int) {
        
        let index = remainingIndices.remove(at: position)
        remainingIndices = remainingIndices.map { $0 >= index ? $0 - 1 : $0 }
        swipes = swipes.map { $0.index >= index ? Swipe(index: $0.index - 1, direction: $0.direction) : $0 }
    }
    
    
    /// 删除位置
    /// - Parameter positions: 位置数组
    func delete(indicesAtPositions positions: [Int]) {
        
        var remainingPositions = positions.removingDuplicates()
        
        while !remainingPositions.isEmpty {
            let position = remainingPositions[0]
            delete(indexAtPosition: position)
            
            remainingPositions.remove(at: 0)
            remainingPositions = remainingPositions.map { $0 >= position ? $0 - 1 : $0 }
        }
    }
    
    /// 刷卡方向
    /// - Parameter direction: SwipeDirection
    func swipe(_ direction: SwipeDirection) {
        
        if remainingIndices.isEmpty { return }
        let firstIndex = remainingIndices.removeFirst()
        let swipe = Swipe(index: firstIndex, direction: direction)
        swipes.append(swipe)
    }
    
    /// 恢复
    func undoSwipe() -> Swipe? {
        if swipes.isEmpty { return nil }
        let lastSwipe = swipes.removeLast()
        remainingIndices.insert(lastSwipe.index, at: 0)
        return lastSwipe
    }
    
    /// 转变
    /// - Parameter distance: 距离
    func shift(withDistance distance: Int) {
        remainingIndices.shift(withDistance: distance)
    }
    
    /// 重置
    /// - Parameter numberOfCards: 数量
    func reset(withNumberOfCards numberOfCards: Int) {
        self.remainingIndices = Array(0..<numberOfCards)
        self.swipes = []
    }
}
