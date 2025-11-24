
# HotChall

<div align="center">
<img width="250" height="250" alt="ChatGPT Image 2025년 7월 30일 오후 04_13_52" src="https://github.com/user-attachments/assets/de39e92d-7c36-4604-8a4a-7e5ac2b54526" />

챌린지를 배우고, 찍어보고, 비교까지 할 수 있는 숏폼 기반 챌린지 플랫폼

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-16.0+-green.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)

</div>

---

## 📑 목차

* [소개](#-소개)
* [기획 및 디자인](#-기획-및-디자인)
* [핵심 기능](#-핵심-기능)
* [기술 스택](#️-기술-스택)
* [아키텍처](#-아키텍처)
* [프로젝트 구조](#-프로젝트-구조)
* [로드맵](#-로드맵)
* [개발팀](#-개발팀)

---

## 🧩 소개

**HotChall**는 요즘 시대의 핵심 문화인 챌린지를 보다 쉽고 효율적으로 배우며 찍을 수 있도록 만든 앱입니다.

* **문제**: 챌린지를 따라 하고 싶지만, 배경 지식 부족 / 편리한 촬영·비교 도구 부족
* **해결**: 숏폼 기반 학습·촬영·비교 기능을 원앱으로 제공
* **가치**: 사용자 스스로 챌린지를 배우고, 촬영하고, 비교하고, 저장하는 전 과정을 지원

---


# 기획 및 디자인
- [핫챌 Figma 디자인 보드](https://www.figma.com/board/bvRxmZ7fbM5mWddMPjCkCP/%ED%95%AB%EC%B1%8C-HotChall-?node-id=73-1539&t=qa2e9EdL0HZyhKFV-0)

---
## ⚡ 핵심 기능

### 1. 숏츠 형식으로 챌린지 보기

* UIPageViewController 기반 위아래 스와이프
* AVPlayer로 틱톡·릴스 스타일 자동재생

### 2. 챌린지 저장 기능

* CoreData 기반 즐겨찾기 기능
* 다시 보고 싶은 챌린지를 저장하여 관리

### 3. 챌린지 찍어보기

* 선택한 챌린지 영상을 기반으로 촬영
* 촬영본과 원본 비교 보기
* 결과 영상 저장 및 공유 가능

### 4. 챌린지 배워보기

* 원하는 구간만 반복하는 구간 반복 기능
* 배속 재생

### 5. 챌린지 비교하기

* 촬영 영상과 본 영상을 동시에 비교
* 서브뷰 전환을 통해 직관적 비교 가능

---

## 🛠️ 기술 스택

* **Language**: Swift 5.9
* **Framework**: UIKit, AVFoundation, AVPlayer, CoreData
* **Architecture**: MVC
* **Media**: AVPlayer, AVAsset
* **Persistence**: CoreData
* **Tooling**: Swift Package Manager

---

## 🧱 아키텍처

```
HotChallenge
├── App
│   ├── HotChallengeApp.swift
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Scene
│   ├── Home (챌린지 보기 화면)
│   ├── Learn (배워보기)
│   ├── Record (촬영)
│   ├── Compare (비교)
│   └── Saved (즐겨찾기)
├── Models
│   └── Challenge, VideoItem, SavedChallenge
├── ViewModels
│   └── 각 화면별 ViewModel
├── Services
│   ├── CoreDataManager
│   ├── VideoPlayerManager
│   └── FileManagerService
└── Utils & Extensions
```
---

## 🗺 로드맵

### v1.0 (완료)

* 숏폼 챌린지 보기
* 즐겨찾기
* 촬영 & 비교
* 구간 반복 / 배속 기능


### v1.1 (진행 중)

* MVC 패턴에서 Reactorkit으로 전환

---

## 👥 개발팀

<table>
  <tr>
    <td align="center"><b>이지훈</b></td>
    <td align="center"><b>임종혁</b></td>
    <td align="center"><b>최용헌</b></td>
    <td align="center"><b>허지우</b></td>
  </tr>
</table>


