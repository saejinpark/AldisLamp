# Aldis Lamp

배의 신호등을 iPhone 앱으로 옮긴 모스 부호 송수신기.

- **송신**: 메시지를 입력하면 화면의 램프와 후면 손전등이 모스 부호로 깜빡입니다. 속도(WPM)와 반복을 조절할 수 있습니다.
- **수동 키**: 키를 누르는 동안 셔터가 열립니다. 누른 길이로 점과 선을 가려 글자로 해독해 보여 줍니다.
- **수신**: 후면 카메라로 상대 램프의 빛을 읽어 모스 부호를 해독합니다. 노출을 고정하고 점 길이를 자동 보정합니다.
- Liquid Glass(iOS 26+), 가로 2단 배치, 한국어·영어·일본어.

## 구조

| 파일 | 역할 |
| --- | --- |
| `AldisLamp/Morse.swift` | 국제 모스 부호표와 타이밍(PARIS 기준) |
| `AldisLamp/Transmitter.swift` | 송신과 수동 키: 램프·손전등·햅틱 제어, 키 입력 해독 |
| `AldisLamp/Receiver.swift` | 카메라 밝기 분석과 빛 신호 해독기 |
| `AldisLamp/LampView.swift` | 황동 하우징과 프레넬 렌즈 램프 |
| `AldisLamp/ContentView.swift` | 화면 구성, 세로/가로 배치, 각 모드의 패널 |
| `AldisLamp/Theme.swift` | 디자인 토큰(색, 간격, 모서리) |
| `AldisLamp/Localizable.xcstrings` | 문자열(ko 원문, en, ja) |
| `Marketing/` | App Store 헤더·검색 결과·스크린샷 이미지 |

디자인 시스템: https://claude.ai/artifact/BTrTeA7RSkDrVmWWfjG6PG

## 빌드

Xcode 26 이상, iOS 26 이상. 서명 팀과 번들 ID(`dev.geppetto.AldisLamp`)는 프로젝트에 들어 있습니다.
