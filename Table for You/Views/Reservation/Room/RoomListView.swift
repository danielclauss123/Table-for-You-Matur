import SwiftUI

struct RoomListView: View {
    @StateObject var roomRepository: RoomRepository
    
    @ObservedObject var viewModel: ReservationViewModel
    
    // MARK: - Body
    var body: some View {
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
        .navigationTitle("Räume")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $roomRepository.searchText)
    }
    
    // MARK: - Room List
    var roomList: some View {
        ForEach(roomRepository.searchedRooms) { room in
            RoomRowView(room: room, viewModel: viewModel)
        }
    }
    
    // MARK: - Init
    init(restaurant: Restaurant, viewModel: ReservationViewModel) {
        self.viewModel = viewModel
        self._roomRepository = StateObject(wrappedValue: RoomRepository(restaurant: restaurant))
    }
}


// MARK: - Previews
struct RoomListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoomListView(restaurant: .examples[0], viewModel: .init(restaurant: .examples[0]))
        }
    }
}
