import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "leaf.fill")
                .imageScale(.large)
                .foregroundColor(.green)
            Text("Welcome to Plantam")
                .font(.title)
                .padding()
            Text("Your iOS Plant Placement Assistant")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
