//
//  MealsListView.swift
//  lct
//
//  Created by Nikola Klipa on 10/20/25.
//

import SwiftUI

struct MealsListView: View {
    @EnvironmentObject private var mealsStore: MealsStore
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var path = NavigationPath() // for deeper navigation if needed
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if isLoading {
                    ProgressView("Loading meals...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                } else if mealsStore.meals.isEmpty {
                    Text("No meals logged today 🍽️")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(mealsStore.meals) { meal in
                            NavigationLink(value: meal) {
                                MealRowView(meal: meal) {
                                    Task {
                                        await mealsStore.retryEstimation(for: meal.id)
                                    }
                                }
                            }
                            .deleteDisabled(meal.isPending)
                        }
                        .onDelete(perform: deleteMeal)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Today's Meals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Navigate to add meal
                        path.append("add")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await loadMeals()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .navigationDestination(for: DashboardMeal.self) { _ in // we will put meal here
                EmptyView()
            }
            .navigationDestination(for: String.self) { route in
                if route == "add" {
                    AddView()
                }
            }
            .task {
                await loadMeals()
            }
        }
    }
    
    private func loadMeals() async {
        do {
            isLoading = true
            let statusCode: Int
            let number = Int.random(in: 1...10)
            (number == 3) ? (statusCode = 300) : (statusCode = 200)
            
            if statusCode == 500 {
                throw NSError(domain: "Whatever", code: 500)
            }
            
            let response = mealsStore.meals.isEmpty
            ? (meals: MealsStore.mock.meals, statusCode: statusCode)
            : (meals: mealsStore.meals, statusCode: statusCode)
            
            mealsStore.meals = response.meals
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load meals"
            isLoading = false
        }
    }

    private func deleteMeal(at offsets: IndexSet) {
        Task {
            mealsStore.remove(at: offsets)
        }
    }
}

#Preview {
    MealsListView()
    .environmentObject(MealsStore.mock)
}
