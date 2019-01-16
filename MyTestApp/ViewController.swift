//
//  ViewController.swift
//  MyTestApp
//
//  Created by yxliu on 2018/11/6.
//  Copyright © 2018 cusc. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit

class ViewController: UIViewController {
    
    var searchController = UISearchController()
    
    var tableView = UITableView()
    
    var dataSource = [String]()
    
    var searchSource = [String]()
    
    var resultController: ResultViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        print(Environment.apiKey)
//        print(Environment.rootURL.absoluteString)
        
        automaticallyAdjustsScrollViewInsets = true
        navigationController?.navigationBar.isTranslucent = false
        
        for index in 0..<100 {
            dataSource.append("\(index)")
        }
        
        let topView = UIView(frame: .zero)
        topView.backgroundColor = .red
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(view)
            make.height.equalTo(250)
        }
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(view)
            make.top.equalTo(topView.snp.bottom)
        }
        
        resultController = ResultViewController()
        resultController.tableView.delegate = self
        resultController.tableView.dataSource = self
        resultController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        searchController = UISearchController(searchResultsController: resultController)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = true
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
        searchController.hidesNavigationBarDuringPresentation = true
        
        searchController.searchBar.sizeToFit()
        
        searchController.searchBar.setValue("取消", forKey: "_cancelButtonText")
        
        let searchBar = searchController.searchBar
        
        searchController.searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBar.frame.origin.y, width: searchBar.frame.size.width, height: 44)
        
        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true
        
//        tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.size.height)
        
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultController.tableView {
            return searchSource.count
        } else {
            return dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        var text = ""
        if tableView == resultController.tableView {
            text = searchSource[indexPath.row]
        } else {
            text = dataSource[indexPath.row]
        }
        cell.textLabel?.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UISearchControllerDelegate {
    
}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchString = searchController.searchBar.text {
            let predicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchString)
            
            if searchSource.count > 0 {
                searchSource.removeAll()
            }
            
            searchSource = dataSource.filter { predicate.evaluate(with: $0 )
            }
            
            resultController.tableView.reloadData()
        }
        
        
    }
    
    
}
