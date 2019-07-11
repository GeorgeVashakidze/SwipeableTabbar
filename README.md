# SwipeableTabbar
iOS SDK As you know, iOS SDK contains too many built in UI components. Buttons, containers, navigations, tabbed layouts, etc.  All this basic components allow us to create all kind of basic structured UIs, but what happens if there is a need, where you have to build some behavior, which is by default not supported by iOS?  One of such cases is UITabbar, where you do not have ability to swipe between tabs, and also you do not have animations between tab switching.  Searching... After searching a lot, I have found only one useful library on Github, which had many issues during running application. It is very easy to use, but buggy.   The lib is under this link  Result So, after thinking, searching a lot, I started implementing my own and I said to myself. Hey, what if we use page view controller for swipe, and native tabbar.  What if we group this two things together, handle page index whiling swiping or tapping on tabbar?   And finally I found very very tricky solution.
