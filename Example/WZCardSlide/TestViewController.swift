//
//  TestViewController.swift
//  WZCardSlide_Example
//
//  Created by qiuqixiang on 2020/3/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WZCardSlide

final class TestViewController: UIViewController {

    var models: [String] = ["水星","金星",
    "地球",
    "火星",
    "木星"]
    
   public var viewType: WZSlideCardConfig.WZSlideCardShowType = .pile

    private lazy var card: WZSlideCardView = {
        let card = WZSlideCardView()
        card.frame = CGRect(x: 50, y: UIApplication.shared.statusBarFrame.size.height + 44.0 + 40.0, width: self.view.frame.size.width - 100 , height: 400)
        card.dataSource = self
        card.delegate = self
        card.config.minScale = 0.9
        card.config.removeDirection = .horizontal
        card.config.cardShowType = viewType
        card.config.visibleCount = viewType == .pile ? 3 : 2
        card.backgroundColor = UIColor.red
        return card
    }()
    
    private lazy var cheHuiLabel: UILabel = {
        $0.text = "撤回"
        $0.backgroundColor = UIColor.orange
        $0.frame = CGRect(x: 20, y: 550, width: 100, height: 30)
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cheHuiLabelAction)))
        return $0
    }(UILabel())
    
    private lazy var backLabel: UILabel = {
        $0.text = "返回上页"
        $0.backgroundColor = UIColor.orange
        $0.frame = CGRect(x: self.view.bounds.size.width-100, y: 550, width: 100, height: 30)
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backLabelAction)))
        return $0
    }(UILabel())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(self.card)
        self.card.reloadData(animation: false)
        view.addSubview(cheHuiLabel)
        view.addSubview(backLabel)
    }
    

     @objc func cheHuiLabelAction(tap: UITapGestureRecognizer) {
            self.card.revoke()
    }
    
    @objc func backLabelAction(tap: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TestViewController: WZSlideCardDataSource {
    func numberOfCount(_ dragCard: WZSlideCardView) -> Int {
        return self.models.count
    }
    
    func dragCard(_ dragCard: WZSlideCardView, indexOfCard index: Int) -> WZSlideCardViewProtocol {
        let label = UILabel()
        label.text = "\(index) -- \(self.models[index])"
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.textAlignment = .center
        label.backgroundColor = .orange
        label.layer.cornerRadius = 5.0
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.masksToBounds = true
        return label
    }
}

extension TestViewController: WZSlideCardDelegate {
    func beganDragCard(_ dragCard: WZSlideCardView, currentCard card: UIView, withIndex index: Int) {
        
    }
    
    func endDragCard(_ dragCard: WZSlideCardView, currentCard card: UIView, withIndex index: Int, withMove isMove: Bool) {
        
    }
    
    func dragCard(_ dragCard: WZSlideCardView, didSelectIndexAt index: Int, with card: WZSlideCardViewProtocol) {
        
    }
    
    func dragCard(_ dragCard: WZSlideCardView, didRemoveCard card: WZSlideCardViewProtocol, withIndex index: Int) {
    }
    
    func dragCard(_ dragCard: WZSlideCardView, currentCard card: UIView, withIndex index: Int, withCenterY y: CGFloat, withCenterX X: CGFloat) {
        
    }
}

extension UILabel: WZSlideCardViewProtocol {
    public func getContentView() -> UIView {
        return self
    }
    
    public var isEmptyView: Bool {
        return false
    }
}

class emptyView: UIView, WZSlideCardViewProtocol {
    public func getContentView() -> UIView {
        return self
    }
    
    public var isEmptyView: Bool {
        return true
    }
}
