//
//  FlyBy.swift
//  HowdyISS
//
//  Created by Me on 12/3/18.
//  Copyright © 2018 Ross Co. All rights reserved.
//

import Foundation

class FlyBy {

    let unixTime: Int;
    let duration: Int;
    let formatter = DateComponentsFormatter()
    
    init(unixTime: Int, duration: Int) {
        self.unixTime = unixTime
        self.duration = duration

        formatter.allowedUnits = [.hour, .day, .minute]
        formatter.unitsStyle = .full
        
    }
    
    /// Returs true if another FlyBy is the same as this one
    func isSameAs(other: FlyBy) -> Bool {
        return unixTime == other.unixTime && duration == other.duration
    }
    
    /// Parses Unix time to Date
    func parseDate(when: Int) -> Date {
        return Date(timeIntervalSince1970: Double(when))
    }

    /// Returns the seconds until the flyby occurs
    func secUntilOccurs() -> Double {
        return parseDate(when: self.unixTime).timeIntervalSince(Date())
    }
    
    ///Returns the minutes until the flyby occurs
    func minUntilOccurs() -> Int {
        return Int(secUntilOccurs() / 60.0)
    }
    
    /// Returns a nicely formatted string of when the flyby will occur
    func prettyWhen() -> String {
        return formatter.string(from: secUntilOccurs())!
    }
    
    /// Returns a nicely formatted string of the duration of the flyby
    func prettyDuration() -> String {
        return "\(duration/60) minutes"
    }
    
    
}

