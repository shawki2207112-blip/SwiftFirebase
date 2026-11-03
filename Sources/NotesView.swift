import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct Note: Identifiable {
    var id: String        
    var title: String
    var details: String
}


struct NotesView: View {

    @Binding var isLoggedIn: Bool

    @State var notes: [Note] = []       
    @State var expandedId = ""           
    @State var errorMessage = ""

   
    @State var showForm = false
    @State var editingId = ""           
    @State var formTitle = ""
    @State var formDetails = ""

    var notesCollection: CollectionReference {
        let uid = Auth.auth().currentUser?.uid ?? "unknown"
        return Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("notes")
    }

   
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {

                    if errorMessage != "" {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    if notes.isEmpty {
                        Text("No notes yet. Tap + to add one.")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    }

                    ForEach(notes) { note in
                        noteRow(note)
                    }
                }
                .padding()
            }
            .navigationBarTitle("My Notes")
            .navigationBarItems(
                leading: Button("Logout") { logout() },
                trailing: Button(action: { openAddForm() }) {
                    Image(systemName: "plus")
                }
            )
        }
        .onAppear {
            readNotes()
        }
        .sheet(isPresented: $showForm) {
            formView
        }
    }

    
    func noteRow(_ note: Note) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            Button(action: {
                if expandedId == note.id {
                    expandedId = ""
                } else {
                    expandedId = note.id
                }
            }) {
                HStack {
                    Text(note.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: expandedId == note.id ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }

            
            if expandedId == note.id {
                Text(note.details)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 20) {
                Button("Update") { openEditForm(note) }
                Button("Delete") { deleteNote(note) }
                    .foregroundColor(.red)
            }
            .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(10)
    }


    var formView: some View {
        VStack(spacing: 16) {
            Text(editingId == "" ? "New Note" : "Update Note")
                .font(.title2)
                .bold()

            TextField("Title", text: $formTitle)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)

            TextField("Description", text: $formDetails)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)

            Button(action: saveNote) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button("Cancel") { showForm = false }

            Spacer()
        }
        .padding()
    }

 
    func openAddForm() {
        editingId = ""
        formTitle = ""
        formDetails = ""
        showForm = true
    }

    func openEditForm(_ note: Note) {
        editingId = note.id
        formTitle = note.title
        formDetails = note.details
        showForm = true
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Logout error")
        }
        isLoggedIn = false
    }


    func readNotes() {
        notesCollection
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                var loaded: [Note] = []
                for doc in snapshot?.documents ?? [] {
                    let data = doc.data()
                    let note = Note(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        details: data["description"] as? String ?? ""
                    )
                    loaded.append(note)
                }
                notes = loaded
            }
    }

    func saveNote() {
        if formTitle == "" {
            return   
        }

        if editingId == "" {
           
            let newData: [String: Any] = [
                "title": formTitle,
                "description": formDetails,
                "createdAt": Date().timeIntervalSince1970
            ]
            notesCollection.addDocument(data: newData) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                }
                readNotes()
            }
        } else {
            
            let changes: [String: Any] = [
                "title": formTitle,
                "description": formDetails
            ]
            notesCollection.document(editingId).updateData(changes) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                }
                readNotes()
            }
        }
        showForm = false
    }

    func deleteNote(_ note: Note) {
        notesCollection.document(note.id).delete { error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
            readNotes()
        }
    }
}
