# Sade Telefon

Sade Telefon; Apple Contacts ve Phone sadeliğini modern bir şirket rehberiyle birleştiren, SwiftUI ve SwiftData tabanlı, tamamen yerel bir iPhone uygulamasıdır. Giriş, sunucu veya hesap gerekmez. İlk açılışta 12 Türkçe demo kişi ve yedi grup hazırlanır. Arama geçmişi yalnızca **bu uygulamanın başlattığı** çağrıları içerir; uygulama Phone.app geçmişine eriştiğini iddia etmez.

## Neler hemen çalışır?

- Ana Sayfa, Gruplar, Kişiler ve Son Aramalar sekmeleri
- Ad, soyad, tam ad, şirket, görev, telefon, konum ve grup üzerinde yerel arama
- Türkçe sesli arama, favoriler, kişi detayları ve fotoğraf seçme
- SwiftData ile aygıt üzerinde kayıt, grup üyeliği ve uygulama içi arama geçmişi
- Fiziksel iPhone'da belgelenmiş `tel:` URL'si ile normal SIM/eSIM çağrısı
- Karanlık mod, Dynamic Type, VoiceOver etiketleri ve en az 44 punto çağrı hedefleri

## Proje ağacı

```text
DialerApp/
├── App/DialerApp.swift
├── Models/
│   ├── Contact.swift
│   ├── ContactGroup.swift
│   └── CallRecord.swift
├── Services/
│   ├── CallingService.swift
│   ├── DefaultDialerCallingService.swift
│   ├── SystemFallbackCallingService.swift
│   ├── LiveCommunicationKitCellularAdapter.swift
│   ├── PhoneNumber.swift
│   └── SpeechRecognizer.swift
├── ViewModels/DialerViewModel.swift
├── Views/
│   ├── RootView.swift
│   ├── HomeView.swift
│   ├── ContactsView.swift
│   ├── GroupsView.swift
│   ├── ContactDetailView.swift
│   ├── AddContactView.swift
│   ├── RecentsView.swift
│   ├── SettingsView.swift
│   ├── AvatarView.swift
│   └── KeypadView.swift
└── Resources/
    ├── Info.plist
    └── DialerApp.entitlements
```

## Fiziksel iPhone'a kurulum

1. Güncel Xcode'u açın ve `DialerApp.xcodeproj` dosyasını seçin.
2. Project Navigator'da projeyi, ardından **DialerApp** target'ını seçin.
3. **Signing & Capabilities** sekmesini açın.
4. **Team** alanında Apple Developer takımınızı seçin.
5. `com.example.SadeTelefon` Bundle Identifier'ını hesabınıza özgü bir değerle değiştirin.
6. **Automatically manage signing** seçeneğini etkinleştirin.
7. iPhone'u USB kablosuyla Mac'e bağlayın (daha sonra kablosuz geliştirme de seçilebilir).
8. Sorulursa iPhone'da bilgisayara güvenin ve Mac'te aygıt eşleştirmesini onaylayın.
9. Gerekirse iPhone'da **Ayarlar → Gizlilik ve Güvenlik → Geliştirici Modu**nu açıp aygıtı yeniden başlatın.
10. Xcode hedef menüsünden fiziksel iPhone'u seçin.
11. **Product → Run** (`⌘R`) ile derleyip yükleyin.
12. Sesli arama ve fotoğraf seçimini ilk kullanışınızda mikrofon, konuşma tanıma ve fotoğraf izinlerini verin.
13. Apple hesabınız ve bölgeniz destekliyorsa aşağıdaki Default Dialer adımlarını tamamlayın; desteklemiyorsa hiçbir şey eklemeyin, fallback hazırdır.
14. Desteklenen iOS sürümünde **Ayarlar → Uygulamalar → Varsayılan Uygulamalar → Arama** yolundan Sade Telefon'u seçin. Menü görünmüyorsa aygıt/sürüm/bölge veya entitlement uygun değildir.

