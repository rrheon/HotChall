//
//  GetKeyWindowProtocol.swift
//  HotChal
//
//  Created by 최용헌 on 8/8/25.
//

import UIKit


/// 활성화된 Key Window 가져오기
protocol GetKeyWindowProtocol {
  func getKeyWindow() -> UIWindow? 
}

extension GetKeyWindowProtocol {
  func getKeyWindow() -> UIWindow? {
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }
  
}
