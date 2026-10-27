import Foundation

struct User: Identifiable {
    // For SwiftUI’s ForEach or List,
    // it's often convenient to have an 'id' property.
    let id = UUID()

    let fullName: String
    let thumbnailURL: String
}
