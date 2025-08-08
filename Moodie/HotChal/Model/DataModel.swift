//
//  DataModel.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import Foundation

/// 챌린지 영상 모델
struct ChallengeVideo {
  let id: UUID?
  let thumbnailImage: String?
  let title: String?
  let uploader: String?
  let videoFilename: String?
  let mp4Filename: String?
  let category: String?
}

extension ChallengeVideo {
  init(coreDataObject: ChallengeVideoWithCoreData) {
    self.id = coreDataObject.id
    self.thumbnailImage = coreDataObject.thumbnailImage
    self.title = coreDataObject.title
    self.uploader = coreDataObject.uploader
    self.videoFilename = coreDataObject.videoFilename
    self.mp4Filename = coreDataObject.mp4Filename
    self.category = coreDataObject.category
  }
    var mp4FilenameWithoutExtension: String? {
        guard let mp4Filename = self.videoFilename else { return nil }
        return URL(fileURLWithPath: mp4Filename).deletingPathExtension().lastPathComponent
    }
}
