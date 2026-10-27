import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.error {
                    Text("Error: \(error.localizedDescription)")
                } else {
                    List(viewModel.users) { user in
                        HStack {
                            // Asynchronously load the thumbnail image
                            AsyncImage(url: URL(string: user.thumbnailURL)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    // Fallback image or an error symbol
                                    Image(systemName: "person.fill.questionmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            
                            Text(user.fullName)
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationTitle("Random Users")
        }
        // SwiftUI 4.0+:
        .task {
            await viewModel.fetchUsers()
        }
    }
}

#Preview {
    ContentView()
}
