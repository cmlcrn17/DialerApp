# Sade Telefon

Sade Telefon, SwiftUI ile yazılmış yerel bir iPhone arama uygulamasıdır. Kişileri SwiftData ile yalnızca uygulama içinde saklar; Speech framework ile kişi arar ve standart `tel:` sistemiyle normal SIM/hücresel arama başlatır. Mimari MVVM'dir ve arama altyapısı bir servis protokolünün arkasında tutulur.

## Gereksinimler

- macOS ve iOS 26 SDK içeren güncel Xcode
- iOS 17 veya daha yeni bir iPhone
- Fiziksel aygıta yüklemek için bir Apple geliştirici hesabı ve kişisel Development Team

## Aygıtta çalıştırma

1. `DialerApp.xcodeproj` dosyasını Xcode'da açın.
2. **DialerApp** target'ında **Signing & Capabilities** bölümünden kendi Team'inizi seçin.
3. Bundle Identifier'ı hesabınıza özgü bir değerle değiştirin.
4. iPhone'u USB ile bağlayın, hedef olarak aygıtı seçin ve **Run** düğmesine basın.
5. Sesli aramayı ilk kullandığınızda mikrofon ve konuşma tanıma izinlerini onaylayın.

Simulator normal hücresel arama yapamaz; çağrı akışını fiziksel, SIM/eSIM etkin bir iPhone'da deneyin.

## Default Dialer / LiveCommunicationKit

Default Dialer yetkisi Apple onayı ve bu yetkiyi içeren provisioning profile gerektirir. Bu nedenle indirildiği haliyle proje kişisel imzalamada çalışan `tel:` hücresel fallback'ini kullanır. Apple hesabınız için yetki verildikten sonra:

1. Target'ın **Code Signing Entitlements** ayarını `DialerApp/Resources/DialerApp.entitlements` yapın.
2. **Swift Compiler - Custom Flags** altında `DIALER_ENABLE_LIVE_COMMUNICATION_KIT` koşulunu tanımlayın (`SWIFT_ACTIVE_COMPILATION_CONDITIONS`).
3. `LiveCommunicationKitCellularAdapter.swift` içindeki iOS 26 SDK çağrısını, kullandığınız Xcode beta/GM imzasıyla doğrulayın.

Adaptör `TelephonyConversationManager` ve `StartCellularConversationAction` kullanımını ana uygulamadan izole eder. Yetki/koşul olmadan derlemeye dahil edilmez ve `CellularCallingService` otomatik olarak `SystemURLCallingService` yoluna gider.

## Gizlilik

Uygulama sistem rehberini okumaz. Oluşturulan kişiler ve uygulama içinden başlatılan arama geçmişi SwiftData mağazasında yerel olarak saklanır. Tarihler `Date` olarak mutlak zaman değeridir (UTC temelli).
