//
//  TabBarController.swift
//
//
//

import UIKit

class TabBarController: UITabBarController {
    
    private enum Tab: Int {
        
        case TakePhoto
        case Feeds
        case Discover
        case Profile
        
        var title: String {
            
            switch self {
            case .TakePhoto:
                return NSLocalizedString("Photo", comment: "")
            case .Feeds:
                return NSLocalizedString("Feeds", comment: "")
            case .Discover:
                return NSLocalizedString("Discover", comment: "")
            case .Profile:
                return NSLocalizedString("Profile", comment: "")
            }
        }
    }
    
    private var previousTab = Tab.Discover
    
    private var checkDoubleTapOnFeedsTimer: NSTimer?
    private var hasFirstTapOnFeedsWhenItIsAtTop = false {
        willSet {
            if newValue {
                let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkDoubleTapOnFeeds:", userInfo: nil, repeats: false)
                checkDoubleTapOnFeedsTimer = timer
                
            } else {
                checkDoubleTapOnFeedsTimer?.invalidate()
            }
        }
    }
    
    @objc private func checkDoubleTapOnFeeds(timer: NSTimer) {
        
        hasFirstTapOnFeedsWhenItIsAtTop = false
    }
    
    private struct Listener {
        static let lauchStyle = "TabBarController.lauchStyle"
    }
    
    deinit {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.lauchStyle.removeListenerWithName(Listener.lauchStyle)
        }
        
        println("deinit TabBar")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        view.backgroundColor = UIColor.whiteColor()
        
        // 将 UITabBarItem 的 image 下移一些，也不显示 title 了
        /*
         if let items = tabBar.items as? [UITabBarItem] {
         for item in items {
         item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
         item.title = nil
         }
         }
         */
        
        // Set Titles
        
        if let items = tabBar.items {
            for i in 0..<items.count {
                let item = items[i]
                item.title = Tab(rawValue: i)?.title
            }
        }
        
        // 处理启动切换
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.lauchStyle.bindListener(Listener.lauchStyle) { [weak self] style in
                if style == .Message {
                    self?.selectedIndex = 0
                }
            }
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        guard
            let tab = Tab(rawValue: selectedIndex),
            let nvc = viewController as? UINavigationController else {
                return false
        }
        
        if tab != previousTab {
            return true
        }
        
        
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        guard
            let tab = Tab(rawValue: selectedIndex),
            let nvc = viewController as? UINavigationController else {
                return
        }
        
        // 不相等才继续，确保第一次 tap 不做事
        
        if tab != previousTab {
            previousTab = tab
            return
        }
        
        switch tab {
            
        case .TakePhoto:
            if let vc = nvc.topViewController as? TakePhotoViewController {
                if !vc.conversationsTableView.yep_isAtTop {
                    vc.conversationsTableView.yep_scrollsToTop()
                }
            }
            
        case .Feeds:
            if let vc = nvc.topViewController as? FeedsViewController {
                if !vc.feedsTableView.yep_isAtTop {
                    vc.feedsTableView.yep_scrollsToTop()
                    
                } else {
                    if !vc.feeds.isEmpty && !vc.pullToRefreshView.isRefreshing {
                        vc.feedsTableView.setContentOffset(CGPoint(x: 0, y: -150), animated: true)
                        hasFirstTapOnFeedsWhenItIsAtTop = false
                    }
                }
            }
            
        case .Discover:
            if let vc = nvc.topViewController as? DiscoverViewController {
                if !vc.discoveredUsersCollectionView.yep_isAtTop {
                    vc.discoveredUsersCollectionView.yep_scrollsToTop()
                }
            }
            
        case .Profile:
            if let vc = nvc.topViewController as? ProfileViewController {
                if !vc.profileCollectionView.yep_isAtTop {
                    vc.profileCollectionView.yep_scrollsToTop()
                }
            }
        }
        }
}

