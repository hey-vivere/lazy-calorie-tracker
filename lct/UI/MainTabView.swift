//
//  ContentView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var mealsStore = MealsStore()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
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
    }
}

#Preview {
    MainTabView()
        .environmentObject(MealsStore.mock)
}
