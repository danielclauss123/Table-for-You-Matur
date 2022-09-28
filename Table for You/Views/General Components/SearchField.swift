import SwiftUI

/// A TextField that looks like a search field.
struct SearchField: View {
    let title: String
    
    @Binding var text: String
    
    let systemImage: String?
    let backgroundColor: Color
    
    @FocusState var isFocused: Bool
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 3) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.secondary)
            }
            
            TextField(title, text: $text)
                .focused($isFocused)
            
            if !text.isEmpty && isFocused {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(backgroundColor)
        .cornerRadius(10)
    }
    
    // MARK: - Initializer
    init(_ title: String = "Suche", text: Binding<String>, systemImage: String? = "magnifyingglass", backgroundColor: Color = Color(uiColor: .systemGray5)) {
        self.title = title
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor
        self._text = text
    }
}

struct SearchField_Previews: PreviewProvider {
    static var previews: some View {
        Container()
    }
    
    struct Container: View {
        @State private var text = ""
        
        var body: some View {
            SearchField(text: $text)
        }
    }
}
