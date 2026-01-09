//
//  ContentView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showQuickCapture = false
    @StateObject private var mealsStore = MealsStore()

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DashboardView(showQuickCapture: $showQuickCapture)
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar.fill")
                    }
                    .tag(0)

                AddView()
                    .tabItem {
                        Label("Add Meal", systemImage: "plus.circle.fill")
                    }
                    .tag(1)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .environmentObject(mealsStore)

            if showQuickCapture {
                QuickCaptureFlow(isPresented: $showQuickCapture)
                    .environmentObject(mealsStore)
                    .transition(.move(edge: .leading))
                    .zIndex(1)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MainTabView()
        .environmentObject(MealsStore.mock)
}
