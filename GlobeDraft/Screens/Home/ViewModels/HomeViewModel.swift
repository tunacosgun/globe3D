import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var selectedCity: City?
    @Published var searchText = ""
    @Published var isSearching = false
    
    var filteredCities: [City] {
        if searchText.isEmpty {
            return Array(sampleCities.prefix(8))
        }
        return Array(sampleCities.filter { city in
            city.name.localizedCaseInsensitiveContains(searchText) ||
            city.country.localizedCaseInsensitiveContains(searchText)
        }.prefix(8))
    }
    
    func selectCity(_ city: City) {
        selectedCity = city
        isSearching = false
        searchText = ""
    }
    
    func startSearch() {
        isSearching = true
    }
    
    func cancelSearch() {
        isSearching = false
        searchText = ""
    }
    
    func clearSelectedCity() {
        selectedCity = nil
    }
}