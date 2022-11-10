import SwiftUI

struct AllHoursView: View {
    let openingHours: OpeningHours
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Weekday.allCases.filter { $0 != .unknown }) { weekday in
                HStack(alignment: .top) {
                    Text(weekday.name)
                    
                    Spacer()
                    
                    DayHoursView(dayHours: openingHours.hours(forWeekday: weekday))
                        .font(.headline)
                }
                .padding(.top, 5)
            }
        }
    }
}


// MARK: - Previews
struct AllHoursView_Previews: PreviewProvider {
    static var previews: some View {
        AllHoursView(openingHours: .example)
    }
}
