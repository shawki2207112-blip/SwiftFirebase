import SwiftUI
import FirebaseAuth


struct LoginView: View {

    @Binding var isLoggedIn: Bool

    @State var email = ""
    @State var password = ""
    @State var errorMessage = ""

    var body: some View {
        VStack(spacing: 16) {

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 70, height: 70)
                .foregroundColor(.blue)

            Text("My Notes")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)

            SecureField("Password (min 6 characters)", text: $password)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)

          
            if errorMessage != "" {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: login) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: signUp) {
                Text("Create new account")
            }
        }
        .padding()
    }

    
    func login() {
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }

    
    func signUp() {
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}
