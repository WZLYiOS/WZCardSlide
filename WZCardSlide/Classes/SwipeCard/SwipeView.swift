//
//  SwipeView.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - SwipeView
open class SwipeView: UIView {
    
    /// 视图检测到的滑动方向,设置此变量以忽略某些方向
    open var swipeDirections = SwipeDirection.allDirections
    
    /// 附加到视图的平移手势识别器
    public var panGestureRecognizer: UIPanGestureRecognizer {
        return internalPanGestureRecognizer
    }
    
    
    /// 内部平移手势识别器
    private lazy var internalPanGestureRecognizer = PanGestureRecognizer(target: self,
                                                                         action: #selector(handlePan))
    
    /// 点击手势识别器附加到视图
    public var tapGestureRecognizer: UITapGestureRecognizer {
        return internalTapGestureRecognizer
    }
    
    
    /// 内部点击手势识别器
    private lazy var internalTapGestureRecognizer = TapGestureRecognizer(target: self,
                                                                         action: #selector(didTap))
    
    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addGestureRecognizer(internalPanGestureRecognizer)
        addGestureRecognizer(internalTapGestureRecognizer)
    }
    
    // MARK: - Swipe Calculations
    

    /// 视图上的主动滑动方向(如果有的话)
    /// - Returns: 方向
    public func activeDirection() -> SwipeDirection? {
        return swipeDirections.reduce((CGFloat.zero, nil)) { [unowned self] lastResult, direction in
            let dragPercentage = self.dragPercentage(on: direction)
            return dragPercentage > lastResult.0 ? (dragPercentage, direction) : lastResult
        }.1
    }
    

    /// 当前拖动速度投射到指定方向上的速度
    /// - Parameter direction: 方向
    /// - Returns: 速度
    public func dragSpeed(on direction: SwipeDirection) -> CGFloat {
        let velocity = panGestureRecognizer.velocity(in: superview)
        return abs(direction.vector * CGVector(to: velocity))
    }
    

    /// 当前拖动平移达到指定方向的“最小旋转距离”的百分比
    /// - Parameter direction: 方向
    /// - Returns: 百分比
    public func dragPercentage(on direction: SwipeDirection) -> CGFloat {
        let translation = CGVector(to: panGestureRecognizer.translation(in: superview))
        let scaleFactor = 1 / minimumSwipeDistance(on: direction)
        let percentage = scaleFactor * (translation * direction.vector)
        return percentage < 0 ? 0 : percentage
    }
    
    
    /// 在预期方向上触发滑动所需的最低速度。子类可以重写，自定义滑动行为的方法。
    /// - Parameter direction: 方向
    /// - Returns: 每秒点数。每个方向默认为1100
    open func minimumSwipeSpeed(on direction: SwipeDirection) -> CGFloat {
        return 1100
    }
    

    /// 在预期方向上触发滑动所需的最小拖动距离，从
    /// swipe最初的触点。子类可以重写此方法来定制滑动行为
    /// - Parameter direction: 方向
    /// - Returns: 在指定方向上触发一击所需的最小距离，默认为屏幕宽度和高度最小值的1/4
    open func minimumSwipeDistance(on direction: SwipeDirection) -> CGFloat {
        return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 4
    }
    
    // MARK: - Gesture Recognition
    
    
    /// 点击手势
    /// - Parameter recognizer: UITapGestureRecognizer
    @objc open func didTap(_ recognizer: UITapGestureRecognizer) {}
    
    
    /// 手势开始
    /// - Parameter recognizer: UIPanGestureRecognizer
    open func beginSwiping(_ recognizer: UIPanGestureRecognizer) {}
    

    /// 每当视图识别活动滑动中的更改时，就会调用此函数
    /// - Parameter recognizer: UIPanGestureRecognizer
    open func continueSwiping(_ recognizer: UIPanGestureRecognizer) {}
    
    
    /// 只要视图识别到滑动结束，就会调用此函数，而不管是否滑动
    /// - Parameter recognizer: UIPanGestureRecognizer
    open func endSwiping(_ recognizer: UIPanGestureRecognizer) {
        if let direction = activeDirection() {
            if dragSpeed(on: direction) >= minimumSwipeSpeed(on: direction)
                || dragPercentage(on: direction) >= 1 {
                didSwipe(recognizer, with: direction)
                return
            }
        }
        didCancelSwipe(recognizer)
    }
    

    /// 只要视图识别到滑动，就调用此函数。默认的实现是;子类可以重写这个方法来执行任何必要的操作
    /// - Parameters:
    ///   - recognizer: UIPanGestureRecognizer
    ///   - direction: direction
    open func didSwipe(_ recognizer: UIPanGestureRecognizer, with direction: SwipeDirection) {}
    

    /// 每当视图识别取消的滑动时，就调用此函数。
    /// - Parameter recognizer: UIPanGestureRecognizer
    open func didCancelSwipe(_ recognizer: UIPanGestureRecognizer) {}
    
    
    // MARK: - Selectors
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .possible, .began:
            beginSwiping(recognizer)
        case .changed:
            continueSwiping(recognizer)
        case .ended, .cancelled:
            endSwiping(recognizer)
        default:
            break
        }
    }
}
