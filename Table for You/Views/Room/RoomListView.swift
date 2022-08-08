import SwiftUI

struct RoomListView: View {
    @StateObject var roomRepository: RoomRepository
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                switch roomRepository.loadingStatus {
                    case .loading:
                        EmptyView()
                    case .firestoreError(let error):
                        Section("Fehler") {
                            Text(error)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    case .ready:
                        roomList
                }
            }
            .overlay {
                if roomRepository.loadingStatus == .loading {
                    ProgressView()
                }
            }
            .navigationTitle("Tischpläne")
            .searchable(text: $roomRepository.searchText)
        }
    }
    
    // MARK: - Room List
    var roomList: some View {
        ForEach(roomRepository.searchedRooms) { room in
            RoomRowView(room: room)
        }
    }
    
    // MARK: - Init
    init(restaurant: Restaurant) {
        self._roomRepository = StateObject(wrappedValue: RoomRepository(restaurant: restaurant))
    }
}


// MARK: - Previews
struct RoomListView_Previews: PreviewProvider {
    static var previews: some View {
        RoomListView(restaurant: Restaurant.examples[0])
    }
}
