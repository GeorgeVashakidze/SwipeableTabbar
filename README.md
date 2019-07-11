Swipeable UI Tabbar

iOS SDK
As you know, iOS SDK contains too many built in UI components. Buttons, containers, navigations, tabbed layouts, etc. 
All this basic components allow us to create all kind of basic structured UIs, but what happens if there is a need, where you have to build some behavior, which is by default not supported by iOS?

One of such cases is UITabbar, where you do not have ability to swipe between tabs, and also you do not have animations between tab switching.

Searching...
After searching a lot, I have found only one useful library on Github, which had many issues during running application. It is very easy to use, but buggy. 

The lib is under this link

Result
So, after thinking, searching a lot, I started implementing my own and I said to myself.
Hey, what if we use page view controller for swipe, and native tabbar. 
What if we group this two things together, handle page index whiling swiping or tapping on tabbar? 

And finally I found very very tricky solution.


Solution
Imagine, you have 3 tabbar items to be built, what automatically means you have 3 pages/controllers to be displayed per tab item.

In this case you will need to instantiate those 3 view controllers and also you will need 2 placeholder/empty view controllers for tabbar, to tell bar items, change their state when tab is pressed, or user wants to change tab index programmatically.

For this, lets deep into the xCode and write a couple classes, to see who these things are working.
An Example of Swipe between tabs






On these screenshots, you see the first tab bar item is blue, then user is swiping to the right, which is itself yellow, and the last screen shows the 3rd item is selected and whole page is displayed as yellow.

Programmatic use of Swipeable Tabbar

So, let’s dive into this feature and write an easy example of swipeable tabbar for iOS. First of all, we need to create a new project. 


The prerequisites needed for our project are basic: Xcode and Xcode build tools installed on your Mac.

To create a new project, open your Xcode application on your Mac and select "Create a new Xcode project," then name your project, and choose the type of application to be created. Simply select "Single View App" and press Next.


 On the next screen, as you can see there will be some info that you need to provide. 
 - Product Name: I named it SwipeableTabbar
 - Team. Here, if you want to run this application on a real device, you will have to have a developer account. In my case, I will use my own account for this. 
Note: If you do not have a developer account, you can run this on Simulator as well. 
- Organization Name: I named it Toptal 
- Organization Identifier: I named it "com.toptal"
- Language: Choose Swift 
- Uncheck "Use Core Data," "Include Unit Tests," and "Include UI Tests"

Press the Next button, and we are ready to start.

Simple architecture


As you already know, when you create a new app, you already have Main `ViewController` class and `Main.Storyboard`. 

Before we start designing something, let’s first create all the necessary classes and files to make sure we have everything set up and running to move to the UI part of the job.


Somewhere inside your project, simply create a new files -> "TabbarController.swift", “NavigationController.swift”, “PageViewController.swift”.
In my case, it looks like this.






In AppDelegate file, leave only `didFinishLaunchingWithOptions`, you can simply remove all other methods.

Inside `didFinishLaunchingWithOptions`, simply copy and paste lines from below.

window = UIWindow(frame: UIScreen.main.bounds)
window?.rootViewController = NavigationController(rootViewController: TabbarController())
window?.makeKeyAndVisible()

return true

Remove everything from file called  "ViewController.swift". We will get back to this file later.

First let’s write code for "NavigationController.swift".


import Foundation
import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .gray
    }
}

Here I’ve just created simple UINavigationController, where we have translucent bar with gray TintColor.

That’s all here.

Now we can move to `PageViewController`.

Here, we need to code a little bit more, then in the previous file.

This file contains one class, one protocol and some UIPageViewController datasource and delegate methods.

The file needs to look like this

 

As you can see, we have declared our own protocol called “PageViewControllerDelegate”, which should tell tabbar controller, that page index was changed after swipe is handled.


import Foundation
import UIKit

protocol PageViewControllerDelegate: class {
    func pageDidSwipe(to index: Int)
}


Then we need to create a new class, called “PageViewController”, which will hold our view controllers, select pages at specific index and also will handle swipes.

Let’s imagine first selected controller on first run should be center view controller, in this case we assign our default index value, equal to 1.




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

As you can see here, we have variable pages, which will contain references of all our view controllers.

A variable prevIndex, is used to store last selected index

You can simply call selectPage method, in order to set selected index 

If you want to listen page index changes, you have to subscribe to swipeDelegate, and on each page swipe, you will be notified, that page index changed and you also will receive current index.

The method direction, will return swipe direction of UIPageViewController
Last part in this class, are delegate/datasource implementation

These implementations are very simple.

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




As you can see above there are 3 methods.

The first one finds the index and returns previous view controller

The second one finds the index and returns next view controller

The last one finds, if swipe was ended, settings current index and calls delegate method, to notify parent view controller that swipe was done successfully.


Now we can write UITabbar Implementation


import UIKit

class TabbarController: UITabBarController {
    
    let selectedColor = UIColor.blue
    let deselectedColor = UIColor.gray
    
    let tabBarImages = [
        UIImage(named: "ic_music")!,
        UIImage(named: "ic_play")!,
        UIImage(named: "ic_star")!
    ]
    
