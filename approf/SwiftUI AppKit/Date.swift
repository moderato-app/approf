// Created for approf in 2024

import Foundation

extension Date {
  func isToday() -> Bool {
    return Calendar.current.isDateInToday(self)
  }

  func isYesterday() -> Bool {
    return Calendar.current.isDateInYesterday(self)
  }

  func humanReadable(_ includeTime: Bool = true) -> String {
    var text = ""
    if isToday() {
      text = "Today"
    } else if isYesterday() {
      text = "Yesterday"
    } else {
      text = formatted(date: .abbreviated, time: .omitted)
    }

    if includeTime {
      return text + " " + formatted(date: .omitted, time: .shortened)
    }
    return text
  }
}
