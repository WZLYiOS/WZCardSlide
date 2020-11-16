//
//  CardLayoutProvidable.swift
//  Array+Extensions
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import Foundation

/// MARK - 扩展洗牌数组
extension Array {
    
    mutating func shift(withDistance distance: Int = 1) {
        let offsetIndex = distance >= 0
            ? index(startIndex, offsetBy: distance, limitedBy: endIndex)
            : index(endIndex, offsetBy: distance, limitedBy: startIndex)
        guard let index = offsetIndex else { return }
        self = Array(self[index ..< endIndex] + self[startIndex ..< index])
    }
}

/// MARK - Hashable
extension Array where Element: Hashable {
    
    func removingDuplicates() -> [Element] {
        var dict = [Element: Bool]()
        return filter { dict.updateValue(true, forKey: $0) == nil }
    }
    
    /// 删除重复的
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
