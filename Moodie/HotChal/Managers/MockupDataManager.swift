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
  
  lazy var top3ChallengeVideos: [ChallengeVideo] = {
    var seenCategories = Set<String>()
    var uniqueVideos: [ChallengeVideo] = []
    
    for video in sortedWithViewCountChallengeVideos {
      if let category = video.category, !seenCategories.contains(category) {
        seenCategories.insert(category)
        uniqueVideos.append(video)
      }
      if uniqueVideos.count == 3 {
        break
      }
    }
    return uniqueVideos
  }()

  lazy var top3Categories = top3ChallengeVideos.map { $0.category }
  
  lazy var top3ChallengeVideosWithCategory: [Int : [ChallengeVideo]] = [:]
  
  lazy var sortedWithViewCountChallengeVideos: [ChallengeVideo] = []

  
  // MARK: init

  private init() {
    sortedWithViewCountChallengeVideos = Array(challengeVideos.sorted(by: {
      guard let firstViewCount = $0.viewCount,
            let secondViewCount = $1.viewCount else { return false }
      return firstViewCount > secondViewCount
    }).prefix(20))
    
    
    for (num, category) in top3Categories.enumerated() {
      let challenges = challengeVideos.filter { $0.category == category }
      
      top3ChallengeVideosWithCategory.updateValue(challenges, forKey: num)
    }
  }
  
  // MARK: mockup

  let challengeVideos: [ChallengeVideo] = [
    ChallengeVideo(id: UUID(),
                   thumbnailImage: "Golden1",
                   title: "Golden 배우기 1",
                   uploader: "춤선생 SIMBA",
                   videoFilename: "golden1.mp4",
                   mp4Filename: "",
                   category: "Golden",
                   viewCount: Int.random(in: 0...32767)),
    
    ChallengeVideo(id: UUID(),
                   thumbnailImage: "Golden2",
                   title: "Golden 배우기 2",
                   uploader: "춤추는 당근 Dancing Carrot",
                   videoFilename: "golden2.mp4",
                   mp4Filename: "",
                   category: "Golden",
                   viewCount: Int.random(in: 0...32767)),

    ChallengeVideo(id: UUID(),
                   thumbnailImage: "Pokemon1",
                   title: "Pokedance 배우기 1",
                   uploader: "몸치탈출연구소 (Fast dance)",
                   videoFilename: "pokemon1.mp4",
                   mp4Filename: "",
                   category: "Pokedance",
                   viewCount: Int.random(in: 0...32767)),
    
    ChallengeVideo(id: UUID(),
                   thumbnailImage: "Pokemon2",
                   title: "Pokedance 배우기 2",
                   uploader: "춤선생 SIMBA",
                   videoFilename: "pokemon2.mp4",
                   mp4Filename: "",
                   category: "Pokedance",
                   viewCount: Int.random(in: 0...32767)),
    
    ChallengeVideo(id: UUID(),
                   thumbnailImage: "SodaPop1",
                   title: "SodaPop 배우기",
                   uploader: "춤선생 SIMBA",
                   videoFilename: "sodaPop1.mp4",
                   mp4Filename: "",
                   category: "SodaPop",
                   viewCount: Int.random(in: 0...32767)),
    
    ChallengeVideo(id: UUID(),
                   thumbnailImage: "SodaPop2",
                   title: "SodaPop 배우기 2",
                   uploader: "댄싱꽥꽥 Dancing Duck",
                   videoFilename: "sodaPop2.mp4",
                   mp4Filename: "",
                   category: "SodaPop",
                   viewCount: Int.random(in: 0...32767)),
    
    ChallengeVideo(id: UUID(),
                   thumbnailImage: "SodaPop3",
                   title: "SodaPop 배우기 3",
                   uploader: "joohee kim",
                   videoFilename: "sodaPop3.mp4",
                   mp4Filename: "",
                   category: "SodaPop",
                   viewCount: Int.random(in: 0...32767)),
    
    ChallengeVideo(id: UUID(),
                   thumbnailImage: "SodaPop4",
                   title: "SodaPop 배우기 4",
                   uploader: "춤선생 SIMBA",
                   videoFilename: "sodaPop4.mp4",
                   mp4Filename: "",
                   category: "SodaPop",
                   viewCount: Int.random(in: 0...32767)),
    
    ChallengeVideo(id: UUID(),
                   thumbnailImage: "Toca1",
                   title: "TocaToca 배우기 1",
                   uploader: "PREMIUM DANCE STUDIO",
                   videoFilename: "toca1.mp4",
                   mp4Filename: "",
                   category: "TocaToca",
                   viewCount: Int.random(in: 0...32767)),
    
    ChallengeVideo(id: UUID(),
                   thumbnailImage: "Toca2",
                   title: "TocaToca 배우기 2",
                   uploader: "몸치탈출연구소 (Fast dance)",
                   videoFilename: "toca2.mp4",
                   mp4Filename: "",
                   category: "TocaToca",
                   viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "asepa1",
            title: "에스파 더티워크 챌린지 레드스파 vs 블랙스파 선택은?",
            uploader: "꿀재미슈",
            videoFilename: "asepa1.mp4",
            mp4Filename: "",
            category: "Dirty Work",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "boom1",
            title: "Boom boom boom",
            uploader: "LE SSERAFIM",
            videoFilename: "boom1.mp4",
            mp4Filename: "",
            category: "이프푸",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "bts1",
            title: "Learn Takedown",
            uploader: "Netflix",
            videoFilename: "bts1.mp4",
            mp4Filename: "",
            category: "Takedown",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "hypoBoy1",
            title: "?? : 뉴진스의 하입보이요",
            uploader: "kimwonhun",
            videoFilename: "hypoBoy1.mp4",
            mp4Filename: "",
            category: "HypeBoy",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "hypoBoy2",
            title: "[뉴진스] Hype Boy 추는 민지 혜인",
            uploader: "케이팝아카이빙",
            videoFilename: "hypoBoy2.mp4",
            mp4Filename: "",
            category: "HypeBoy",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "hypoBoy3",
            title: "뉴진스의 하입보이요 원본",
            uploader: "6ixmin",
            videoFilename: "hypoBoy3.mp4",
            mp4Filename: "",
            category: "HypeBoy",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "idol1",
            title: "[Twice] NaMoChaeng Yoasobi - Idol Challenge",
            uploader: "kgirlsmoment",
            videoFilename: "idol1.mp4",
            mp4Filename: "",
            category: "Idol",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "idol2",
            title: "최애의 아이 챌린지",
            uploader: "조씨Jossi",
            videoFilename: "idol2.mp4",
            mp4Filename: "",
            category: "Idol",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "idol3",
            title: "최애의 aespa",
            uploader: "aespa",
            videoFilename: "idol3.mp4",
            mp4Filename: "",
            category: "Idol",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "idol4",
            title: "요아소비 앞에서 최애의 아이 챌린지 하는 채원과 사쿠라",
            uploader: "르세라핌픽쳐스",
            videoFilename: "idol4.mp4",
            mp4Filename: "",
            category: "Idol",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "karina1",
            title: "up",
            uploader: "aespa",
            videoFilename: "karina1.mp4",
            mp4Filename: "",
            category: "Up",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "karina2",
            title: "에스파 카리나 챌린지 모음",
            uploader: "꿀챌리",
            videoFilename: "karina2.mp4",
            mp4Filename: "",
            category: "Karina",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "kdh1",
            title: "kpop idols who did the kdh challenge girl groups",
            uploader: "˚bunnyasa",
            videoFilename: "kdh1.mp4",
            mp4Filename: "",
            category: "Kdh",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "miyao1",
            title: "ᨐᵉᵒʷ",
            uploader: "aespa",
            videoFilename: "miyao1.mp4",
            mp4Filename: "",
            category: "Miyao",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "nemonemo",
            title: "안유진 님도 함께 네모네모 Sign〰💟",
            uploader: "YENA(최예나)",
            videoFilename: "nemonemo.mp4",
            mp4Filename: "",
            category: "네모네모",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "nemonemo2",
            title: "레전드 귀여운 최예나 신곡 '네모네모'",
            uploader: "M2",
            videoFilename: "nemonemo2.mp4",
            mp4Filename: "",
            category: "네모네모",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "ohmyGirl1",
            title: "이게나다",
            uploader: "이영지",
            videoFilename: "ohmyGirl1.mp4",
            mp4Filename: "",
            category: "IAM",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "savage1",
            title: "Savage Angle Challenge 🎃 Edition",
            uploader: "aespa",
            videoFilename: "savage1.mp4",
            mp4Filename: "",
            category: "Savage",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "superNova1",
            title: "슈슈슈슈퍼노바 퇴근",
            uploader: "aespa",
            videoFilename: "superNova1.mp4",
            mp4Filename: "",
            category: "SuperNova",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "superNova2",
            title: "#Supernova with #JAESUK ",
            uploader: "aespa",
            videoFilename: "superNova2.mp4",
            mp4Filename: "",
            category: "SuperNova",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "superNova3",
            title: "거세게 커져가 Ah Oh Ay",
            uploader: "aespa",
            videoFilename: "superNova3.mp4",
            mp4Filename: "",
            category: "SuperNova",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "superNova4",
            title: "사건은 다가와 Ah Oh Ay",
            uploader: "aespa",
            videoFilename: "superNova4.mp4",
            mp4Filename: "",
            category: "SuperNova",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "whiplash1",
            title: "✶⋆.˚ Whiplash with a changed man",
            uploader: "aespa",
            videoFilename: "whiplash1.mp4",
            mp4Filename: "",
            category: "Whiplash",
            viewCount: Int.random(in: 0...32767)),
    
      .init(id: UUID(),
            thumbnailImage: "whiplash2",
            title: "요즘에는 Whip-Whiplash★☆★",
            uploader: "aespa",
            videoFilename: "whiplash2.mp4",
            mp4Filename: "",
            category: "Whiplash",
            viewCount: Int.random(in: 0...32767))
  ]
  
  func fetchTop3Challenge(with category: String) -> [ChallengeVideo]{
    return challengeVideos.filter { $0.category == category }
  }
  
}
