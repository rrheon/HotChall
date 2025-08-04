//
//  CoreDataManager.swift
//  HotChal
//
//  Created by 최용헌 on 8/4/25.
//

import UIKit

import CoreData


/// 코어데이터 매니저
final class CoreDataManager {
  static let shared = CoreDataManager()
  
  
  /// 저장된 챌린지 리스트
  private var savedChallengeList: [ChallengeVideo] = []
  
  private init (){
    self.fetchSavedChallengeList()
  }
  
  // AppDelegate 내부에 있는 ViewContext 호출
  private let context: NSManagedObjectContext? = {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      print("AppDelegate가 초기화되지 않았습니다.")
      return nil
    }
    return appDelegate.persistentContainer.viewContext
  }()
  
  // 엔터티 이름
  let modelName: String = "ChallengeVideoWithCoreData"

  // 저장된 챌린지 리스트 가져오기
  func getSavedChallengeList() -> [ChallengeVideo]{
    return savedChallengeList
  }
  
  /// 코어데이터에 저장된 데이터 모두 읽어오기
  func fetchSavedChallengeList(){
    guard let context = context else { return }
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: modelName)
    
    do {
      guard let challengeList = try context.fetch(fetchRequest) as? [ChallengeVideoWithCoreData] else { return }
      let convertedList = challengeList.map { ChallengeVideo(coreDataObject: $0) }
      savedChallengeList = convertedList

    }catch {
      print("err: \(error.localizedDescription)")
    }
  }
  
  /// 코어데이터에 데이터 생성
  func saveChallenge(with data: ChallengeVideo, completion: @escaping (Bool) -> Void) {
    let savedList = CoreDataManager.shared.getSavedChallengeList()
    
    // 중복 여부 확인 (예: uuid가 같으면 중복)
    guard !savedList.contains(where: { $0.title == data.title && $0.uploader == $0.uploader }) else {
      print("중복된 챌린지입니다.")
      completion(false)
      return 
    }
    
    if let context = context,
        let entity = NSEntityDescription.entity(forEntityName: self.modelName, in: context) {
      let challenge = ChallengeVideoWithCoreData(entity: entity, insertInto: context)
      challenge.id = UUID()
      challenge.category = data.category
      challenge.mp4Filename = data.mp4Filename
      challenge.thumbnailImage = data.thumbnailImage
      challenge.title = data.title
      challenge.uploader = data.uploader
      challenge.videoFilename = data.videoFilename

      do {
        try context.save()
        print(challenge)
        CoreDataManager.shared.fetchSavedChallengeList()

        completion(true)
      } catch {
        print(error)
      }
    }
  }

  /// 코어데이터에서 데이터 삭제하기 (일치하는 데이터 찾아서 ===> 삭제)
  func deleteSavedChallenge(with savedChallengeID: UUID, completion: @escaping () -> Void) {
    guard let context = context else { return }
    
    let fetchRequest = NSFetchRequest<ChallengeVideoWithCoreData>(entityName: modelName)
    fetchRequest.predicate = NSPredicate(format: "id = %@", savedChallengeID.uuidString)
    
    do {
      guard let result = try? context.fetch(fetchRequest),
            let object = result.first as? NSManagedObject else { return }
      context.delete(object)

      try context.save()
      CoreDataManager.shared.fetchSavedChallengeList()

      completion()
    }catch{
      print(#fileID, #function, #line, "- err: \(error.localizedDescription)")

    }
    
  }
  
}
