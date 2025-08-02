//
//  MockupDataManager.swift
//  HotChal
//
//  Created by 최용헌 on 8/2/25.
//

import Foundation


/// 목업데이터 매니저
final class MockupDataManager {
  static let shared = MockupDataManager()
  
  private init() {}
  
  let challengeVideos: [ChallengeVideo] = [
    ChallengeVideo(thumbnailImage: "Golden1",
                   title: "Golden 배우기 1",
                   uploader: "춤선생 SIMBA",
                   videoFilename: "golden1.mp4",
                   mp4Filename: "",
                   category: "Golden"),
    
    ChallengeVideo(thumbnailImage: "Golden2",
                   title: "Golden 배우기 2",
                   uploader: "춤추는 당근 Dancing Carrot",
                   videoFilename: "golden2.mp4",
                   mp4Filename: "",
                   category: "Golden"),
    
    ChallengeVideo(thumbnailImage: "Pokemon1",
                   title: "Pokedance 배우기 1",
                   uploader: "몸치탈출연구소 (Fast dance)",
                   videoFilename: "pokemon1.mp4",
                   mp4Filename: "",
                   category: "Pokedance"),
    
    ChallengeVideo(thumbnailImage: "Pokemon2",
                   title: "Pokedance 배우기 2",
                   uploader: "춤선생 SIMBA",
                   videoFilename: "pokemon2.mp4",
                   mp4Filename: "",

                   category: "Pokedance"),
    
    ChallengeVideo(thumbnailImage: "SodaPop1",
                   title: "SodaPop 배우기",
                   uploader: "춤선생 SIMBA",
                   videoFilename: "sodaPop1.mp4",
                   mp4Filename: "",

                   category: "SodaPop"),
    
    ChallengeVideo(thumbnailImage: "SodaPop2",
                   title: "SodaPop 배우기 2",
                   uploader: "댄싱꽥꽥 Dancing Duck",
                   videoFilename: "sodaPop2.mp4",
                   mp4Filename: "",

                   category: "SodaPop"),
    
    ChallengeVideo(thumbnailImage: "SodaPop3",
                   title: "SodaPop 배우기 3",
                   uploader: "joohee kim",
                   videoFilename: "sodaPop3.mp4",
                   mp4Filename: "",

                   category: "SodaPop"),
    
    ChallengeVideo(thumbnailImage: "SodaPop4",
                   title: "SodaPop 배우기 4",
                   uploader: "춤선생 SIMBA",
                   videoFilename: "sodaPop4.mp4",
                   mp4Filename: "",

                   category: "SodaPop"),
    
    ChallengeVideo(thumbnailImage: "Toca1",
                   title: "TocaToca 배우기 1",
                   uploader: "PREMIUM DANCE STUDIO",
                   videoFilename: "toca1.mp4",
                   mp4Filename: "",

                   category: "TocaToca"),
    
    ChallengeVideo(thumbnailImage: "Toca2",
                   title: "TocaToca 배우기 2",
                   uploader: "몸치탈출연구소 (Fast dance)",
                   videoFilename: "toca2.mp4",
                   mp4Filename: "",

                   category: "TocaToca")
  ]
}