Simulator normal hücresel çağrı yapamaz. Çağrıyı SIM/eSIM etkin fiziksel iPhone'da sınayın.

## Default Dialer ve LiveCommunicationKit

Projede iki açıkça ayrılmış yol vardır:

- `SystemFallbackCallingService`: `tel:` üzerinden normal hücresel çağrı açar ve yönetilen entitlement olmadan çalışır.
- `DefaultDialerCallingService`: uygun derlemede `LiveCommunicationKitCellularAdapter` kullanır; aksi halde fallback'i çağırır. VoIP'e sessizce geçmez.

`com.apple.developer.dialing-app` **yönetilen bir Apple entitlement'ıdır**. Dosyada örnek olarak bulunması Apple'ın bunu hesabınıza verdiği anlamına gelmez; ücretsiz kişisel takım ya da sıradan provisioning profile ile imzalanamaz. Onayınız yoksa `DialerApp.entitlements` dosyasını target'ın Code Signing Entitlements ayarına bağlamayın.

Apple entitlement'ı hesabınıza tanımladıktan sonra:

1. Certificates, Identifiers & Profiles alanında doğru App ID ve provisioning profile'ın entitlement'ı içerdiğini doğrulayın.
2. Xcode'da **Target → Signing & Capabilities** üzerinden Apple'ın sunduğu ilgili Default Calling/Dialer capability'yi ekleyin. Xcode capability'yi göstermiyorsa elle uydurulmuş bir capability eklemeyin.
3. Target'ın **Code Signing Entitlements** değerini `DialerApp/Resources/DialerApp.entitlements` yapın.
4. **Build Settings → Swift Compiler - Custom Flags → Active Compilation Conditions** alanına `DIALER_ENABLE_LIVE_COMMUNICATION_KIT` ekleyin.
5. Seçtiğiniz güncel Xcode SDK'sındaki LiveCommunicationKit imzalarını doğrulayıp fiziksel cihazda test edin.
6. iPhone Ayarları'nda uygulamayı varsayılan arama uygulaması seçin.

Bu adımlar yalnızca Default Dialer / LiveCommunicationKit yolunu açar. Rehber, gruplar, SwiftData, sesli arama, özel geçiş ekranı, uygulama içi geçmiş ve `tel:` fallback bunlar olmadan çalışır.

## Bilinen sınırlamalar

- Default Dialer kullanılabilirliği Apple Developer hesabına, yönetilen entitlement onayına, provisioning profile'a, iOS sürümüne, donanıma ve bölgeye bağlıdır.
- Uygulama ayarlardaki default-dialer seçimini doğrulayan herkese açık bir API yoksa durum tahmin edilmez; Ayarlar ekranı yalnızca belgelenmiş uygulama ayarları URL'sini açar.
- Özel “Aranıyor” ekranı yalnızca uygulamanın kontrolündeki geçiştir. Korunan sistem hücresel görüşme ekranını değiştirmez.
- `tel:` fallback Simulator'da çalışmaz ve iOS çağrı onayı/sistem arayüzünü yönetir.
- Speech tanımanın kullanılabilirliği aygıta, dile ve Apple servis durumuna bağlı olabilir.
- Kayıt zamanları `Date` ile mutlak zaman (UTC/0) olarak saklanır; UI aygıtın yerel saat diliminde gösterir.
- Tüm SwiftData sorguları sabit `projectID`, aktif kayıt ve silinmemiş (`deletedAt == nil`) kapsamını uygular.

## Doğrulama

Linux ortamında SwiftUI/iOS SDK bulunmadığı için gerçek iOS derlemesi yapılamaz. `scripts/validate_project.sh`, tüm Swift dosyalarının target'a eklendiğini ve property list dosyalarının okunabildiğini doğrular. Son derleme ve imzalama güncel Xcode'da yapılmalıdır.
