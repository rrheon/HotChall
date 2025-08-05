//
//  ChallengeDataWithCoreData+CoreDataProperties.swift
//  HotChal
//
//  Created by 최용헌 on 8/4/25.
//

import Foundation
import CoreData

extension ChallengeVideoWithCoreData {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<ChallengeVideoWithCoreData> {
      return NSFetchRequest<ChallengeVideoWithCoreData>(entityName: "ChallengeVideoWithCoreData")
  }
  
  @NSManaged public var id: UUID
  @NSManaged public var category: String?
  @NSManaged public var mp4Filename: String?
  @NSManaged public var thumbnailImage: String?
  @NSManaged public var title: String?
  @NSManaged public var uploader: String?
  @NSManaged public var videoFilename: String?

}
