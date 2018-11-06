//
//  ViewController.swift
//  MyTestApp
//
//  Created by yxliu on 2018/11/6.
//  Copyright © 2018 cusc. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(Environment.apiKey)
        print(Environment.rootURL.absoluteString)
        
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50));
        label.backgroundColor = .white
        label.textColor = .black;
        label.text = Environment.rootURL.absoluteString
        view.addSubview(label)
        
    }


}

