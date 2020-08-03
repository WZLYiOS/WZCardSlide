//
//  WZCardSlide.swift
//  WZCardSlide_Example
//
//  Created by qiuqixiang on 2020/3/23.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

// MARK - 存储卡片的位置信息
public class WZSlideCardInfo: NSObject {
    public let cardProtocol: WZSlideCardViewProtocol
    public var transform: CGAffineTransform
    public var frame: CGRect
    init(model: WZSlideCardViewProtocol) {
        self.cardProtocol = model
        self.transform = model.getContentView().transform
        self.frame = model.getContentView().frame
        super.init()
    }
    
    /// 视图
    var card: UIView {
        return cardProtocol.getContentView()
    }
}

// MAKR - 滑动卡片容器
public class WZSlideCardView: UIView {

    /// 数据源
    public weak var dataSource: WZSlideCardDataSource?
    
    /// 协议
    public weak var delegate: WZSlideCardDelegate?
    
    /// 当前添加的视图列表
    public private(set) var infos: [WZSlideCardInfo] = []
    
    /// 卡片位置信息，存入首次，reload时候卡片的详情，为了撤回位置准备
    private var stableInfos: [WZSlideCardInfo] = []
    
    /// 基础配置
    public var config: WZSlideCardConfig = WZSlideCardConfig()
    
    /// 初始顶层卡片的位置
    private var initialFirstCardCenter: CGPoint = .zero
    
    /// 当前索引
    /// 顶层卡片的索引(直接与用户发生交互)
    public private(set) var currentIndex: Int = 0
    
    /// 是否正常撤回
    private var revoking: Bool = false

