//
//  ReuseProtocol.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import Foundation

protocol ReuseIdentifiable {
  static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
  
  /// 현재 타입의 이름을 문자열로 반환
  /// ex) CustomCell.reuseIdentifier -> "CustomCell"
  static var reuseIdentifier: String {
    get {
      return String(describing: Self.self)
    }
  }
}
