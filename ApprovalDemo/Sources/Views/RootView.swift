import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Users", systemImage: "person.2") {
                ContentView()
            }
            Tab("Security", systemImage: "faceid") {
                SecurityView()
            }
        }
    }
}

#Preview {
    RootView()
}
