//
//  PageViewController.swift
//  SwipeableTabBar
//
//  Created by George Vashakidze on 7/11/19.
//  Copyright © 2019 Toptal. All rights reserved.
//

import Foundation
import UIKit

protocol PageViewControllerDelegate: class {
    func pageDidSwipe(to index: Int)
}

class PageViewController: UIPageViewController {
    
    weak var swipeDelegate: PageViewControllerDelegate?
    
    var pages = [UIViewController]()
    
    var prevIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
    }
    
    func selectPage(at index: Int) {
        self.setViewControllers(
            [self.pages[index]],
            direction: self.direction(for: index),
            animated: true,
            completion: nil
        )
        self.prevIndex = index
    }
    
    private func direction(for index: Int) -> UIPageViewController.NavigationDirection {
        return index > self.prevIndex ? .forward : .reverse
    }
    
}

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard pages.count > previousIndex else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return nil }
        guard pages.count > nextIndex else { return nil }
        
        return pages[nextIndex]
    }
    
}

extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard let currentPageIndex = self.viewControllers?.first?.view.tag else { return }
            self.prevIndex = currentPageIndex
            self.swipeDelegate?.pageDidSwipe(to: currentPageIndex)
        }
    }
    
}