    override func viewDidLoad() {
        
        view.backgroundColor = .gray
        
        self.delegate = self
        tabBar.isTranslucent = true
        tabBar.tintColor = deselectedColor
        tabBar.unselectedItemTintColor = deselectedColor
        tabBar.barTintColor = UIColor.white.withAlphaComponent(0.92)
        tabBar.itemSpacing = 10.0
        tabBar.itemWidth = 76.0
        tabBar.itemPositioning = .centered
        
        setUp()
        
        self.selectPage(at: 1)
    }
    
}
As you can see, we create TabbarController, with default properties and style.

We need to define two colors, for selected and deselected bar items.

Also, I’ve introduced 3 images for tabbar items.

In viewDidLoad, I just setting up default configuration of tabbar and selecting page #1, 
What means, startup page will be page number 1


    private func setUp() {
        
        guard let centerPageViewController = createCenterPageViewController() else { return }
        
        var controllers: [UIViewController] = []
        
        controllers.append(createPlaceholderViewController(forIndex: 0))
        controllers.append(centerPageViewController)
        controllers.append(createPlaceholderViewController(forIndex: 2))
        
        setViewControllers(controllers, animated: false)
        
        selectedViewController = centerPageViewController
    }
    
    private func selectPage(at index: Int) {
        guard let viewController = self.viewControllers?[index] else { return }
        self.handleTabbarItemChange(viewController: viewController)
        guard let PageViewController = (self.viewControllers?[1] as? PageViewController) else { return }
        PageViewController.selectPage(at: index)
    }
    



Inside setUp method, you see that we create two placeholder view controllers.
These two view controllers will take place as a missing controllers for UI tabbar pages. As you remember we use UIPageViewController in order to display controllers, but for UITabbar, to make it fully workable, we need do have all view controllers instantiated, so that bar items will work, when you tap on it. So, in this example placeholderviewcontroller #0 and #2 are empty view controllers. 

As a centered view controller, we create PageViewController with 3 view controllers.

    private func createPlaceholderViewController(forIndex index: Int) -> UIViewController {
        let emptyViewController = UIViewController()
        emptyViewController.tabBarItem = tabbarItem(at: index)
        emptyViewController.view.tag = index
        return emptyViewController
    }
    
    private func createCenterPageViewController() -> UIPageViewController? {
        
        let leftController = ViewController()
        let centerController = ViewController2()
        let rightController = ViewController3()
        
        leftController.view.tag = 0
        centerController.view.tag = 1
        rightController.view.tag = 2
        
        leftController.view.backgroundColor = .red
        centerController.view.backgroundColor = .blue
        rightController.view.backgroundColor = .yellow
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        guard let pageViewController = storyBoard.instantiateViewController(withIdentifier: "PageViewController") as? PageViewController else { return nil }
        
        pageViewController.pages = [leftController, centerController, rightController]
        pageViewController.tabBarItem = tabbarItem(at: 1)
        pageViewController.view.tag = 1
        pageViewController.swipeDelegate = self
        
        return pageViewController
    }
    
    private func tabbarItem(at index: Int) -> UITabBarItem {
        return UITabBarItem(title: nil, image: self.tabBarImages[index], selectedImage: nil)
    }



The 1st and 2nd methods above are init methods of pageview controller.

The method tabbar item, just returns tabbar item at index.


Inside method createCenterPageViewController(), as you can see I am using tags for each view controller. This is helping me to understand which controller is appeared on the screen.

Next and most important method, is handleTabbarItemChange.


    private func handleTabbarItemChange(viewController: UIViewController) {
        guard let viewControllers = self.viewControllers else { return }
        let selectedIndex = viewController.view.tag
        self.tabBar.tintColor = selectedColor
        self.tabBar.unselectedItemTintColor = selectedColor
        
        for i in 0..<viewControllers.count {
            let tabbarItem = viewControllers[i].tabBarItem
            let tabbarImage = self.tabBarImages[i]
            tabbarItem?.selectedImage = tabbarImage.withRenderingMode(.alwaysTemplate)
            tabbarItem?.image = tabbarImage.withRenderingMode(
                i == selectedIndex ? .alwaysOriginal : .alwaysTemplate
            )
        }
        
        if selectedIndex == 1 {
            viewControllers[selectedIndex].tabBarItem.selectedImage = self.tabBarImages[1].withRenderingMode(.alwaysOriginal)
        }
    }




In this method, I am getting view controller as a parameter.
From this view controller I get tag as a selected index.

For tabbar we need to set selected and unselected colors.

Now we need to loop through all controllers and check, if i == selectedIndex 
Then we need to render image as an original rendering mode, else we need to render image as a template mode.

When you render image with template mode, it will take color from item’s tint color.


We are almost done.

We just need to introduce two important methods from UITabBarControllerDelegate and PageViewControllerDelegate.


    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.selectPage(at: viewController.view.tag)
        return false
    }
    
    func pageDidSwipe(to index: Int) {
        guard let viewController = self.viewControllers?[index] else { return }
        self.handleTabbarItemChange(viewController: viewController)
    }



First one is could when you press on any tab item

The second one is called, when you swipe between tabs.