    /// 刷新整个卡片，回到初始状态
    /// - Parameter animation: 是否动画
    public func reloadData(animation: Bool) {
        
        self.infos.forEach { (transform) in
            transform.card.removeFromSuperview()
        }
        self.infos.removeAll()
        self.stableInfos.removeAll()
        self.currentIndex = 0
        
        // 纠正
        let maxCount: Int = self.dataSource?.numberOfCount(self) ?? 0
        let showCount: Int = min(maxCount, config.visibleCount)
        
        if showCount <= 0 { return }
        
        var scale: CGFloat = 1.0
        if showCount > 1 {
            scale = CGFloat(1.0 - config.correctScale()) / CGFloat(showCount - 1)
        }
        
        let cardWidth = self.bounds.size.width
        var cardHeight: CGFloat = self.bounds.size.height - CGFloat(showCount - 1) * correctCardSpacing()
        if config.cardShowType == .full {
            cardHeight = self.bounds.size.height
        }
        
        for index in 0..<showCount {

            let yMarn = config.cardShowType == .full ? 0 : index
            let y = correctCardSpacing() * CGFloat(yMarn)
            let frame = CGRect(x: 0, y: y, width: cardWidth, height: cardHeight)
            
            let tmpScale: CGFloat = 1.0 - (scale * CGFloat(index))
            let transform = CGAffineTransform(scaleX: tmpScale, y: tmpScale)
            
            guard let model = self.dataSource?.dragCard(self, indexOfCard: index) else {
                continue
            }
            let card = model.getContentView()
            
            card.isUserInteractionEnabled = false
            if config.cardShowType == .pile {
                card.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            }
            insertSubview(card, at: 0)
            card.transform = .identity
            card.frame = frame
    
            if animation {
                UIView.animate(withDuration: 0.25, animations: {
                    card.transform = transform
                }, completion: nil)
            } else {
                card.transform = transform
            }
            
            card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(panGesture:))))
            card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(tapGesture:))))
            infos.append(WZSlideCardInfo(model: model))
            /// 保存首次的各级卡片位置信息
            stableInfos.append(WZSlideCardInfo(model: model))
            if index == 0 {
                initialFirstCardCenter = card.center
                card.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK - 手势操作
extension WZSlideCardView {
    
    /// tap手势
    /// - Parameter tapGesture: gesture
    @objc private func tapGestureRecognizer(tapGesture: UITapGestureRecognizer) {
        guard let model = self.infos.first else { return }
        self.delegate?.dragCard(self, didSelectIndexAt: self.currentIndex, with: model.cardProtocol)
    }

    /// pan手势
    /// - Parameter panGesture: gesture
    @objc private func panGestureRecognizer(panGesture: UIPanGestureRecognizer) {
        guard let cardView = panGesture.view else { return }
        let movePoint = panGesture.translation(in: self)
        let velocity = panGesture.velocity(in: self)
        
        switch panGesture.state {
        case .began:
            //print("begin")
            // 把下一张卡片添加到最底部
            delegate?.beganDragCard(self, currentCard: cardView, withIndex: self.currentIndex)
            installNextCard()
        case .changed:
            //print("changed")
            let currentPoint = CGPoint(x: cardView.center.x + movePoint.x, y: cardView.center.y + movePoint.y)
            // 设置手指拖住的那张卡牌的位置
            cardView.center = currentPoint
            
            // 垂直方向上的滑动比例
            let verticalMoveDistance: CGFloat = cardView.center.y - initialFirstCardCenter.y
            var verticalRatio = verticalMoveDistance / config.correctVerticalRemoveDistance()
            if verticalRatio < -1.0 {
                verticalRatio = -1.0
            } else if verticalRatio > 1.0 {
                verticalRatio = 1.0
            }
            
            // 水平方向上的滑动比例
            let horizontalMoveDistance: CGFloat = cardView.center.x - initialFirstCardCenter.x
            var horizontalRatio = horizontalMoveDistance / config.correctHorizontalRemoveDistance()
            
            if horizontalRatio < -1.0 {
                horizontalRatio = -1.0
            } else if horizontalRatio > 1.0 {
                horizontalRatio = 1.0
            }
            
            // 设置手指拖住的那张卡牌的旋转角度
            let rotationAngle = horizontalRatio * config.correctRemoveMaxAngleAndToRadius()
            cardView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            // 复位
            panGesture.setTranslation(.zero, in: self)
            
            // 卡牌变化
            moving(ratio: config.removeDirection == .horizontal ? abs(horizontalRatio) : abs(verticalRatio))
            delegate?.dragCard(self, currentCard: cardView, withIndex: self.currentIndex, withCenterY:  cardView.center.y, withCenterX: cardView.center.x)
         
        case .ended:
            
            let horizontalMoveDistance: CGFloat = cardView.center.x - initialFirstCardCenter.x
            let verticalMoveDistance: CGFloat = cardView.center.y - initialFirstCardCenter.y
            if config.removeDirection == .horizontal {
                if (abs(horizontalMoveDistance) > config.horizontalRemoveDistance || abs(velocity.x) > config.horizontalRemoveVelocity) &&
                    abs(verticalMoveDistance) > 0.1 && // 避免分母为0
                    abs(horizontalMoveDistance) / abs(verticalMoveDistance) >= tan(config.correctDemarcationAngle()){
                    disappear(horizontalMoveDistance: horizontalMoveDistance, verticalMoveDistance: verticalMoveDistance, isAuto: false)
                } else {
                    restore()
                }
            } else {
                if (abs(verticalMoveDistance) > config.horizontalRemoveDistance || abs(velocity.y) > config.verticalRemoveVelocity) &&
                    abs(verticalMoveDistance) > 0.1 && // 避免分母为0
                    abs(horizontalMoveDistance) / abs(verticalMoveDistance) <= tan(config.correctDemarcationAngle()) {
                    disappear(horizontalMoveDistance: horizontalMoveDistance, verticalMoveDistance: verticalMoveDistance, isAuto: false)
                } else {
                    restore()
                }
            }
        case .cancelled, .failed:
            restore()
        default:
            break
        }
    }
}

// MARK - 卡牌后续操作
extension WZSlideCardView {
    
    /// 纠正cardSpacing  [0.0, bounds.size.height / 2.0]
    func correctCardSpacing() -> CGFloat {
        var spacing: CGFloat = config.cardSpacing
        if config.cardSpacing < 0.0 {
            spacing = 0.0
        } else if config.cardSpacing > bounds.size.height / 2.0 {
            spacing = bounds.size.height / 2.0
        }
        return spacing
    }
    
    /// 卡片移动中其他卡片的变化
    private func moving(ratio: CGFloat) {
        // 1、infos数量小于等于visibleCount
        // 2、infos数量大于visibleCount（infos数量最多只比visibleCount多1）
        var ratio = ratio
        if ratio < 0.0 {
            ratio = 0.0
        } else if ratio > 1.0 {
            ratio = 1.0
        }
        
        for (index, info) in self.infos.enumerated() {
            if self.infos.count <= config.visibleCount {
                if index == 0 { continue }
            } else {
                if index == self.infos.count - 1 || index == 0 { continue }
            }
            let willInfo = self.infos[index - 1]
            
            let currentTransform = info.transform
            let currentFrame = info.frame
            
            let willTransform = willInfo.transform
            let willFrame = willInfo.frame
            
            info.card.transform = CGAffineTransform(scaleX:currentTransform.a - (currentTransform.a - willTransform.a) * ratio,
                                                    y: currentTransform.d - (currentTransform.d - willTransform.d) * ratio)
//            info.card.transform = CGAffineTransform(rotationAngle: 0.8)
            var frame = info.card.frame
            frame.origin.y = currentFrame.origin.y - (currentFrame.origin.y - willFrame.origin.y) * ratio;
            info.card.frame = frame
        }
    }
    
    /// 重置所有卡片位置信息
    private func restore() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                        guard let self = self else { return }
                        for (_, info) in self.infos.enumerated() {
                            info.card.transform = info.transform
                            info.card.frame = info.frame
                        }
        }) { [weak self] (isFinish) in
            guard let self = self else { return }
            if isFinish {
                self.delegate?.endDragCard(self, currentCard: self.infos.first!.card, withIndex: self.currentIndex, withMove: false)
                // 只有当infos数量大于visibleCount时，才移除最底部的卡片
                if self.infos.count > self.config.visibleCount {
                    if let info = self.infos.last {
                        info.card.removeFromSuperview()
                    }
                    self.infos.removeLast()
                }
            }
        }
    }
    
    /// 添加下一张卡片
    private func installNextCard() {
        let maxCount: Int = self.dataSource?.numberOfCount(self) ?? 0
        let showCount: Int = min(maxCount, config.visibleCount)
        if showCount <= 0 { return }
        
        /// 数据已经滑完了
        if self.currentIndex + showCount >= maxCount  { return }
        var model: WZSlideCardViewProtocol? = nil
        
        if maxCount > showCount {
            // 无剩余卡片可以滑动，把之前滑出去的，加在最下面
            if self.currentIndex + showCount >= maxCount {
                model = self.dataSource?.dragCard(self, indexOfCard: self.currentIndex + showCount - maxCount)
            } else {
                // 还有剩余卡片可以滑动
                model = self.dataSource?.dragCard(self, indexOfCard: self.currentIndex + showCount)
            }
        } else { // 最多只是`maxCount = showCount`，比如总数是3张，一次性显示3张3
            // 滑出去的那张，放在最下面
            model = self.dataSource?.dragCard(self, indexOfCard: self.currentIndex)
        }
        
        guard let _model = model else {
            return
        }
        guard let bottomCard = infos.last?.card else { return }
        
        let card = _model.getContentView()
        card.isUserInteractionEnabled = false
        if config.cardShowType == .pile {
            card.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        }
        insertSubview(card, at: 0)

        card.transform = .identity
        card.transform = bottomCard.transform
        card.frame = bottomCard.frame
        
        if !_model.isEmptyView {
            card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(panGesture:))))
            card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(tapGesture:))))
        }
        infos.append(WZSlideCardInfo(model: _model))
    }
    
    /// 顶层卡片消失
    /// - Parameter horizontalMoveDistance: 水平移动距离(相对于initialFirstCardCenter)
    /// - Parameter verticalMoveDistance: 垂直移动距离(相对于initialFirstCardCenter)
    /// - Parameter isAuto: 是否是自动消失
    /// - Parameter closure: 回调
    private func disappear(horizontalMoveDistance: CGFloat, verticalMoveDistance: CGFloat, isAuto: Bool) {
        let animation = { [weak self] in
            guard let self = self else { return }
            // 顶层卡片位置设置
            if let _topCard = self.infos.first?.card {
                if self.config.removeDirection == .horizontal {
                    var flag: Int = 0
                    if horizontalMoveDistance > 0 {
                        flag = 2 // 右边滑出
                    } else {
                        flag = -1 // 左边滑出
                    }
                    let tmpWidth = UIScreen.main.bounds.size.width * CGFloat(flag)
                    let tmpHeight = (verticalMoveDistance / horizontalMoveDistance * tmpWidth) + self.initialFirstCardCenter.y
                    _topCard.center = CGPoint(x: tmpWidth, y: tmpHeight)
                } else {
                    var flag: Int = 0
                    if verticalMoveDistance > 0 {
                        flag = 2 // 向下滑出
                    } else {
                        flag = -1 // 向上滑出
                    }
                    let tmpHeight = UIScreen.main.bounds.size.height * CGFloat(flag)
                    let tmpWidth = horizontalMoveDistance / verticalMoveDistance * tmpHeight + self.initialFirstCardCenter.x
                    _topCard.center = CGPoint(x: tmpWidth, y: tmpHeight)
                }
            }
            // 1、infos数量小于等于visibleCount，表明不会再增加新卡片了
            // 2、infos数量大于visibleCount（infos数量最多只比visibleCount多1）
            for (index, info) in self.infos.enumerated() {
                if self.infos.count <= self.config.visibleCount {
                    if index == 0 { continue }
                } else {
                    if index == self.infos.count - 1 || index == 0 { continue }
                }
                let willInfo = self.infos[index - 1]
                
                info.card.transform = willInfo.transform
                
                var frame = info.card.frame
                frame.origin.y = willInfo.frame.origin.y
                info.card.frame = frame
            }
        }
        if isAuto {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let _self = self else { return }
                if let _topCard = _self.infos.first?.card {
                    if _self.config.removeDirection == .horizontal {
                        _topCard.transform = CGAffineTransform(rotationAngle: horizontalMoveDistance > 0 ? _self.config.correctRemoveMaxAngleAndToRadius() : -_self.config.correctRemoveMaxAngleAndToRadius())
                    } else {
                        // 垂直方向不做处理
                    }
                }
            }
        }
                
        UIView.animate(withDuration: 0.5,
                       animations: {
            animation()
        }) { [weak self] (isFinish) in
            guard let self = self else { return }
            if !isFinish { return }
            // 交换每个info的位置信息
            for (index, info) in self.infos.enumerated().reversed() { // 倒叙交换位置
                if self.infos.count <= self.config.visibleCount {
                    if index == 0 { continue }
                } else {
                    if index == self.infos.count - 1 || index == 0 { continue }
                }
                let willInfo = self.infos[index - 1]
                
                let willTransform = willInfo.transform
                let willFrame = willInfo.frame
                
                info.transform = willTransform
                info.frame = willFrame
            }
                        
            guard let info = self.infos.first else { return }
            info.card.removeFromSuperview()
            self.infos.removeFirst()
            
            // 如果不是最后一张卡片移出去，则把索引+1
            if self.currentIndex < (self.dataSource?.numberOfCount(self) ?? 0) - 1 {
                self.currentIndex = self.currentIndex + 1
                self.infos.first?.card.isUserInteractionEnabled = true
            }
            // 卡片滑出去的回调
            self.delegate?.endDragCard(self, currentCard: info.card, withIndex: self.currentIndex, withMove: true)
        }
    }
    
    /// 默认是左边
    public func revoke() {
        if revoking { return }
        if currentIndex <= 0 { return }
        guard let topInfo = infos.first else { return }
        
        guard let data = self.dataSource?.dragCard(self, indexOfCard: currentIndex - 1) else { return }
        let info = WZSlideCardInfo(model: data)
        let card = info.card
        card.isUserInteractionEnabled = false
        topInfo.card.isUserInteractionEnabled = false
    
        card.transform = .identity
        card.frame = topInfo.frame
        card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(panGesture:))))
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(tapGesture:))))
        addSubview(card)
        infos.insert(info, at: 0)
        
        if config.removeDirection == .horizontal {
            let flag: CGFloat = -1.0
            card.transform = CGAffineTransform(rotationAngle: config.correctRemoveMaxAngleAndToRadius() * flag)
        } else {
            // 垂直方向不做处理
            card.transform = .identity
        }
        
        if config.removeDirection == .horizontal {
            let flag: CGFloat = -0.5
            let tmpWidth = UIScreen.main.bounds.size.width * flag
            let tmpHeight = self.initialFirstCardCenter.y - 20.0
            card.center = CGPoint(x: tmpWidth, y: tmpHeight)
        } else {
            let flag: CGFloat = -1.0
            let tmpWidth = self.initialFirstCardCenter.x
            let tmpHeight = UIScreen.main.bounds.size.height * flag
            card.center = CGPoint(x: tmpWidth, y: tmpHeight)
        }
        
        revoking = true
        UIView.animate(withDuration: 0.4, animations: {
            
            card.center = self.initialFirstCardCenter
            for (index, info) in self.infos.enumerated(){
                if index > self.stableInfos.count - 1  { continue }
                let willInfo = self.stableInfos[index]
                info.card.transform = willInfo.transform
                info.card.frame = willInfo.frame
                info.transform = willInfo.transform
                info.frame = willInfo.frame
            }
            
        }) { [weak self] (isFinish) in
            
            guard let self = self else { return }
            // 移除最底部的卡片
            if self.infos.count > self.config.visibleCount, let _bottomCard = self.infos.last?.card {
                _bottomCard.removeFromSuperview()
                self.infos.removeLast()
            }
            card.isUserInteractionEnabled = true
            self.currentIndex -= 1
            self.revoking = false
        }
    }
}
