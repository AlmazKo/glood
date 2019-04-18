//
//  ComplicationController.swift
//  cnt4 WatchKit Extension
//
//  Created by Alexander on 16/04/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//


import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {

    let tintColor = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)

    // MARK: - Timeline Configuration

    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward])
    }

    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }

    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }

    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
//        // Call the handler with the current timeline entry
        // let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        let dt = Date().addingTimeInterval(TimeInterval(3600))
        let timeString = dateFormatter.string(from: dt)

        switch complication.family {
        case .modularLarge:
            let tpl = CLKComplicationTemplateModularLargeTallBody()
            tpl.headerTextProvider = CLKSimpleTextProvider(text: "head")
            tpl.bodyTextProvider = CLKSimpleTextProvider(text: dateFormatter.string(from: dt))
            let entry = CLKComplicationTimelineEntry(date: dt, complicationTemplate: tpl)
            handler(entry)

        case .modularSmall:
            let tpl = CLKComplicationTemplateModularSmallSimpleText()
            tpl.textProvider = CLKSimpleTextProvider(text: "ms")
            let entry = CLKComplicationTimelineEntry(date: dt, complicationTemplate: tpl)
            handler(entry)

        case .circularSmall:
            let tpl = CLKComplicationTemplateCircularSmallRingText()
            tpl.textProvider = CLKSimpleTextProvider(text: "6")
            tpl.ringStyle = .closed
            tpl.fillFraction = 0.33
            let entry = CLKComplicationTimelineEntry(date: dt, complicationTemplate: tpl)
            handler(entry)

        default:
            handler(nil)
        }

    }

    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        handler(nil)
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        var timeLineEntryArray = [CLKComplicationTimelineEntry]()
//        var nextDate = Date(timeIntervalSinceNow: 1 * 60 * 60)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "hh:mm"
//
//        for index in 1...3 {
//
//            let timeString = dateFormatter.string(from: nextDate)
//            let entry = createTimeLineEntry(headerText: timeString, bodyText: timeLineText[index], date: nextDate)
//            timeLineEntryArray.append(entry)
//            nextDate = nextDate.addingTimeInterval(1 * 60 * 60)
//        }
        handler(timeLineEntryArray)
    }

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = getLocalizableSampleTemplate(for: complication.family)
        handler(template)
    }

//
    func getLocalizableSampleTemplate(for family: CLKComplicationFamily) -> CLKComplicationTemplate? {

        switch family {

        case .modularLarge:
            let tpl = CLKComplicationTemplateModularLargeTallBody()
            tpl.headerTextProvider = CLKSimpleTextProvider(text: "head")
            tpl.bodyTextProvider = CLKSimpleTextProvider(text: "222:22")

            return tpl

        case .modularSmall:
            let tpl = CLKComplicationTemplateModularSmallSimpleText()
            tpl.textProvider = CLKSimpleTextProvider(text: "62")

            return tpl

        case .circularSmall:
            let tpl = CLKComplicationTemplateCircularSmallRingText()
            tpl.textProvider = CLKSimpleTextProvider(text: "6")
            tpl.ringStyle = .closed
            tpl.fillFraction = 0.33
            return tpl

        default:
            return nil
        }
    }

    func createTimeLineEntry(headerText: String, bodyText: String, date: Date) -> CLKComplicationTimelineEntry {

        let tpl = CLKComplicationTemplateModularLargeTallBody()

        tpl.headerTextProvider = CLKSimpleTextProvider(text: headerText)
        tpl.bodyTextProvider = CLKSimpleTextProvider(text: bodyText)

        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: tpl)

        return (entry)
    }

}
