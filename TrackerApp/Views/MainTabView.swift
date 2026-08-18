//
//  MainTabView.swift
//  TrackerApp
//
//  Bottom tab bar: Streaks (weekly overview) — Today (default) — Profile.
//  A 4th "Analysis" tab is planned for later; adding it is just another
//  case here once that screen exists.
//
//  Owns the single shared HabitStore so the Streaks and Today tabs always
//  show the same in-memory habit/log data without a duplicate fetch.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var auth: AuthManager
    @StateObject private var store = HabitStore()

    @State private var selectedTab: Tab = .today

    private enum Tab {
        case streaks, today, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            StreaksView(store: store)
                .tabItem { Label("Streaks", systemImage: "square.grid.3x3.fill") }
                .tag(Tab.streaks)

            TodayView(store: store)
                .tabItem { Label("Today", systemImage: "house.fill") }
                .tag(Tab.today)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(Tab.profile)
        }
        .task {
            guard let userId = auth.userId else { return }
            await store.loadAll(userId: userId)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
