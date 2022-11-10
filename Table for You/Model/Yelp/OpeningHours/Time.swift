import Foundation

/// A struct storing time for one day.
struct Time: Comparable {
    var hour: Int
    var minute: Int
    var second: Int
    
    init(hour: Int, minute: Int, second: Int) {
        self.hour = hour
        self.minute = minute
        self.second = second
    }
    
    init?(date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        
        guard let hour = components.hour, let minute = components.minute else {
            return nil
        }
        
        self.hour = hour
        self.minute = minute
        
        if let second = components.second {
            self.second = second
        } else {
            self.second = 0
        }
    }
    
    var inSeconds: Int {
        hour * 3600 + minute * 60 + second
    }
    
    static func < (lhs: Time, rhs: Time) -> Bool {
        lhs.inSeconds < rhs.inSeconds
    }
}
