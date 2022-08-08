import SwiftUI

struct TableView: View {
    let table: Table
    
    // MARK: - Body
    var body: some View {
        Group {
            if table.rotation == .normal || table.rotation == .right {
                horizontalTable
            } else {
                verticalTable
            }
        }
        .frame(width: table.width, height: table.height)
        .shadow(radius: 10)
    }
    
    // MARK: - Horizontal Table
    var horizontalTable: some View {
        HStack(spacing: 0) {
            if (table.rotation == .normal && table.leftHeadSeat != nil) || (table.rotation == .right && table.rightHeadSeat != nil) {
                HalfRoundedRectangle(.leading, cornerRadius: table.seatAndTabletopCornerRadius)
                    .fill(Table.seatFill)
                    .frame(width: table.normalSeatHeight, height: table.normalSeatWidth)
                    .frame(height: table.height)
            }
            
            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 1)
                    ForEach(table.rotation == .normal ? table.topSeats : table.bottomSeats) { _ in
                        HalfRoundedRectangle(.top, cornerRadius: table.seatAndTabletopCornerRadius)
                            .fill(Table.seatFill)
                            .frame(width: table.normalSeatWidth, height: table.normalSeatHeight)
                        Spacer(minLength: 1)
                    }
                    // This table prevents the view from looking strange when there is no bottom seat, because the layout expects that there is always one.
                    if table.bottomSeats.isEmpty && table.rotation == .right {
                        HalfRoundedRectangle(.top, cornerRadius: table.seatAndTabletopCornerRadius)
                            .fill(Table.seatFill)
                            .frame(width: table.normalSeatWidth, height: table.normalSeatHeight)
                            .opacity(0)
                    }
                }
                
                RoundedRectangle(cornerRadius: table.seatAndTabletopCornerRadius)
                    .fill(Table.tableFill)
                
                HStack {
                    Spacer(minLength: 1)
                    ForEach(table.rotation == .normal ? table.bottomSeats : table.topSeats) { _ in
                        HalfRoundedRectangle(.bottom, cornerRadius: table.seatAndTabletopCornerRadius)
                            .fill(Table.seatFill)
                            .frame(width: table.normalSeatWidth, height: table.normalSeatHeight)
                        Spacer(minLength: 1)
                    }
                    // This table prevents the view from looking strange when there is no bottom seat, because the layout expects that there is always one.
                    if table.bottomSeats.isEmpty && table.rotation == .normal {
                        HalfRoundedRectangle(.bottom, cornerRadius: table.seatAndTabletopCornerRadius)
                            .fill(Table.seatFill)
                            .frame(width: table.normalSeatWidth, height: table.normalSeatHeight)
                            .opacity(0)
                    }
                }
            }
            
            if (table.rotation == .normal && table.rightHeadSeat != nil) || (table.rotation == .right && table.leftHeadSeat != nil) {
                HalfRoundedRectangle(.trailing, cornerRadius: table.seatAndTabletopCornerRadius)
                    .fill(Table.seatFill)
                    .frame(width: table.normalSeatHeight, height: table.normalSeatWidth)
                    .frame(height: table.height)
            }
        }
    }
    
    // MARK: - Vertical Table
    var verticalTable: some View {
        VStack(spacing: 0) {
            if (table.rotation == .up && table.leftHeadSeat != nil) || (table.rotation == .down && table.rightHeadSeat != nil) {
                HalfRoundedRectangle(.top, cornerRadius: table.seatAndTabletopCornerRadius)
                    .fill(Table.seatFill)
                    .frame(width: table.normalSeatWidth, height: table.normalSeatHeight)
                    .frame(width: table.width)
            }
            
            HStack(spacing: 0) {
                VStack {
                    Spacer(minLength: 1)
                    ForEach(table.rotation == .up ? table.bottomSeats : table.topSeats) { _ in
                        HalfRoundedRectangle(.leading, cornerRadius: table.seatAndTabletopCornerRadius)
                            .fill(Table.seatFill)
                            .frame(width: table.normalSeatHeight, height: table.normalSeatWidth)
                        Spacer(minLength: 1)
                    }
                    // This table prevents the view from looking strange when there is no bottom seat, because the layout expects that there is always one.
                    if table.bottomSeats.isEmpty && table.rotation == .up {
                        HalfRoundedRectangle(.leading, cornerRadius: table.seatAndTabletopCornerRadius)
                            .fill(Table.seatFill)
                            .frame(width: table.normalSeatHeight, height: table.normalSeatWidth)
                            .opacity(0)
                    }
                }
                
                RoundedRectangle(cornerRadius: table.seatAndTabletopCornerRadius)
                    .fill(Table.tableFill)
                
                VStack {
                    Spacer(minLength: 1)
                    ForEach(table.rotation == .up ? table.topSeats : table.bottomSeats) { _ in
                        HalfRoundedRectangle(.trailing, cornerRadius: table.seatAndTabletopCornerRadius)
                            .fill(Table.seatFill)
                            .frame(width: table.normalSeatHeight, height: table.normalSeatWidth)
                        Spacer(minLength: 1)
                    }
                    // This table prevents the view from looking strange when there is no bottom seat, because the layout expects that there is always one.
                    if table.bottomSeats.isEmpty && table.rotation == .down {
                        HalfRoundedRectangle(.leading, cornerRadius: table.seatAndTabletopCornerRadius)
                            .fill(Table.seatFill)
                            .frame(width: table.normalSeatHeight, height: table.normalSeatWidth)
                            .opacity(0)
                    }
                }
            }
            
            if (table.rotation == .down && table.leftHeadSeat != nil) || (table.rotation == .up && table.rightHeadSeat != nil) {
                HalfRoundedRectangle(.bottom, cornerRadius: table.seatAndTabletopCornerRadius)
                    .fill(Table.seatFill)
                    .frame(width: table.normalSeatWidth, height: table.normalSeatHeight)
                    .frame(width: table.width)
            }
        }
    }
}


// MARK: - Previews
struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        TableView(
            table: .example(seatCount: 5, sideSeats: true, rotation: .normal)
        )
        .previewLayout(.sizeThatFits)
    }
}

