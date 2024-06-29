//
//  Utilities.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 5/6/24.
//

import SwiftUI
import Foundation

final class Utilities {
    static let shared = Utilities()
    
    private init() {}
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? getRootViewController()
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }

    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .first as? UIWindowScene else {
            return nil
        }
        
        return windowScene.windows.filter({ $0.isKeyWindow }).first?.rootViewController
    }
}



