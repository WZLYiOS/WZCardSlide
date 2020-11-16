//
//  CardLayoutProvidable.swift
//  UIView+Extensions
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 设置子视图是否启用
    /// - Parameter isEnabled: 是否启用
    func setUserInteraction(_ isEnabled: Bool) {
        isUserInteractionEnabled = isEnabled
        for subview in subviews {
            subview.setUserInteraction(isEnabled)
        }
    }
}
