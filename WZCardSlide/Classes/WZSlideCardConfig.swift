//
//  WZSlideCardConfig.swift
//  WZCardSlide_Example
//
//  Created by qiuqixiang on 2020/3/24.
//  Copyright © 2020 CocoaPods. All rights reserved.
//  改移动卡片基础配置

import UIKit
import Foundation

// MARK - 改移动卡片基础配置
public class WZSlideCardConfig {
    
    /// 卡片方向
    public enum Direction {
        case `default`   // default
        case left        // 向左
        case right       // 向右
        case up          // 向上
        case down        // 向下
    }
    
    /// 横屏竖屏
    public enum WZSlideCardRemoveDirection {
        case horizontal
        case vertical
    }
    
    /// 显示样式
    public enum WZSlideCardShowType {
        case pile        // 堆叠
        case full        // 满屏
    }
    
    /// 当前列表显示的样式
    public var cardShowType: WZSlideCardShowType = .pile
    
    /// 可见卡片数量，默认3
    /// 取值范围:大于0
    /// 内部会根据`visibleCount`和`numberOfCount(_ dragCard: YHDragCard)`来纠正初始显示的卡片数量
    public var visibleCount: Int = 3
    
    /// 卡片之间的间隙，默认10.0
    /// 如果小于0.0，默认0.0
    /// 如果大于容器高度的一半，默认为容器高度一半
    public var cardSpacing: CGFloat = 10.0
    
    /// 最底部那张卡片的缩放比例，默认0.8
    /// 其余卡片的缩放比例会进行自动计算
    /// 取值范围:0.1 - 1.0
    /// 如果小于0.1，默认0.1
    /// 如果大于1.0，默认1.0
    public var minScale: CGFloat = 0.8
    
    /// 移除方向(一般情况下是水平方向移除的，但是有些设计是垂直方向移除的)
    /// 默认水平方向
    public var removeDirection: WZSlideCardRemoveDirection = .horizontal
    
    /// 水平方向上最大移除距离，默认屏幕宽度1/4
    /// 取值范围:大于10.0
    /// 如果小于10.0，默认10.0
    /// 如果水平方向上能够移除卡片，请设置该属性的值
    public var horizontalRemoveDistance: CGFloat = UIScreen.main.bounds.size.width / 4.0
    
    /// 水平方向上最大移除速度，默认1000.0
    /// 取值范围:大于100.0。如果小于100.0，默认100.0
    /// 如果水平方向上能够移除卡片，请设置该属性的值
    public var horizontalRemoveVelocity: CGFloat = 1000.0
    
    /// 垂直方向上最大移除距离，默认屏幕高度1/4
    /// 取值范围:大于50.0
    /// 如果小于50.0，默认50.0
    /// 如果垂直方向上能够移除卡片，请设置该属性的值
    public var verticalRemoveDistance: CGFloat = UIScreen.main.bounds.size.height / 4.0
    
    /// 垂直方向上最大移除速度，默认500.0
    /// 取值范围:大于100.0。如果小于100.0，默认100.0
    /// 如果垂直方向上能够移除卡片，请设置该属性的值
    public var verticalRemoveVelocity: CGFloat = 500.0
    
    /// 侧滑角度，默认10.0度(最大会旋转10.0度)
    /// 取值范围:0.0 - 90.0
    /// 如果小于0.0，默认0.0
    /// 如果大于90.0，默认90.0
    /// 当`removeDirection`设置为`vertical`时，会忽略该属性
    /// 在滑动过程中会根据`horizontalRemoveDistance`和`removeMaxAngle`来动态计算卡片的旋转角度
    /// 目前我还没有遇到过在垂直方向上能移除卡片的App，因此如果上下滑动，卡片的旋转效果很小，只有在水平方向上滑动，才能观察到很明显的旋转效果
    public var removeMaxAngle: CGFloat = 10.0
    
    /// 卡片滑动方向和纵轴之间的角度，默认5.0
    /// 取值范围:5.0 - 85.0
    /// 如果小于5.0，默认5.0
    /// 如果大于85.0，默认85.0
    /// 如果水平方向滑动能移除卡片，请把该值设置的尽量小
    /// 如果垂直方向能够移除卡片，请把该值设置的大点
    public var demarcationAngle: CGFloat = 5.0
    
    /// 是否无限滑动
    public var infiniteLoop: Bool = false
}

// MARK - 纠正基础配置
extension WZSlideCardConfig {
    
    /// 纠正minScale   [0.1, 1.0]
        public func correctScale() -> CGFloat {
            var scale = self.minScale
            if scale > 1.0 { scale = 1.0 }
            if scale <= 0.1 { scale = 0.1 }
            return scale
        }

        /// 纠正侧滑角度，并把侧滑角度转换为弧度  [0.0, 90.0]
        func correctRemoveMaxAngleAndToRadius() -> CGFloat {
    //        var angle: CGFloat = removeMaxAngle
            var angle: CGFloat = 10
            if angle < 0.0 {
                angle = 0.0
            } else if angle > 90.0 {
                angle = 90.0
            }
            
            let xxx = angle / -180.0 * CGFloat(Double.pi)
            
            return xxx
        }
        
        /// 纠正水平方向上的最大移除距离，内部做了判断 [10.0, ∞)
        func correctHorizontalRemoveDistance() -> CGFloat {
            return horizontalRemoveDistance < 10.0 ? 10.0 : horizontalRemoveDistance
        }
        
        /// 纠正水平方向上的最大移除速度  [100.0, ∞)
        func correctHorizontalRemoveVelocity() -> CGFloat {
            return horizontalRemoveVelocity < 100.0 ? 100.0 : horizontalRemoveVelocity
        }
        
        /// 纠正垂直方向上的最大移距离  [50.0, ∞)
        func correctVerticalRemoveDistance() -> CGFloat {
            return verticalRemoveDistance < 50.0 ? 50.0 : verticalRemoveDistance
        }
        
        /// 纠正垂直方向上的最大移除速度  [100.0, ∞)
        func correctVerticalRemoveVelocity() -> CGFloat {
            return verticalRemoveVelocity < 100.0 ? 100.0 : verticalRemoveVelocity
        }
        
        /// 纠正卡片滑动方向和纵轴之间的角度，并且转换为弧度   [5.0, 85.0]
        func correctDemarcationAngle() -> CGFloat {
            var angle = demarcationAngle
            if demarcationAngle < 5.0 {
                angle = 5.0
            } else if demarcationAngle > 85.0 {
                angle = 85.0
            }
            return angle / 180.0 * CGFloat(Double.pi)
        }
}
