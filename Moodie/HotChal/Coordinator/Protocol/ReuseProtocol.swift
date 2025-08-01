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
  static var reuseIdentifier: String {
    get {
      return String(describing: Self.self)
    }
  }
}
