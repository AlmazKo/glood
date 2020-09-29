//
//  ComplicationController.swift
//  cnt4 WatchKit Extension
//
//  Created by Alexander on 16/04/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//


import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    let dateFormatter = DateFormatter()
    
    let tintColor = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
    let tintColor2 = UIColor(red: 255 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
    
    let record = Record(
        dt: Date(timeIntervalSince1970: 1556745551),
        note: "2.34",
        icon: "#",
        color: UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
    )
    
    override init() {
        dateFormatter.dateFormat = "mm"
    }
    
    func getAlwaysOnTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        
        case .modularSmall:
            let tpl = CLKComplicationTemplateModularSmallRingText()
            tpl.textProvider = CLKSimpleTextProvider(text: "1")
            tpl.fillFraction = 0.9
            tpl.tintColor = .blue
            tpl.ringStyle = .closed
            handler(tpl)
            
        default:
            handler(nil)
        }
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        switch complication.family {
        
        case .modularSmall:
            let tpl = CLKComplicationTemplateModularSmallRingText()
            tpl.textProvider = CLKSimpleTextProvider(text: "4")
            tpl.fillFraction = 0.75
            tpl.tintColor = .green
            tpl.ringStyle = .closed
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: tpl)
            handler(entry)
            
        default:
            handler(nil)
        }
        
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = getLocalizableSampleTemplate(for: complication.family)
        handler(template)
    }
    
    func getLocalizableSampleTemplate(for family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        
        switch family {
        
        case .modularSmall:
            let tpl = CLKComplicationTemplateModularSmallRingText()
            tpl.textProvider = CLKSimpleTextProvider(text: "9")
            tpl.fillFraction = 0.3
            tpl.ringStyle = .closed
            tpl.tintColor = .green
            return tpl
            
        default:
            return nil
        }
    }
    
    
}
