//
//  Helper.swift
//  Reminder
//
//  Created by Karthi Ponnusamy on 4/5/17.
//  Copyright © 2017 Karthi Ponnusamy. All rights reserved.
//

import Foundation
import UserNotifications
import CoreData
import UserNotifications
import UIKit

class Helper{

    static var monthNames = ["January", "February", "March", "April", "May", "June",
                             "July", "August", "September", "October", "November", "December"
    ];
    
    static let REMINDER_BEFORE_NO_OF_DAYS = 5
    static let REMINDER_HOUR = 08
    static let REMINDER_MINUTE = 30
    let defaults = UserDefaults.standard
    
    static let applicationDocumentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }()
    
    static func getCurrentYear() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year = components.year
        return year!
    }
    
    static func getComponentFrom(date: Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day], from: date)
    }

    
    static func getDateFromMonthAndDay(month: Int, day: Int, isNextYear: Bool) -> Date {
        var components = DateComponents()
        components.year = getCurrentYear()
        if isNextYear {
            components.year = components.year! + 1
        }
        
        components.month = month
        components.day = day
        components.hour = 8
        components.timeZone = TimeZone(abbreviation: "GMT")
        
        let birthdayDate = Calendar.current.date(from: components)!
        return birthdayDate
    }
    
    static func calcuateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        
        return end - start
    }

    static func getDateStringFromDate(_ date: Date) -> String! {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    static func getNextBirthday(day:Int, month:Int, year:Int) -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        
        components.year = year
        components.month = month
        components.day = day
        components.hour = 8
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(abbreviation: "GMT")

        return gregorian.date(from: components)!
    }
    
    static func getFistReminderDate(birhday:Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: -REMINDER_BEFORE_NO_OF_DAYS, to: birhday)!
    }
    
   
    
    static func randomString(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
   
    static func getReminder2TimeFromDefaults(timeVal:Date) -> (Int, Int) {
        var timing = (hour: Helper.REMINDER_HOUR, minute: Helper.REMINDER_MINUTE)
        let reminderDate2 = timeVal
        if reminderDate2 != nil {
            let calendar = Calendar.current
            let component = calendar.dateComponents([.hour, .minute], from: reminderDate2)
            timing.hour = component.hour!
            timing.minute = component.minute!
        }
        return timing
    }
    
    static func getReminder1TimeFromDefaults() -> (Int, Int) {
        var timing = (hour: Helper.REMINDER_HOUR, minute: Helper.REMINDER_MINUTE)
        let reminderDate1 = UserDefaults.standard.object(forKey:"ReminderDate2") as? Date
        if reminderDate1 != nil {
            let calendar = Calendar.current
            let component = calendar.dateComponents([.hour, .minute], from: reminderDate1!)
            timing.hour = component.hour!
            timing.minute = component.minute!
        }
        return timing
    }
    
    
    
    static func getReminder1FireDate(nextBirthDayObj:Date) -> Date {
        var noOfDays = UserDefaults.standard.object(forKey:"DaysBefore") as? Int
        if noOfDays == nil {
            noOfDays = REMINDER_BEFORE_NO_OF_DAYS
        }
        
        return Calendar.current.date(byAdding: .day, value: -noOfDays!, to: nextBirthDayObj)!
    }
  
    
    static func convertTimeFormat(inputDate: String) -> String {

         let olDateFormatter = DateFormatter()
         olDateFormatter.dateFormat = "h:m:ss a"

         let oldDate = olDateFormatter.date(from: inputDate)

         let convertDateFormatter = DateFormatter()
         convertDateFormatter.dateFormat = "hh:mm:ss a"

         return convertDateFormatter.string(from: oldDate!)
    }
    
    static func convertTime24Format(inputDate: String) -> String {

        let olDateFormatter = DateFormatter()
         olDateFormatter.dateFormat = "hh:mm:ss a"

         let oldDate = olDateFormatter.date(from: inputDate)

         let convertDateFormatter = DateFormatter()
         convertDateFormatter.dateFormat = "HH:mm:ss"

         return convertDateFormatter.string(from: oldDate!)
    }
    
    static func convertTime12Format(inputDate: String) -> String {

        let olDateFormatter = DateFormatter()
         olDateFormatter.dateFormat = "HH:mm:ss"

         let oldDate = olDateFormatter.date(from: inputDate)

         let convertDateFormatter = DateFormatter()
         convertDateFormatter.dateFormat = "hh:mm:ss a"

         return convertDateFormatter.string(from: oldDate!)
    }
    
    static func convertDateFormat(inputDate: String) -> String {

         let olDateFormatter = DateFormatter()
         olDateFormatter.dateFormat = "MMM d, yyyy"

         let oldDate = olDateFormatter.date(from: inputDate)

         let convertDateFormatter = DateFormatter()
         convertDateFormatter.dateFormat = "dd/MM/yyyy"

         return convertDateFormatter.string(from: oldDate!)
    }
    
    static func convertCausalDateFormat(inputDate: String) -> String {

         let olDateFormatter = DateFormatter()
         olDateFormatter.dateFormat = "dd/MM/yyyy"

         let oldDate = olDateFormatter.date(from: inputDate)

         let convertDateFormatter = DateFormatter()
         convertDateFormatter.dateFormat = "MMM d, yyyy"

         return convertDateFormatter.string(from: oldDate!)
    }
    
    static func convertStringToDate(str:String) -> Date{
        let olDateFormatter = DateFormatter()
        olDateFormatter.dateFormat = "dd/MM/yyyy"

        guard let oldDate = olDateFormatter.date(from: str) else { return Date()}
        return oldDate
    }

    
   
    
    static func convertStringToTime(str:String) -> Date{
        let olDTimeFormatter = DateFormatter()
        if hasAMPM == true
        {
            olDTimeFormatter.dateFormat = "hh:mm:ss a"
            if olDTimeFormatter.date(from: "\(str)") != nil {
                let oldDate = olDTimeFormatter.date(from: "\(str)")
                return oldDate!
            } else {
                olDTimeFormatter.dateFormat = "HH:mm:ss"
                let oldDate = olDTimeFormatter.date(from: "\(str)")
                return oldDate!
            }
        }
        else{
            olDTimeFormatter.dateFormat = "HH:mm:ss"
        }
        let oldDate = olDTimeFormatter.date(from: "\(str)")
        return oldDate!
    }
    
    static func getFormatedTime(date: Date) -> String {
        /*
        let calendar = Calendar.current
        let component = calendar.dateComponents([.hour, .minute], from: date)
        return "\(component.hour!) : \(component.minute!)"
         */
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    static func getBorderColor() -> UIColor {
        let borderColor: UIColor = UIColor( red: CGFloat(252/255.0), green: CGFloat(131/255.0), blue: CGFloat(127/255.0), alpha: CGFloat(1.0))
        return borderColor
    }
    
}

func convertStringToDateforInApp(inputDate: Date) -> String {
    
    let convertDateFormatter = DateFormatter()
    convertDateFormatter.dateFormat = "dd MMMM yyyy"
    
    let myStr = convertDateFormatter.string(from: inputDate)
    let myDate = convertDateFormatter.date(from: myStr)
    let myStrDate = convertDateFormatter.string(from: myDate!)
    return myStrDate
    
    
}

func getexpirydate()  -> String{
    let monthsToAdd = 1
    var transactiondate = Helper.convertStringToDate(str:  Defaults.string(forKey: "StartDate") ?? "")
    var newDate = Calendar.current.date(byAdding: .year, value: monthsToAdd, to: transactiondate)
    if Defaults.string(forKey: "prductID") == "com.erasoft.WebWhatsApp.monthly" {
         newDate = Calendar.current.date(byAdding: .month, value: monthsToAdd, to: transactiondate)
    }
    print( convertStringToDateforInApp(inputDate: newDate ?? Date()))
    return convertStringToDateforInApp(inputDate: newDate ?? Date())
    
    
}
