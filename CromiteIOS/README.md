# Cromite for Apple (iOS 17/18+ & macOS 14+ / Darwin 27)

A native, privacy-first Swift & SwiftUI web browser engineered specifically for the Apple ecosystem, translating all core privacy protections, ad blocking, and anti-fingerprinting features of [Cromite](https://www.cromite.org) into native iOS/macOS WebKit technologies.

---

## 🛡️ Cromite Feature Parity Matrix

| Cromite / Chromium Feature | Cromite iOS Swift Implementation | Native iOS / Apple Mechanism |
| :--- | :--- | :--- |
| **Built-in Ad Blocking** | `AdBlockEngine.swift` | `WKContentRuleListStore` compiled JSON rules (EasyList / AdGuard) |
| **Tracker & Telemetry Blocking** | `PrivacyFirewall.swift` | Network-level host blocking & third-party cookie isolation |
| **URL Tracking Parameter Stripping** | `TrackingParamStripper.swift` | Dynamic query cleaning (`utm_*`, `gclid`, `fbclid`, `msclkid`, etc.) |
| **Canvas Hash Noise Perturbation** | `AntiFingerprinting.swift` | `WKUserScript` injection perturbing canvas pixel data imperceptibly |
| **AudioBuffer / AnalyserNode Protection** | `AntiFingerprinting.swift` | Low-entropy frequency & channel noise injection |
| **Disable Battery API** | `AntiFingerprinting.swift` | `delete navigator.getBattery` before DOM hydration |
| **Disable Gamepad & Sensors** | `AntiFingerprinting.swift` | Overriding `navigator.getGamepads` & device motion |
| **WebRTC Local IP Leak Protection** | `AntiFingerprinting.swift` | Sanitizing `RTCPeerConnection` ice servers and candidates |
| **Global Privacy Control & DNT** | `AntiFingerprinting.swift` | `navigator.globalPrivacyControl = true`, `navigator.doNotTrack = '1'` |
| **Strict HTTPS Upgrading** | `PrivacyFirewall.swift` | Pre-navigation protocol upgrade to `https://` |
| **Always Incognito / Ephemeral Mode** | `CromiteTab.swift` | `WKWebsiteDataStore.nonPersistent()` zero disk caching |
| **Google RLZ / Querystring Sanitization** | `PrivacySettings.swift` | English-only, telemetry-free search parameters |
| **Cromite Shield Dashboard** | `ShieldsDashboardSheet.swift` | Real-time UI indicator showing blocked trackers, ads & parameters |
| **Data Retention & Instant Wiping** | `SettingsSheet.swift` | Configurable history days & one-tap full sandbox data purge |

---

## 📁 Project Architecture

```
CromiteIOS/
├── Package.swift                    # Swift 5.9 / 6.0 Package definition (iOS 17+, macOS 14+)
├── README.md                        # Documentation and architecture guide
└── Sources/
    ├── CromiteCore/                 # Core engine, networking, and privacy rules
    │   ├── AdBlock/
    │   │   └── AdBlockEngine.swift  # WebKit Content Blocker compiler
    │   ├── Bookmarks/
    │   │   ├── BookmarkItem.swift   # Bookmark data model
    │   │   └── BookmarkManager.swift# Persistent bookmarks store & import/export
    │   ├── Engine/
    │   │   ├── CromiteTab.swift     # WKWebView wrapper & navigation delegate
    │   │   ├── CromiteTabManager.swift # Multi-tab lifecycle manager
    │   │   └── HistoryManager.swift # History retention & search
    │   ├── Privacy/
    │   │   ├── AntiFingerprinting.swift # JS user script injection for canvas/audio/battery
    │   │   ├── PrivacyFirewall.swift    # Telemetry and ad domain blocker
    │   │   └── TrackingParamStripper.swift # Strips utm_*, fbclid, gclid from links
    │   └── Settings/
    │       └── PrivacySettings.swift    # Persistent configuration and search engines
    │
    ├── CromiteUI/                   # Modern SwiftUI interface
    │   ├── Components/
    │   │   ├── AddressBarView.swift # Omnibar with SSL lock, Shield pill, reload
    │   │   ├── BrowserUIState.swift # Observable UI view states
    │   │   └── WebViewContainer.swift # SwiftUI WKWebView representable
    │   └── Views/
    │       ├── BookmarksSheet.swift     # Saved bookmarks view
    │       ├── BrowserView.swift        # Primary browser screen & toolbars
    │       ├── HistorySheet.swift       # History view with search & deletion
    │       ├── SettingsSheet.swift      # Cromite feature toggles & controls
    │       ├── ShieldsDashboardSheet.swift # Cromite Shield metrics popup
    │       └── TabsOverviewSheet.swift  # Tab grid switcher with incognito support
    │
    ├── CromiteApp/                  # App entry point
    │   └── CromiteApp.swift         # @main SwiftUI Application
    │
    └── CromiteTestRunner/           # Automated validation suite
        └── main.swift               # Runs tests on privacy, adblocking, stripping
```

---

## 🚀 How to Build and Run

### 1. Command Line (Swift Package Manager)
Build the entire project:
```bash
cd CromiteIOS
swift build
```

Run the validation suite:
```bash
swift run CromiteTestRunner
```

### 2. Opening in Xcode
1. Open Xcode on macOS.
2. Select **File > Open...** and select the `CromiteIOS/` folder (or drag `Package.swift` into Xcode).
3. Select any iOS Simulator (e.g. iPhone 15/16 running iOS 17+) or a connected physical iOS device.
4. Press **Cmd + R** to run.

