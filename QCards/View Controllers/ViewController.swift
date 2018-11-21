//
//  ViewController.swift
//  QCards
//
//  Created by Andreas Lüdemann on 20/11/2018.
//  Copyright © 2018 Andreas Lüdemann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let myLabel: UILabel = {
        let label = UILabel()
        label.text = "QCards"
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(myLabel)
        
        myLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "QCards"

        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleAddDeck))
    }
    
    @objc func handleAddDeck() {
        print("hello")
    }
}
