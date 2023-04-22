//
//  SwipeCard.swift
//  SwipeView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit

/// MARK - 卡片视图
open class SwipeCard: SwipeView {
    
    open var animationOptions: CardAnimatableOptions = CardAnimationOptions.default
    
    /// 主内容视图
    public var content: UIView? {
        didSet {
            if let content = content {
                oldValue?.removeFromSuperview()
                addSubview(content)
            }
        }
    }
    
    /// 底部视图
    public var footer: UIView? {
        didSet {
            if let footer = footer {
                oldValue?.removeFromSuperview()
                addSubview(footer)
            }
        }
    }
    
    /// 底部高度
    public var footerHeight: CGFloat = 100 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 委托
    weak var delegate: SwipeCardDelegate?
    
    /// 点击位置
    var touchLocation: CGPoint? {
        return internalTouchLocation
    }
    
    /// 内部点击位置
    private var internalTouchLocation: CGPoint?
    
    
    /// 滑动完成
    var swipeCompletionBlock: () -> Void {
        return { [weak self] in
            self?.removeFromSuperview()
        }
    }
    
    /// 反向滑动完成块
    var reverseSwipeCompletionBlock: () -> Void {
        return { [weak self] in
            self?.isUserInteractionEnabled = true
        }
    }
    
    /// 二级的卡片取消是否动画
    public var toCardisCancelAnimation: Bool = true
    /// 是否全屏
    public var overlaysIsFullScreen: Bool = false
    private let overlayContainer = UIView()
    private var overlays = [SwipeDirection: UIView]()
    private var animator: CardAnimatable = CardAnimator()
    private var layoutProvider: CardLayoutProvidable = CardLayoutProvider()
    private var transformProvider: CardTransformProvidable = CardTransformProvider()
    
    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(animator: CardAnimatable,
                     layoutProvider: CardLayoutProvidable,
                     transformProvider: CardTransformProvidable) {
        self.init(frame: .zero)
        self.animator = animator
        self.layoutProvider = layoutProvider
        self.transformProvider = transformProvider
    }
    
    private func initialize() {
        addSubview(overlayContainer)
        overlayContainer.setUserInteraction(false)
    }
    
    // MARK: - Layout
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        footer?.frame = layoutProvider.createFooterFrame(for: self)
        layoutContentView()
        layoutOverlays()
    }
    
    private func layoutContentView() {
        guard let content = content else { return }
        content.frame = layoutProvider.createContentFrame(for: self)
        sendSubviewToBack(content)
    }
    
    private func layoutOverlays() {
        overlayContainer.frame = layoutProvider.createOverlayContainerFrame(for: self)
        bringSubviewToFront(overlayContainer)
        if overlaysIsFullScreen {
            overlays.values.forEach { $0.frame = overlayContainer.bounds }
        }
    }
    
    // MARK: - Overrides
    
    override open func didTap(_ recognizer: UITapGestureRecognizer) {
        super.didTap(recognizer)
        internalTouchLocation = recognizer.location(in: self)
        delegate?.card(didTap: self)
    }
    
    override open func beginSwiping(_ recognizer: UIPanGestureRecognizer) {
        super.beginSwiping(recognizer)
    
        internalTouchLocation = recognizer.location(in: self)
        delegate?.card(didBeginSwipe: self)
        animator.removeAllAnimations(on: self)
    }
    
    override open func continueSwiping(_ recognizer: UIPanGestureRecognizer) {
        super.continueSwiping(recognizer)
        
        if delegate?.card(isCanMove: self) == false { return }
        delegate?.card(didContinueSwipe: self)
        
        transform = transformProvider.transform(for: self)
        
        for (direction, overlay) in overlays {
            overlay.alpha = transformProvider.overlayPercentage(for: self, direction: direction)
        }
    }
    
    override open func endSwiping(_ recognizer: UIPanGestureRecognizer) {
        super.endSwiping(recognizer)
        
        if delegate?.card(isCanMove: self) == false { return }
        delegate?.card(endSwiping: self)
    }
    
    override open func didSwipe(_ recognizer: UIPanGestureRecognizer,
                                with direction: SwipeDirection) {
        super.didSwipe(recognizer, with: direction)
        if delegate?.card(isCanMove: self) == false {
            return
        }
        delegate?.card(didSwipe: self, with: direction)
        swipeAction(direction: direction, forced: false)
    }
    
    override open func didCancelSwipe(_ recognizer: UIPanGestureRecognizer) {
        super.didCancelSwipe(recognizer)
        if toCardisCancelAnimation {
            delegate?.card(didCancelSwipe: self)
        }
        animator.animateReset(on: self)
    }
    
    // MARK: - Main Methods
    
    public func setOverlay(_ overlay: UIView?, forDirection direction: SwipeDirection) {
        overlays[direction]?.removeFromSuperview()
        overlays[direction] = overlay
        
        if let overlay = overlay {
            overlayContainer.addSubview(overlay)
            overlay.alpha = 0
            overlay.setUserInteraction(false)
        }
    }
    
    public func setOverlays(_ overlays: [SwipeDirection: UIView]) {
        for (direction, overlay) in overlays {
            setOverlay(overlay, forDirection: direction)
        }
    }
    
    public func overlay(forDirection direction: SwipeDirection) -> UIView? {
        return overlays[direction]
    }
    
    
    /// 调用此方法将触发一个滑动动画。
    /// -参数方向:卡将滑出屏幕的方向
    public func swipe(direction: SwipeDirection) {
        swipeAction(direction: direction, forced: true)
    }
    
    func swipeAction(direction: SwipeDirection, forced: Bool) {
        isUserInteractionEnabled = false
        animator.animateSwipe(on: self,
                              direction: direction,
                              forced: forced) { [weak self] finished in
            if finished {
                self?.swipeCompletionBlock()
            }
        }
    }
    
    /// 调用此方法将触发反向滑动(撤销)动画。
    /// -参数方向:卡片离开屏幕的方向。
    public func reverseSwipe(from direction: SwipeDirection) {
        isUserInteractionEnabled = false
        animator.animateReverseSwipe(on: self, from: direction) { [weak self] finished in
            if finished {
                self?.reverseSwipeCompletionBlock()
            }
        }
    }
    
    public func removeAllAnimations() {
        layer.removeAllAnimations()
        animator.removeAllAnimations(on: self)
    }
}
