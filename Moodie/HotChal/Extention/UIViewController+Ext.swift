//
//  UIViewController+Ext.swift
//  HotChal
//
//  Created by 최용헌 on 8/1/25.
//

import UIKit

extension UIViewController {
  

  
  func setupBackButton(){
    let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
    backBarButtonItem.tintColor = .white  // 색상 변경
    self.navigationItem.backBarButtonItem = backBarButtonItem
  }
}
