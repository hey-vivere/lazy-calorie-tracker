//
//  AddView.swift
//  lct
//
//  Created by Nikola Klipa on 10/13/25.
//

import SwiftUI
import CoreLocation

struct AddView: View {
    @EnvironmentObject private var mealsStore: MealsStore
    @StateObject private var locationService = LocationService()

    @State private var showManualEntry = false
    @State private var showCamera = false
    @State private var searchText = ""
    @State private var suggestions: [MealTemplate] = []
    @State private var searchResults: [MealTemplate] = []

    private var suggestionService: MockMealSuggestionService {
        MockMealSuggestionService(mealsProvider: { mealsStore.meals })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    suggestionsSection
                    quickActionsSection
                    searchSection

                    if !searchText.isEmpty {
                        searchResultsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Add Meal")
            .sheet(isPresented: $showManualEntry) {
                ManualEntryView()
            }
            .fullScreenCover(isPresented: $showCamera) {
                QuickCaptureFlow(isPresented: $showCamera)
            }
            .onAppear {
                locationService.requestWhenInUseAuthorization()
                locationService.startUpdatingLocation()
            }
            .onDisappear {
                locationService.stopUpdatingLocation()
            }
            .task {
                await loadSuggestions()
            }
            .onChange(of: locationService.currentLocation) { _, _ in
                Task {
                    await loadSuggestions()
                }
            }
            .onChange(of: mealsStore.meals) { _, _ in
                Task {
                    await loadSuggestions()
                    if !searchText.isEmpty {
                        await performSearch()
                    }
                }
            }
            .onChange(of: searchText) { _, newValue in
                Task {
                    await performSearch()
                }
            }
        }
    }

    // MARK: - Suggestions Section

    @ViewBuilder
    private var suggestionsSection: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label(
                    locationService.isAuthorized && locationService.currentLocation != nil ? "Nearby" : "Frequent",
                    systemImage: locationService.isAuthorized && locationService.currentLocation != nil ? "location.fill" : "clock.fill"
                )
                .font(.headline)
                .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(suggestions.prefix(10)) { template in
                            MealSuggestionCard(template: template) {
                                quickAdd(template: template, source: .locationSuggestion)
                            }
                        }
                    }
                }
            }
        } else if mealsStore.meals.isEmpty {
            emptyStateView
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Log your first meal to see suggestions")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Quick Actions Section

    @ViewBuilder
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Log a meal")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                QuickActionButton(
                    icon: "camera.fill",
                    title: "Camera",
                    color: .blue
                ) {
                    showCamera = true
                }

                QuickActionButton(
                    icon: "pencil.line",
                    title: "Manual",
                    color: .green
                ) {
                    showManualEntry = true
                }
            }
        }
    }

    // MARK: - Search Section

    @ViewBuilder
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search history")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search past meals...", text: $searchText)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Search Results Section

    @ViewBuilder
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Results")
                .font(.headline)
                .foregroundColor(.secondary)

            if searchResults.isEmpty {
                Text("No meals found")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(searchResults) { template in
                        MealTemplateRow(template: template) {
                            quickAdd(template: template, source: .searchHistory)
                            searchText = ""
                        }
                    }
                }
            }
        }
    }

    // MARK: - Data Loading

    private func loadSuggestions() async {
        if let location = locationService.currentLocation, locationService.isAuthorized {
            if let nearby = try? await suggestionService.fetchSuggestionsNearLocation(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude,
                radiusMeters: 200
            ), !nearby.isEmpty {
                suggestions = nearby
                return
            }
        }

        // Fall back to most common
        suggestions = (try? await suggestionService.fetchMostCommon(limit: 10)) ?? []
    }

    private func performSearch() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        searchResults = (try? await suggestionService.searchMeals(query: searchText)) ?? []
    }

    private func quickAdd(template: MealTemplate, source: MealSource) {
        mealsStore.quickAddFromTemplate(
            template,
            at: locationService.currentLocation,
            source: source
        )
    }
}

#Preview {
    AddView()
        .environmentObject(MealsStore.mock)
}
