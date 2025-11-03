import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            // Dark navy background
            Color(red: 0.1, green: 0.1, blue: 0.3)
                .ignoresSafeArea()
            
            // Stars background
            StarsBackgroundView()
                .ignoresSafeArea()
            
            // 3D Earth View
            EarthSceneView(selectedCity: viewModel.selectedCity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            // Search Interface Overlay
            VStack {
                Spacer()
                
                SearchOverlayView(
                    viewModel: viewModel
                )
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    HomeView()
}
