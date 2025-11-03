import SwiftUI

struct SearchOverlayView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            if viewModel.isSearching {
                SearchActiveView(viewModel: viewModel)
            } else {
                SearchButtonView(viewModel: viewModel)
            }
        }
    }
}

struct SearchButtonView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Selected city info
            if let city = viewModel.selectedCity {
                CityInfoCard(city: city) {
                    withAnimation {
                        viewModel.clearSelectedCity()
                    }
                }
            }
            
            // Search button
            Button(action: {
                withAnimation {
                    viewModel.startSearch()
                }
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search Cities")
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal)
    }
}

struct SearchActiveView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search cities...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                )
                
                Button("Cancel") {
                    withAnimation {
                        viewModel.cancelSearch()
                    }
                }
                .foregroundColor(.white)
                .padding(.leading, 8)
            }
            .padding(.horizontal)
            
            // Results list
            if !viewModel.filteredCities.isEmpty {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredCities) { city in
                        CityRowView(city: city) {
                            viewModel.selectCity(city)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
}

struct CityInfoCard: View {
    let city: City
    let onClear: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(city.country)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct CityRowView: View {
    let city: City
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(city.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(city.country)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
