import SwiftUI

struct ConfiramtionTestView: View {
    @ObservedObject var viewModel: ReservationViewModel
    
    @State private var showing = false
    
    @Namespace var ns
    
    var body: some View {
        ZStack {
            if showing {
                Button {
                    showing = true
                } label: {
                    TableView(table: .example(), seatFill: Color.accentColor, tableFill: Color.accentColor)
                }
                .matchedGeometryEffect(id: "asdf", in: ns)
            } else {
                Button {
                    showing = true
                } label: {
                    TableView(table: .example(), seatFill: Color.accentColor, tableFill: Color.accentColor)
                }
                .offset(y: 150)
                .matchedGeometryEffect(id: "asdf", in: ns)
            }
            
            /*if showing {
                VStack {
                    Text(viewModel.restaurant.name)
                    
                    TableView(table: .example(), seatFill: Color.accentColor, tableFill: Color.accentColor)
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                }
            }*/
        }
    }
}

struct ConfiramtionTestView_Previews: PreviewProvider {
    static var previews: some View {
        ConfiramtionTestView(viewModel: .example)
    }
}
