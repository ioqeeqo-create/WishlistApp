# Wishlist iOS App

## Requirements
- macOS 13+, Xcode 15+
- Apple Developer account (Team ID: 8A5K2DNPSR)
- iOS 16+ deployment target

## Build with xcodebuild

### Simulator (no signing required)
```bash
xcodebuild build \
  -project Wishlist.xcodeproj \
  -scheme Wishlist \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -configuration Debug
```

### Device / Archive (requires signing)
```bash
xcodebuild archive \
  -project Wishlist.xcodeproj \
  -scheme Wishlist \
  -configuration Release \
  -archivePath ./build/Wishlist.xcarchive \
  DEVELOPMENT_TEAM=8A5K2DNPSR \
  CODE_SIGN_STYLE=Automatic
```

### Export IPA (Ad Hoc)
Create `ExportOptions.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>method</key><string>ad-hoc</string>
  <key>teamID</key><string>8A5K2DNPSR</string>
  <key>compileBitcode</key><false/>
</dict></plist>
```
Then:
```bash
xcodebuild -exportArchive \
  -archivePath ./build/Wishlist.xcarchive \
  -exportPath ./build/IPA \
  -exportOptionsPlist ExportOptions.plist
```

## Project Structure
```
WishlistApp/
├── Wishlist.xcodeproj/
│   ├── project.pbxproj          ← generated, stable UUIDs
│   └── xcshareddata/xcschemes/
│       └── Wishlist.xcscheme
└── Wishlist/
    ├── WishlistApp.swift
    ├── Info.plist
    ├── Assets.xcassets/
    ├── Models/CoreDataModels.swift
    ├── Helpers/
    │   ├── PersistenceController.swift
    │   ├── CoreDataModelBuilder.swift
    │   └── DesignHelpers.swift
    ├── ViewModels/WishlistViewModel.swift
    └── Views/
        ├── ContentView.swift
        ├── HomeView.swift
        ├── WishlistDetailView.swift
        ├── ItemViews.swift
        ├── WishlistFormViews.swift
        └── ProfileView.swift
```
