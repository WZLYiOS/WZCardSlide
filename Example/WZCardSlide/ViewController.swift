//
//  ViewController.swift
//  WZCardSlide
//
//  Created by ppqx on 03/23/2020.
//  Copyright (c) 2020 ppqx. All rights reserved.
//

import UIKit
import SnapKit
import WZCardSlide

class ViewController: UIViewController {

    /// stackSwipeView
    private lazy var stackSwipeView: SwipeCardStack = {
        $0.cardStackInsets = UIEdgeInsets.zero
        $0.delegate = self
        $0.dataSource = self
        $0.numberOfVisibleCards = 2
//        $0.transformProvider = CustomCardStackTransformProvider()
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(SwipeCardStack())
    
    var list: [String] = ["1","2","3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        configViewLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 添加视图
    func configView() {
        view.addSubview(stackSwipeView)
    }
    
    /// 视图位置
    func configViewLocation() {
        stackSwipeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(UIApplication.shared.statusBarFrame.size.height+10)
            make.bottom.equalTo(-80)
        }
    }

}

/// MARK - SwipeCardStackDataSource
extension ViewController: SwipeCardStackDataSource {
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return list.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
     
        let view = HomeUserDetailsView()
        view.buider(text: "\(index)")
        return view
    }
}

/// MARK - SwipeCardStackDelegate
extension ViewController: SwipeCardStackDelegate {
    func cardStackDidBeginAnimating(_ cardStack: WZCardSlide.SwipeCardStack, didSelectCardAt index: Int) {
        
    }
    
    func didSwipeAllCards(_ cardStack: WZCardSlide.SwipeCardStack) {
        
    }
    
    func cardStackDidEndAnimating(_ cardStack: WZCardSlide.SwipeCardStack) {
        
    }
    
    func cardStack(_ cardStack: WZCardSlide.SwipeCardStack, didSelectCardAt index: Int) {
        
    }
    
    func cardStack(_ cardStack: WZCardSlide.SwipeCardStack, didSwipeCardAt index: Int, with direction: WZCardSlide.SwipeDirection) {
       
        
        /// 提前2条开始加载数据
        if list.count - (index + 1) <= 2  {
            let startIndex = self.list.count
            let endIndex = 1 + startIndex
            self.list.append(contentsOf: ["\(index+1)"])
            self.stackSwipeView.appendCards(atIndices: (startIndex..<endIndex).map { $0 })
        }
    }
    
    func cardStack(_ cardStack: WZCardSlide.SwipeCardStack, didUndoCardAt index: Int, from direction: WZCardSlide.SwipeDirection) {
        
    }
    
    func cardStackIsCanMove(_ cardStack: WZCardSlide.SwipeCardStack, didSwipeCardAt index: Int) -> Bool {
        return index == 2 ? false : true
    }
}

// MARK - 卡片视图
class HomeUserDetailsView: SwipeCard {
    
    ///
    private lazy var textLabel: UILabel = {
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
        configViewLocation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 添加视图
    func configView() {
        addSubview(textLabel)
    }
    
    /// 视图位置
    func configViewLocation() {
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func buider(text: String) {
        textLabel.text = text
        
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
