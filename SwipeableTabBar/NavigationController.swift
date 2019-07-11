//
//  NavigationController.swift
//  SwipeableTabBar
//
//  Created by George Vashakidze on 7/11/19.
//  Copyright © 2019 Toptal. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .gray
    }
}
