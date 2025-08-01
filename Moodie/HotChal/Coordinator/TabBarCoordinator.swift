//
//  TabBarCoordinator.swift
//  HotChal
//
//  Created by heojiwoo on 7/29/25.
//

import UIKit

enum TabBarPage {
    case home, learn, favorites

    init?(index: Int) {
        switch index {
        case 0:
            self = .home
        case 1:
            self = .learn
        case 2:
            self = .favorites
        default:
            return nil
        }
    }
    
    func pageTitleValue() -> String {
        switch self {
        case .home:
            return "인기차트"
        case .learn:
            return "핫한 챌린지 배우기"
        case .favorites:
            return "보관함"
        }
    }

    func pageOrderNumber() -> Int {
        switch self {
        case .home:
            return 0
        case .learn:
            return 1
        case .favorites:
            return 2
        }
    }
    
    func tabIcon() -> UIImage? {
           switch self {
           case .home:
               return UIImage(systemName: "star.fill")
           case .learn:
               return UIImage(systemName: "star.fill")
           case .favorites:
               return UIImage(systemName: "star.fill")
           }
       }
}


protocol TabCoordinatorProtocol: Coordinator {
    var tabBarController: UITabBarController { get set }
    
    func selectPage(_ page: TabBarPage)
    
    func setSelectedIndex(_ index: Int)
    
    func currentPage() -> TabBarPage?
}

class TabCoordinator: NSObject, Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
        
    var childCoordinators: [Coordinator] = []

    var navigationController: UINavigationController
    
    var tabBarController: UITabBarController

    var type: CoordinatorType { .tab }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = .init()
    }

    func start() {
        let pages: [TabBarPage] = [.home, .learn, .favorites]
            .sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
        
        let controllers: [UINavigationController] = pages.map({ getTabController($0) })
        
        prepareTabBarController(withTabControllers: controllers)
    }
    
    deinit {
        print("TabCoordinator deinit")
    }
    
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        tabBarController.delegate = self
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = TabBarPage.home.pageOrderNumber()
    
        tabBarController.tabBar.isTranslucent = false
        
        navigationController.viewControllers = [tabBarController]
    }
      
    private func getTabController(_ page: TabBarPage) -> UINavigationController {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(false, animated: false)

        navController.tabBarItem = UITabBarItem.init(title: page.pageTitleValue(),
                                                     image: page.tabIcon(),
                                                     tag: page.pageOrderNumber())

        switch page {
        case .home:
            let chalCoordinator = ChalCoordinator(navController)
            chalCoordinator.start()
            childCoordinators.append(chalCoordinator)
            
        case .learn:
            let learnViewController = LearnViewController()
            learnViewController.didSendEventClosure = { [weak self] event in
                switch event {
                case .learnViewControllerTwo:
                    print("Learn!")
                }
            }
            navController.pushViewController(learnViewController, animated: true)
        case .favorites:
            let favoriteCoordinator = FavoriteCoordinator(navController)
            favoriteCoordinator.start()
            childCoordinators.append(favoriteCoordinator)
        }
        
        return navController
    }
    
    func currentPage() -> TabBarPage? { TabBarPage.init(index: tabBarController.selectedIndex) }

    func selectPage(_ page: TabBarPage) {
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPage.init(index: index) else { return }
        
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
}

// MARK: - UITabBarControllerDelegate
extension TabCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        // Some implementation
    }
}

