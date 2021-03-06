//
//  CardLayoutProvidable.swift
//  TapGestureRecognizer
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - TapGestureRecognizer
class TapGestureRecognizer: UITapGestureRecognizer {
    
    private weak var testTarget: AnyObject?
    private var testAction: Selector?
    
    private var testLocation: CGPoint?
    
    override init(target: Any?, action: Selector?) {
        testTarget = target as AnyObject
        testAction = action
        super.init(target: target, action: action)
    }
    
    override func location(in view: UIView?) -> CGPoint {
        return testLocation ?? super.location(in: view)
    }
    
    func performTap(withLocation location: CGPoint?) {
        testLocation = location
        if let action = testAction {
            testTarget?.performSelector(onMainThread: action,
                                        with: self,
                                        waitUntilDone: true)
        }
    }
}
