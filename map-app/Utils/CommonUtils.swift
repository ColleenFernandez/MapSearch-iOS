//
//  CommonUtils.swift
//  map-app
//
//  Created by Admin on 11/2/21.
//

import Foundation

func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}


func getDiffTimestamp(_ tstamp: String) -> String {
    let diff = Int(NSDate().timeIntervalSince1970 - TimeInterval(tstamp)!)
    let month = diff / 30 / 24 / 3600
    let day = diff / 24 / 3600
    let hour = diff / 3600
    let min = diff / 60
    let sec = diff
    if month >= 1{
        return "\(month)月の前"
    }else if day >= 1{
        return "\(day)日前"
    }else if hour >= 1{
        return "\(hour)時間前"
    }else if min >= 1{
        return "\(min)数分前"
    }else{
        return "\(sec)秒前"
    }
}

func dayDifference(from interval : TimeInterval) -> Int{
    // return value 0: within today, 1: within this year, 2: within last year
    let calendar = Calendar.current
    let date = Date(timeIntervalSince1970: interval)
    if calendar.isDateInToday(date) { return 0 }else {
        if date.year == Date().year{
            return 1
        }else{
            return 2
        }
    }
}

func getStrDateVariousTimeFormat(_ tstamp: String) -> String {
    let date: Date? = Date(timeIntervalSince1970: TimeInterval(tstamp)!)
    let num = dayDifference(from: TimeInterval(tstamp)!)
    var strDate: String = ""
    let dateFormatter = DateFormatter()
    dateFormatter.locale = NSLocale.current
    if num == 0{
        dateFormatter.dateFormat = "HH:mm"
    }else if num == 1{
        dateFormatter.dateFormat = "MM/dd"
    }else{
        dateFormatter.dateFormat = "yyyy/MM/dd"
    }
    strDate = dateFormatter.string(from: date ?? Date())
    return strDate
}
