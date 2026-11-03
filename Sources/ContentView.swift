import SwiftUI
import FirebaseCore
import FirebaseAuth


struct ContentView: View {

    @State var isLoggedIn = false

    var body: some View {
        Group {
            if isLoggedIn {
                NotesView(isLoggedIn: $isLoggedIn)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
            
            if Auth.auth().currentUser != nil {
                isLoggedIn = true
            }
        }
    }
}
