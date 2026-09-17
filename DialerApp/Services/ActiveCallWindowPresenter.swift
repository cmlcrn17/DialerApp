import Combine
import SwiftUI
import UIKit

/// Presents the in-app call controls in a dedicated window above every other
/// window owned by the application. iOS does not allow application windows to
/// cover another application or protected system call UI; when this app becomes
/// active again, the call window is restored immediately.
@MainActor
final class ActiveCallWindowPresenter: NSObject {
    static let shared = ActiveCallWindowPresenter()

    private var activeCall: ActiveCallViewModel?
    private var callObservation: AnyCancellable?
    private var windows: [String: UIWindow] = [:]

    private override init() {
        super.init()
        callObservation = ActiveCallCenter.shared.$current
            .receive(on: RunLoop.main)
            .sink { [weak self] model in
                MainActor.assumeIsolated {
                    self?.activeCall = model
                    self?.refreshWindows()
                }
            }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneDidActivate(_:)),
            name: UIScene.didActivateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneDidDisconnect(_:)),
            name: UIScene.didDisconnectNotification,
            object: nil
        )
    }

    @objc private func sceneDidActivate(_ notification: Notification) {
        guard let scene = notification.object as? UIWindowScene else { return }
        updateWindow(for: scene)
    }

    @objc private func sceneDidDisconnect(_ notification: Notification) {
        guard let scene = notification.object as? UIWindowScene else { return }
        windows.removeValue(forKey: scene.session.persistentIdentifier)?.isHidden = true
    }

    private func refreshWindows() {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        scenes.forEach(updateWindow)

        if activeCall == nil {
            windows.values.forEach { window in
                window.isHidden = true
                window.windowScene?.windows
                    .first { $0 !== window && $0.windowLevel == .normal }
                    ?.makeKey()
            }
        }
    }

    private func updateWindow(for scene: UIWindowScene) {
        let identifier = scene.session.persistentIdentifier
        guard let activeCall, scene.activationState == .foregroundActive else {
            windows[identifier]?.isHidden = true
            return
        }

        let window = windows[identifier] ?? makeWindow(for: scene)
        window.rootViewController = UIHostingController(rootView: ActiveCallView(model: activeCall))
        window.isHidden = false
        window.makeKeyAndVisible()
        windows[identifier] = window
    }

    private func makeWindow(for scene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: scene)
        window.backgroundColor = .clear
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue + 1)
        return window
    }
}
