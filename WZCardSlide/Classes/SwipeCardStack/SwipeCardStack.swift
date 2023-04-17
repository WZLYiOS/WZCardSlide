//
//  SwipeCardStack.swift
//  CardView
//
//  Created by xiaobin liu on 2020/10/4.
//  Copyright © 2020 我主良缘. All rights reserved.
//

import UIKit


/// MARK - SwipeCardStack
open class SwipeCardStack: UIView, SwipeCardDelegate, UIGestureRecognizerDelegate {

    /// Card实体
    public struct Card {
        var index: Int
        var card: SwipeCard
    }
    
    /// 动画可选项
    open var animationOptions: CardStackAnimatableOptions = CardStackAnimationOptions()
    
    /// 如果你想忽略纸牌堆上的所有水平手势，返回“false”
    open var shouldRecognizeHorizontalDrag: Bool = true
    
    /// 如果你想忽略卡片堆上所有的垂直手势，返回“false”
    open var shouldRecognizeVerticalDrag: Bool = true
    
    /// 委托
    public weak var delegate: SwipeCardStackDelegate?
    
    /// 数据源委托
    public weak var dataSource: SwipeCardStackDataSource? {
        didSet {
            reloadData()
        }
    }
    
    /// 卡片内边距
    public var cardStackInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 当前顶部索引
    public var topCardIndex: Int? {
        return visibleCards.first?.index
    }
    
    /// 是否背景卡片缩小
    public var isScale: Bool = true
    
    /// 可视数量
    public var numberOfVisibleCards: Int = 2
    
    
    /// 可视卡片数组
    public private(set) var visibleCards: [Card] = []
     
    /// 顶部卡片
    public var topCard: SwipeCard? {
        return visibleCards.first?.card
    }
    
    ///  背景卡片
    public var backgroundCards: [SwipeCard] {
        return Array(visibleCards.dropFirst()).map { $0.card }
    }
    
    /// 是否启用
    public var isEnabled: Bool {
        return !isAnimating && (topCard?.isUserInteractionEnabled ?? true)
    }
    
    /// 是否动画中
    public private(set) var isAnimating: Bool = false
    
    /// 卡片堆栈的背景卡片动画器
    private var animator: CardStackAnimatable = CardStackAnimator()
    
    /// 布局提供者
    private var layoutProvider: CardStackLayoutProvidable = CardStackLayoutProvider()
    
    /// 状态管理
    private var stateManager: CardStackStateManagable = CardStackStateManager()
    
    /// 转换提供者
    public var transformProvider: CardStackTransformProvidable = CardStackTransformProvider()
    
    /// 通知
    private var notificationCenter = NotificationCenter()
    
    /// 卡容器视图
    private let cardContainer = UIView()
    
    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(animator: CardStackAnimatable,
                     layoutProvider: CardStackLayoutProvidable,
                     notificationCenter: NotificationCenter,
                     stateManager: CardStackStateManagable,
                     transformProvider: CardStackTransformProvidable) {
        self.init(frame: .zero)
        self.animator = animator
        self.layoutProvider = layoutProvider
        self.notificationCenter = notificationCenter
        self.stateManager = stateManager
        self.transformProvider = transformProvider
    }
    
    private func initialize() {
        addSubview(cardContainer)
        notificationCenter.addObserver(self,
                                       selector: #selector(didFinishSwipeAnimation),
                                       name: CardDidFinishSwipeAnimationNotification,
                                       object: nil)
    }
    
