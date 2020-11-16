//
//  CardLayoutProvidable.swift
//  StringUtils
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//


import Foundation

/// MARK - 字符串打印
enum StringUtils {

  static func createInvalidUpdateErrorString(newCount: Int,
                                             oldCount: Int,
                                             insertedCount: Int = 0,
                                             deletedCount: Int = 0) -> String {
    return "更新无效:卡片数量无效。更新后卡片堆栈中包含的卡片数量 (\(newCount)) 必须等于更新前卡栈中包含的卡的数量 (\(oldCount)), 加减插入或删除的卡片数量 (\(insertedCount) 插入, \(deletedCount) 删除)"
  }
}
