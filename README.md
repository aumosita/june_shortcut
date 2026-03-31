# JuneShortcut

글로벌 단축키로 지정된 앱을 빠르게 실행할 수 있는 macOS 메뉴바 유틸리티 앱입니다.

## 주요 기능

- **글로벌 단축키** - 어떤 앱을 사용 중이든 단축키로 지정된 앱을 즉시 실행
- **메뉴바 상주** - Dock에 표시되지 않고 메뉴바에서 동작
- **앱 그룹 실행** - 하나의 단축키로 여러 앱을 동시에 실행
- **단축키 충돌 감지** - 이미 등록된 단축키와 겹치는 경우 경고
- **로그인 시 자동 시작** - Mac 부팅 시 자동으로 실행

## 요구 사항

- macOS 14 (Sonoma) 이상
- 접근성 권한 허용 필요 (시스템 설정 > 개인정보 보호 및 보안 > 손쉬운 사용)

## 빌드

```bash
# XcodeGen 필요 (brew install xcodegen)
xcodegen generate
xcodebuild -project JuneShortcut.xcodeproj -scheme JuneShortcut -configuration Release build
```

## 사용 방법

1. 앱을 실행하면 메뉴바에 아이콘(⌘)이 나타납니다
2. 첫 실행 시 접근성 권한을 허용해 주세요
3. 메뉴바 아이콘 클릭 > **설정 열기**로 설정 윈도우를 엽니다
4. **+** 버튼으로 새 단축키를 추가합니다
   - 이름 입력
   - 단축키 필드를 클릭하고 원하는 키 조합 입력 (수정자 키 필수)
   - 실행할 앱 선택 (복수 선택 가능)
5. 등록된 단축키를 누르면 지정된 앱이 실행됩니다

## 기술 스택

| 항목 | 구현 |
|------|------|
| UI | SwiftUI + MenuBarExtra |
| 글로벌 단축키 | CGEvent tap |
| 데이터 저장 | JSON (Application Support) |
| 로그인 아이템 | SMAppService |
| 키 녹화 | NSViewRepresentable (AppKit) |

## 프로젝트 구조

```
JuneShortcut/
├── JuneShortcutApp.swift        # 앱 진입점
├── Models/                      # 데이터 모델
├── ViewModels/                  # 뷰 모델 (MVVM)
├── Views/                       # UI 뷰
├── Services/                    # 핵심 서비스
│   ├── HotkeyService            # 글로벌 단축키 엔진
│   ├── AppLaunchService         # 앱 실행
│   ├── PersistenceService       # 데이터 영속성
│   ├── AccessibilityService     # 접근성 권한
│   └── LoginItemService         # 로그인 아이템
└── Resources/                   # 에셋
```

## 라이선스

MIT License
