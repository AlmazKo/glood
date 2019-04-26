//
//  InterfaceController.swift
//  Glood WatchKit Extension
//
//  Created by Alexander on 16/04/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

let ok = UIColor(red: 4 / 255, green: 222 / 225, blue: 113 / 225, alpha: 1)
let warning = UIColor(red: 255 / 255, green: 230 / 225, blue: 32 / 225, alpha: 1)
let danger = UIColor(red: 255 / 255, green: 59 / 225, blue: 48 / 225, alpha: 1)
let wrongColor = UIColor(red: 194 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1)
let treatmentSym = "💉"


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var tbl: WKInterfaceTable!
    @IBOutlet weak var errorLbl: WKInterfaceLabel!

    let api = Api()
    let healthStore = HKHealthStore()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("History")
    }

    @IBAction func onClick() {
        WKInterfaceDevice.current().play(.success)
        print("onClick")
//
//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
//            print("FIRE!!!")
//            WKInterfaceDevice.current().play(.success)
//        })
    }

    override func willActivate() {
        super.willActivate()

        loadList()
    }

    private func loadList() {
        updateStatus(txt: "Loading ...", color: UIColor.white)
        api.lastEntries({ data -> Void in
            DispatchQueue.main.async {
                self.errorLbl.setHidden(true)
                self.updateTable(data)
            }

        }, { error -> Void in
            self.updateStatus(txt: "\(error)", color: UIColor.red)
        })
    }

    func updateStatus(txt: String, color: UIColor) {
        DispatchQueue.main.async {
            self.errorLbl.setTextColor(color)
            self.errorLbl.setText(txt)
        }
    }

    func updateTable(_ data: [Entry]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        tbl.setNumberOfRows(data.count, withRowType: "Row")

        for (i, e) in data.enumerated() {
            if let row = tbl.rowController(at: i) as? Row {

                row.row.setBackgroundColor(e.fontColor().withAlphaComponent(0.14))

                row.direction.setText(e.direction.rawValue)
                row.direction.setTextColor(e.fontColor())

                row.value.setText(String(format: "%.1f", arguments: [e.value]))
                row.value.setTextColor(e.fontColor())

                row.time.setText(formatter.string(from: e.dt))
                row.time.setTextColor(e.fontColor())
            }
        }
    }

    func updateTable(_ data: [Treatment]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        tbl.setNumberOfRows(data.count, withRowType: "Row")

        for (i, e) in data.enumerated() {
            if let row = tbl.rowController(at: i) as? Row {
                row.direction.setText(treatmentSym)
                row.value.setText(String(format: "%.2f", arguments: [e.insulin]))
                row.time.setText(formatter.string(from: e.dt))
            }
        }
    }

    private func toDirSymbol(dir direction: String) -> String {
        let dir: String

        switch (direction) {
        case "DoubleUp": dir = "⇈";
        case "SingleUp": dir = "↑";
        case "FortyFiveUp": dir = "↗";
        case "Flat": dir = "↝";
        case "FortyFiveDown": dir = "↘";
        case "SingleDown": dir = "↓";
        case "DoubleDown": dir = "⇊";
        default: dir = "?"
        }
        return dir
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension Entry {
    func fontColor() -> UIColor {

        switch (value) {
        case 4.5..<10: return ok;
        case 4..<4.5, 10..<11: return warning;
        default: return danger
        }
    }
}
