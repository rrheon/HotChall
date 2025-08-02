//
//  UIViewController+Ext.swift
//  HotChal
//
//  Created by 최용헌 on 8/1/25.
//

import UIKit

extension UIViewController {
  
  /// 네비게이션 바 색상 설정
  func setupNavigationController(largeTitle: Bool = true){
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = .backgroundColor
    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    
    navigationController?.navigationBar.standardAppearance = appearance
    navigationController?.navigationBar.scrollEdgeAppearance = appearance
    navigationController?.navigationBar.prefersLargeTitles = largeTitle
    navigationController?.navigationBar.backgroundColor = .backgroundColor
    navigationController?.navigationBar.tintColor = .appPink

  }
  
  /// 탭바컨트롤러 색상 설정 및 스크롤 시 색상변경 방지
  func setupTabBarControler(){
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithTransparentBackground()
    tabBarAppearance.backgroundColor = .backgroundColor

    tabBarController?.tabBar.isTranslucent = false
    tabBarController?.tabBar.standardAppearance = tabBarAppearance
    tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
    tabBarController?.tabBar.tintColor = .appPink
  }
  
  func setupBackButton(){
    let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
    backBarButtonItem.tintColor = .white  // 색상 변경
    self.navigationItem.backBarButtonItem = backBarButtonItem
  }
}
