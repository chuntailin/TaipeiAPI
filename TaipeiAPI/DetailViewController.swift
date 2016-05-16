//
//  DetailViewController.swift
//  TaipeiAPI
//
//  Created by Chun Tie Lin on 2016/5/14.
//  Copyright © 2016年 ChunTaiLin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    var acceptCityName: String!
    var acceptAddress: String!
    var acceptUnit: String!
    var acceptStartDate: String!
    var acceptEndDate: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        self.addNavigationBar()
        self.assignValue()
    }
    
    func addNavigationBar() {
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        navigationBar.barTintColor = UIColor(red: 94/255, green: 134/255, blue: 193/255, alpha: 1)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "施工資訊"
        
        let leftButton =  UIBarButtonItem(title: "< back", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailViewController.btnClicked(_:)))
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        
        self.view.addSubview(navigationBar)
        
    }
    
    func btnClicked(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func assignValue() {
        
        self.cityNameLabel.text = acceptCityName
        self.addressLabel.text = acceptAddress
        self.unitLabel.text = acceptUnit
        self.startDateLabel.text = acceptStartDate
        self.endDateLabel.text = acceptEndDate
        
    }
}
