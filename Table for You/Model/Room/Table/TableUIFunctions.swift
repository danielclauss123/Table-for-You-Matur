import SwiftUI

// MARK: - Constant Static Properties
extension Table {
    /// The height of a normal table view with the seats and tabletop.
    static private let normalHeight = 80.0
    /// The percentage of the height that gets filled by the tabletop.
    static private let tabletopHeightPercentage = 0.7
    /// The percentage of the height that gets filled by one seat.
    static private var seatHeightPercentage: Double {
        (1 - tabletopHeightPercentage) / 2
    }
}

// MARK: - Variable Properties
extension Table {
    /// How much bigger the width is in comparison to the height of the tabletop.
    ///
    /// This is always an Int, because the tabletop is maid out a as many squares as this property suggests.
    /// Exp: If this property is 5, the table is 5 times as wide as high, so it consist of 5 equal squares.
    private var tabletopNormalWidthToHeightRatio: Int {
        if headSeatsEnabled {
            return seats.count > 4 ? max(Int(Double(seats.count - 2 + 1) / 2), 1) : 1
        } else {
            return max(Int(Double(seats.count + 1) / 2), 1)
        }
    }
    
    /// The normal width in the horizontal position with the tabletop and, if present, the side seats.
    private var normalWidth: Double {
        let combinedHeadSeatWidth: Double
        if rightHeadSeat != nil {
            combinedHeadSeatWidth = Self.normalHeight * Self.seatHeightPercentage * 2
        } else if leftHeadSeat != nil {
            combinedHeadSeatWidth = Self.normalHeight * Self.seatHeightPercentage * 1
        } else {
            combinedHeadSeatWidth = 0
        }
        
        let tabletopWidth = Self.normalHeight * Self.tabletopHeightPercentage * Double(tabletopNormalWidthToHeightRatio)
        
        return tabletopWidth + combinedHeadSeatWidth
    }
}

// MARK: - Frame
extension Table {
    /// The height for the complete table view. It changes according to the rotation.
    var height: Double {
        if rotation == .normal || rotation == .right {
            return Self.normalHeight
        } else {
            return normalWidth
        }
    }
    
    /// The width for the complete table view. It changes according to the rotation.
    var width: Double {
        if rotation == .normal || rotation == .right {
            return normalWidth
        } else {
            return Self.normalHeight
        }
    }
}

// MARK: - Seat Frame
extension Table {
    /// The seat width is 3 / 4 of the width of one square of  tabletop, that means 3 / 4 of the height of the tabletop.
    ///
    /// This gets used when the seat is in its normal, horizontal position.
    var normalSeatWidth: Double {
        Self.normalHeight * Self.tabletopHeightPercentage * 0.75
    }
    
    /// The normal height times the seat height percentage.
    ///
    /// This gets used when the seat is in its normal, horizontal position.
    var normalSeatHeight: Double {
        Self.normalHeight * Self.seatHeightPercentage
    }
}

// MARK: - Seat and Tabletop Corner Radius
extension Table {
    var seatAndTabletopCornerRadius: Double {
        Self.normalHeight * 0.1
    }
}

// MARK: - Color
extension Table {
    static let seatFill = Color.blue
    static let tableFill = LinearGradient(colors: [.indigo, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
}
