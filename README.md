
# HotChall

<div align="center">
<img width="250" height="250" alt="ChatGPT Image 2025년 7월 30일 오후 04_13_52" src="https://github.com/user-attachments/assets/de39e92d-7c36-4604-8a4a-7e5ac2b54526" />


![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-16.0+-green.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)

</div>

---

사용자들에게 요즘 뜨는 챌린지를 보여주고, 챌린지를 저장하여 배워볼 수 있는 iOS 앱

## 주요 기능

- **핫챌 Top3**: 조회수 기준 인기 챌린지 확인
- **Top100 리스트**: 카테고리별 챌린지 목록
- **챌린지 배우기**: 영상 플레이어로 동작 학습
- **챌린지 촬영**: 카메라로 챌린지 촬영 및 비교
- **즐겨찾기**: CoreData로 챌린지 저장/관리

## 기술 스택

| 분류 | 기술 |
|------|------|
| Architecture | ReactorKit, Coordinator Pattern |
| UI | UIKit (Code-based) |
| Reactive | RxSwift, RxCocoa |
| Storage | CoreData |
| Media | AVFoundation |
| Layout | Auto Layout (NSLayoutConstraint) |

## 아키텍처

### Coordinator Pattern

화면 전환 로직을 분리하여 ViewController 간 의존성을 최소화합니다.

```
AppCoordinator
└── TabCoordinator
    ├── ChalCoordinator (핫챌 메인)
    ├── HotChallLearnCoordinator (배우기)
    └── SavedChallengeCoordinator (즐겨찾기)
```

### ReactorKit Pattern

단방향 데이터 흐름으로 예측 가능한 상태 관리를 구현합니다.

```
Action (사용자 입력)
    ↓
Mutation (상태 변경)
    ↓
State (화면 표시)
```

**구현된 Reactor**:
- HotChalMainReactor
- HotChallTop100Reactor
- HotChallLearnReactor
- SavedHotChallReactor
- ShowChallengeReactor
- PlayerViewReactor
- CameraReactor
- ChallCompareReactor
- ModalReactor

## 프로젝트 구조

```
HotChal/
├── Coordinator/           # 화면 전환 관리
│   ├── AppCoordinator
│   ├── TabBarCoordinator
│   └── Protocol/
│
├── Scene/                 # 각 화면별 구현
│   ├── Chal/             # 핫챌 메인, Top100
│   ├── Learn/            # 배우기, 플레이어
│   ├── SavedChallenge/   # 즐겨찾기
│   ├── ShowChallenge/    # 챌린지 상세
│   ├── TakeChallenge/    # 촬영
│   └── CompareChallenge/ # 영상 비교
│
├── Model/                 # 데이터 모델
├── Managers/              # 싱글톤 매니저
├── Protocols/             # 커스텀 프로토콜
├── DesignSystem/          # UI 컴포넌트
└── Resources/             # 미디어 리소스
```

## 화면 흐름

```
┌──────────────────────────────────────┐
│            TabBarController          │
├──────────┬───────────┬───────────────┤
│ 핫챌Top3  │   배우기    │   즐겨찾기      │
└────┬─────┴─────┬─────┴───────┬───────┘
     │           │             │
     ▼           ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────────┐
│ Top3    │ │   검색   │ │   저장된      │
│ 챌린지    │ |   추천   │ │   챌린지      │
└────┬────┘ └────┬────┘ └──────┬──────┘
     │           │             │
     └───────────┴──────┬──────┘
                        ▼
              ┌─────────────────┐
              │ ChallPlayerView │ (Bottom Sheet)
              │ [배우기] [저장]    │
              │ [촬영]  [보기]    │
              └────────┬────────┘
                       │
           ┌─────────┬───────┬─────┬
           ▼         ▼       ▼     ▼  
       ┌──────┐ ┌──────┐ ┌──────┐ ┌──────--┐
       │Save  │ │Camera│ │Show  │ │Compare │
       │Data  │ │View  │ │Detail│ │View    │
       └──────┘ └──────┘ └──────┘ └──────--┘ 
```

## 데이터 모델

### ChallengeVideo

```swift
struct ChallengeVideo: Equatable {
    let id: UUID?
    let thumbnailImage: String?
    let title: String?
    let uploader: String?
    let videoFilename: String?
    let mp4Filename: String?
    let category: String?
    let viewCount: Int?
}
```

## 주요 컴포넌트

### 카메라 시스템

- **CameraService**: AVCaptureSession 관리, 전/후면 전환
- **RecordingService**: 영상 녹화, 파일 저장
- **CountDownManager**: 카운트다운 타이머
- **RecordingProgressManager**: 녹화 진행도 추적

### 디자인 시스템

- **Cells**: HotChallTopCell, ChallengeCell, ChallegneTop100Cell
- **Views**: ChallPlayerView, NoResultView
- **Components**: AlertView, PopupViewController, BottomSheetViewController

## 기획 및 디자인

- [핫챌 Figma 디자인 보드](https://www.figma.com/board/bvRxmZ7fbM5mWddMPjCkCP/%ED%95%AB%EC%B1%8C-HotChall-?node-id=73-1539&t=qa2e9EdL0HZyhKFV-0)

## 작동환경

- Xcode 16.0+
- iOS 16.0+




## 👥 개발팀

<table>
  <tr>
    <td align="center"><b>이지훈</b></td>
    <td align="center"><b>임종혁</b></td>
    <td align="center"><b>최용헌</b></td>
    <td align="center"><b>허지우</b></td>
  </tr>
</table>