    // MARK: - Layout
    override open func layoutSubviews() {
        super.layoutSubviews()
        cardContainer.frame = layoutProvider.createCardContainerFrame(for: self)
        for (position, value) in visibleCards.enumerated() {
            layoutCard(value.card, at: position)
        }
    }
    
    
    /// 布局卡片
    /// - Parameters:
    ///   - card: 卡片
    ///   - position: 位置
    func layoutCard(_ card: SwipeCard, at position: Int) {
        card.transform = .identity
        card.frame = layoutProvider.createCardFrame(for: self)
        card.transform = transform(forCardAtPosition: position)
        card.isUserInteractionEnabled = position == 0
    }
    
    
    /// scaleFactor
    /// - Parameter position: 位置
    /// - Returns: CGPoint
    func scaleFactor(forCardAtPosition position: Int) -> CGPoint {
        if isScale {
            return position == 0 ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.95, y: 0.95)
        } else {
            return CGPoint(x: 1, y: 1)
        }
    }
    
    
    /// 变化
    /// - Parameter position: 位置
    /// - Returns: CGAffineTransform
    func transform(forCardAtPosition position: Int) -> CGAffineTransform {
        let cardScaleFactor = scaleFactor(forCardAtPosition: position)
        return CGAffineTransform(scaleX: cardScaleFactor.x, y: cardScaleFactor.y)
    }
    
    
    /// 开始手势识别器
    /// - Parameter gestureRecognizer: UIGestureRecognizer
    /// - Returns: Bool
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let topCard = topCard, topCard.panGestureRecognizer == gestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        
        let velocity = topCard.panGestureRecognizer.velocity(in: self)
        
        if abs(velocity.x) > abs(velocity.y) {
            return shouldRecognizeHorizontalDrag
        }
        
        if abs(velocity.x) < abs(velocity.y) {
            return shouldRecognizeVerticalDrag
        }
        
        return topCard.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    // MARK: - Main Methods
    
    
    /// 按指定方向在卡堆上滑动
    /// - Parameters:
    ///   - direction: 方向
    ///   - animated: 是否动画
    public func swipe(_ direction: SwipeDirection, animated: Bool) {
        
        if !isEnabled { return }
        
        if animated {
            if let currentCard = topCard {
                
                switch direction {
                case .left:
                    currentCard.layer.cornerRadius = 24
                    currentCard.layer.masksToBounds = true
                    currentCard.swipe(direction: direction)
                case .right:
                    currentCard.layer.cornerRadius = 24
                    currentCard.layer.masksToBounds = true
                    currentCard.swipe(direction: direction)
                default:
                    currentCard.swipe(direction: direction)
                }
            }
        } else {
            topCard?.removeFromSuperview()
        }
        
        if let topCard = topCard {
            swipeAction(topCard: topCard,
                        direction: direction,
                        forced: true,
                        animated: animated)
        }
    }
    
    func swipeAction(topCard: SwipeCard,
                     direction: SwipeDirection,
                     forced: Bool,
                     animated: Bool) {
        
        guard let swipedIndex = topCardIndex else { return }
        stateManager.swipe(direction)
        visibleCards.remove(at: 0)
        
        // Insert new card if needed
        if (stateManager.remainingIndices.count - visibleCards.count) > 0 {
            let bottomCardIndex = stateManager.remainingIndices[visibleCards.count]
            if let card = loadCard(at: bottomCardIndex) {
                insertCard(Card(index: bottomCardIndex, card: card), at: visibleCards.count)
            }
        }
        
        delegate?.cardStack(self, didSwipeCardAt: swipedIndex, with: direction)
        
        if stateManager.remainingIndices.isEmpty {
            delegate?.didSwipeAllCards(self)
            return
        }
        
        isAnimating = true
        animator.animateSwipe(self,
                              topCard: topCard,
                              direction: direction,
                              forced: forced,
                              animated: animated) { [weak self] finished in
            /// 这边是因为在快速滑动之后并且开始加载数据会导致不能滑动
            //                    if finished {
            //                       self?.isAnimating = false
            //                    }
            self?.isAnimating = false
        }
    }
    
    
    /// 将最近刷过的卡返回到卡堆的顶部
    /// - Parameter animated: 是否动画
    public func undoLastSwipe(animated: Bool) {
        if !isEnabled { return }
        guard let previousSwipe = stateManager.undoSwipe() else { return }
        
        reloadVisibleCards()
        delegate?.cardStack(self, didUndoCardAt: previousSwipe.index, from: previousSwipe.direction)
        
        if animated {
            topCard?.reverseSwipe(from: previousSwipe.direction)
        }
        
        isAnimating = true
        if let topCard = topCard {
            animator.animateUndo(self,
                                 topCard: topCard,
                                 animated: animated) { [weak self] finished in
                if finished {
                    self?.isAnimating = false
                }
            }
        }
    }
    
    /// 将牌堆中剩余的牌移动指定的距离。任何刷卡都被忽略.
    /// - Parameters:
    ///   - distance: 移动剩余牌的距离
    ///   - animated: 一个布尔值，指示撤销操作是否应该被动画化。
    public func shift(withDistance distance: Int = 1, animated: Bool) {
        if !isEnabled || distance == 0 || visibleCards.count <= 1 { return }
        
        stateManager.shift(withDistance: distance)
        reloadVisibleCards()
        
        isAnimating = true
        animator.animateShift(self,
                              withDistance: distance,
                              animated: animated) { [weak self] finished in
            if finished {
                self?.isAnimating = false
            }
        }
    }
    
    // MARK: - Data Source
    public func reloadData() {
        
        guard let dataSource = dataSource else { return }
        let numberOfCards = dataSource.numberOfCards(in: self)
        stateManager.reset(withNumberOfCards: numberOfCards)
        reloadVisibleCards()
        isAnimating = false
    }
    
    
    /// 返回指定多饮的卡片
    /// - Parameter index: 索引
    /// - Returns: 卡片
    public func card(forIndexAt index: Int) -> SwipeCard? {
        
        for value in visibleCards where value.index == index {
            return value.card
        }
        return nil
    }
    
    
    /// 刷新可视卡片
    func reloadVisibleCards() {
        
        visibleCards.forEach { $0.card.removeFromSuperview() }
        visibleCards.removeAll()
        
        let numberOfCards = min(stateManager.remainingIndices.count, numberOfVisibleCards)
        for position in 0..<numberOfCards {
            let index = stateManager.remainingIndices[position]
            if let card = loadCard(at: index) {
                insertCard(Card(index: index, card: card), at: position)
            }
        }
    }
    
    
    /// 插入卡片位置
    /// - Parameters:
    ///   - value: Card
    ///   - position: position
    func insertCard(_ value: Card, at position: Int) {
        
        cardContainer.insertSubview(value.card, at: visibleCards.count - position)
        layoutCard(value.card, at: position)
        visibleCards.insert(value, at: position)
    }
    
    
    /// 根据索引加载卡片
    /// - Parameter index: 索引
    /// - Returns: 卡片
    func loadCard(at index: Int) -> SwipeCard? {
        
        let card = dataSource?.cardStack(self, cardForIndexAt: index)
        card?.delegate = self
        card?.panGestureRecognizer.delegate = self
        return card
    }
    
    // MARK: - State Management
    
    
    /// 返回卡在指定索引处的当前位置
    /// - Parameter index: 索引
    /// - Returns: 位置
    public func positionforCard(at index: Int) -> Int? {
        return stateManager.remainingIndices.firstIndex(of: index)
    }
    
    /// 返回牌堆中剩余的牌数
    /// - Returns: 数量
    public func numberOfRemainingCards() -> Int {
        return stateManager.remainingIndices.count
    }
    
    /// 按刷卡的顺序返回已刷卡的索引
    /// - Returns: 索引数组
    public func swipedCards() -> [Int] {
        return stateManager.swipes.map { $0.index }
    }
    
    
    /// 在指定位置插入具有给定索引的新卡片
    /// - Parameters:
    ///   - index: 索引
    ///   - position: 位置
    public func insertCard(atIndex index: Int, position: Int) {
        
        guard let dataSource = dataSource else { return }
        
        let oldNumberOfCards = stateManager.totalIndexCount
        let newNumberOfCards = dataSource.numberOfCards(in: self)
        
        stateManager.insert(index, at: position)
        
        if newNumberOfCards != oldNumberOfCards + 1 {
            let errorString = StringUtils.createInvalidUpdateErrorString(newCount: newNumberOfCards,
                                                                         oldCount: oldNumberOfCards,
                                                                         insertedCount: 1)
            fatalError(errorString)
        }
        
        reloadVisibleCards()
    }
    
    
    /// 将带有指定索引的新纸牌集合追加到纸牌堆的底部
    /// - Parameter indices: 索引数组
    public func appendCards(atIndices indices: [Int]) {
        guard let dataSource = dataSource else { return }
        
        let oldNumberOfCards = stateManager.totalIndexCount
        let newNumberOfCards = dataSource.numberOfCards(in: self)
        
        for index in indices {
            stateManager.insert(index, at: numberOfRemainingCards())
        }
        
        if newNumberOfCards != oldNumberOfCards + indices.count {
            let errorString = StringUtils.createInvalidUpdateErrorString(newCount: newNumberOfCards,
                                                                         oldCount: oldNumberOfCards,
                                                                         insertedCount: indices.count)
            fatalError(errorString)
        }
        
        if visibleCards.count < numberOfVisibleCards {
            let beginIndex = visibleCards.count
            let numberOfCards = min(stateManager.remainingIndices.count, numberOfVisibleCards)
            for position in beginIndex..<numberOfCards {
                let index = stateManager.remainingIndices[position]
                if let card = loadCard(at: index) {
                    insertCard(Card(index: index, card: card), at: position)
                }
            }
        }
    }
    
    
    /// 删除指定索引处的卡片。如果一个索引对应于一张已刷过的卡
    /// - Parameter indices: 索引数组
    public func deleteCards(atIndices indices: [Int]) {
        
        guard let dataSource = dataSource else { return }
        
        let oldNumberOfCards = stateManager.totalIndexCount
        let newNumberOfCards = dataSource.numberOfCards(in: self)
        
        if newNumberOfCards != oldNumberOfCards - indices.count {
            let errorString = StringUtils.createInvalidUpdateErrorString(newCount: newNumberOfCards,
                                                                         oldCount: oldNumberOfCards,
                                                                         deletedCount: indices.count)
            fatalError(errorString)
        }
        
        stateManager.delete(indices)
        reloadVisibleCards()
    }
    
    
    /// 根据位置数组删除卡片
    /// - Parameter positions: 位置数组
    public func deleteCards(atPositions positions: [Int]) {
        guard let dataSource = dataSource else { return }
        
        let oldNumberOfCards = stateManager.totalIndexCount
        let newNumberOfCards = dataSource.numberOfCards(in: self)
        
        if newNumberOfCards != oldNumberOfCards - positions.count {
            let errorString = StringUtils.createInvalidUpdateErrorString(newCount: newNumberOfCards,
                                                                         oldCount: oldNumberOfCards,
                                                                         deletedCount: positions.count)
            fatalError(errorString)
        }
        
        stateManager.delete(indicesAtPositions: positions)
        reloadVisibleCards()
    }
    
    // MARK: - Notifications
    @objc
    func didFinishSwipeAnimation(_ notification: NSNotification) {
        guard let card = notification.object as? SwipeCard else { return }
        card.removeFromSuperview()
    }
    
    
    // MARK: - SwipeCardDelegate
    func card(didTap card: SwipeCard) {
        guard let topCardIndex = topCardIndex else { return }
        delegate?.cardStack(self, didSelectCardAt: topCardIndex)
    }
    
    func card(didBeginSwipe card: SwipeCard) {
        delegate?.cardStackDidBeginAnimating(self, didSelectCardAt: topCardIndex ?? 0)
        animator.removeBackgroundCardAnimations(self)
    }
    
    func card(didContinueSwipe card: SwipeCard) {
        delegate?.cardStackDidBeginAnimating(self, didSelectCardAt: topCardIndex ?? 0)
        for (position, backgroundCard) in backgroundCards.enumerated() {
            backgroundCard.transform = transformProvider.backgroundCardDragTransform(for: self,
                                                                                     topCard: card,
                                                                                     currentPosition: position + 1)
        }
    }
    
    func card(endSwiping card: SwipeCard) {
        delegate?.cardStackDidEndAnimating(self)
    }
    
    func card(didCancelSwipe card: SwipeCard) {
        animator.animateReset(self, topCard: card)
    }
    
    func card(didSwipe card: SwipeCard,
              with direction: SwipeDirection) {
        swipeAction(topCard: card, direction: direction, forced: false, animated: true)
    }
    
    func card(isCanMove card: SwipeCard) -> Bool {
        guard let swipedIndex = topCardIndex else { return false }
        return delegate?.cardStackIsCanMove(self, didSwipeCardAt: swipedIndex) ?? true
    }
}
