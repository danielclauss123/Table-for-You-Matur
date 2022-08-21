import SwiftUI

/// The normal opening hours of a restaurant.
struct OpeningHours: Codable, Equatable {
    let isOpenNow: Bool
    let open: [DayHours]
    
    var todaysHours: [DayHours] {
        hours(forWeekday: Weekday.today)
    }
    
    func hours(forWeekday weekday: Weekday) -> [DayHours] {
        open.filter { $0.weekday == weekday }
    }
    
    func isOpenOnWeekday(ofDate date: Date) -> Bool {
        guard let weekday = Weekday(fromDate: date) else {
            return false
        }
        
        return !hours(forWeekday: weekday).isEmpty
    }
    
    func isOpenOnTime(ofDate date: Date) -> Bool {
        guard let weekday = Weekday(fromDate: date), let start = Time(date: date) else {
            return false
        }
        
        // The normal customer takes 2 hours so the end time is start + 2 hours.
        let end = Time(hour: start.hour + 2, minute: start.minute, second: start.second)
        
        let hoursOfWeekday = hours(forWeekday: weekday)
        let hoursOfDayBefore = hours(forWeekday: weekday.before)
        
        for hour in hoursOfWeekday {
            guard let openingTime = hour.openingTime, var closingTime = hour.closingTime else {
                continue
            }
            
            // Midnight is 00:00, but for the same day.
            // The calculations below function with midnight being 24:00 or 00:00 the next day.
            // Therefore the time gets changed to 24:00.
            if hour.end == "0000" {
                closingTime = Time(hour: 24, minute: 0, second: 0)
            }
            
            // Example: 22:00 - 05:00 -> 22:00 - 27:00
            if hour.isOvernight {
                closingTime.hour += 24
            }
            
            // Example: Start at 23:00, End at 23:00 + 2h = 25:00
            //          End < 27:00, because End were 01:00 next day, but closing time is 05:00 next day.
            if start >= openingTime && end <= closingTime {
                return true
            } else {
                continue
            }
        }
        
        for hour in hoursOfDayBefore {
            // Example: Sunday 22:00 - 05:00 -> Open Monday 00:00 - 05:00
            guard hour.isOvernight, let closingTime = hour.closingTime else {
                continue
            }
            
            if end <= closingTime {
                return true
            } else {
                continue
            }
        }
        
        return false
    }
}
