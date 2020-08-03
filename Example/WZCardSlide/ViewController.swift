//
//  ViewController.swift
//  WZCardSlide
//
//  Created by ppqx on 03/23/2020.
//  Copyright (c) 2020 ppqx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var models: [String] = ["堆叠样式","全屏样式"]
    
    /// 列表
    private lazy var tableView: UITableView = {
        $0.dataSource = self
        $0.delegate = self
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return $0
    }(UITableView(frame: self.view.bounds))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view, typically from a nib.
        view.isUserInteractionEnabled = true
        view.addSubview(tableView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

}

extension ViewController: UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TestViewController()
        vc.viewType = indexPath.row == 0 ? .pile : .full
        self.present(vc, animated: true, completion: nil)
    }
}
