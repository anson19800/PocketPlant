//
//  ProfilePageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/29.
//

import UIKit

class ProfilePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let animationView = loadAnimation(name: "16957-comming-soon", loopMode: .autoReverse)
        animationView.play()
    }
}
