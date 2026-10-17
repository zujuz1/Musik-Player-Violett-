import SwiftUI
import UIKit

/// Globale UIKit-Optik für Tab-Leiste und Navigationsleiste.
enum Appearance {
    static func configure() {
        configureTabBar()
        configureNavigationBar()
    }

    private static func configureTabBar() {
        let item = UITabBarItemAppearance()
        item.normal.iconColor = UIColor(Theme.textSecondary)
        item.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.textSecondary)]
        item.selected.iconColor = UIColor(Theme.textPrimary)
        item.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.textPrimary)]

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.background)
        appearance.shadowColor = .clear
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.background)
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.textPrimary),
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Theme.textPrimary),
            .font: UIFont.systemFont(ofSize: 30, weight: .heavy)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
