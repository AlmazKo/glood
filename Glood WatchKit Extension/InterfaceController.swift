//
//  InterfaceController.swift
//  Glood WatchKit Extension
//
//  Created by Alexander on 16/04/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import WatchKit
import RxSwift
import Foundation
import HealthKit

let normal = UIColor(red: 242 / 255, green: 244 / 225, blue: 255 / 225, alpha: 1)
let ok = UIColor(red: 4 / 255, green: 222 / 225, blue: 113 / 225, alpha: 1)
let warning = UIColor(red: 255 / 255, green: 230 / 225, blue: 32 / 225, alpha: 1)
let danger = UIColor(red: 255 / 255, green: 59 / 225, blue: 48 / 225, alpha: 1)
let wrongColor = UIColor(red: 194 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1)
let treatmentSym = "💉"
let carbSym = "🍌"


public struct Record {
    let dt: Date
    let note: String
    let icon: String
    let color: UIColor
}

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

        Single.zip(api.lastEntries(), api.lastTreatments(), resultSelector: { (entries: [Entry], treatments: [Treatment]) -> [Record] in
                    return merge(entries: entries, treatments: treatments)
                })
                .observeOn(MainScheduler.instance)
                .subscribe(
                        onSuccess: { json in
                            self.errorLbl.setHidden(true)
                            self.updateTable(json)
                        },
                        onError: { error in
                            print("Error: ", error)
                        })
    }

    private func merge(entries: [Glood.Entry], treatments: [Glood.Treatment]) -> [Record] {
        var records = [Record]()
        entries.forEach { (e: Entry) in
            records.append(Record(
                    dt: e.dt,
                    note: String(format: "%.1f", arguments: [e.value]),
                    icon: e.direction.rawValue,
                    color: self.fontColor(e.value)
            )
            )
        }

        treatments.forEach { (t: Treatment) in

            let note: String
            let icon: String
            if (t.type == .correctionBolus) {
                note = String(format: "%.1f", arguments: [t.insulin])
                icon = treatmentSym
            } else if (t.type == .carbs) {
                note = String(format: "%.1f", arguments: [t.carbs])
                icon = carbSym
            } else {
                note = t.note
                icon = treatmentSym
            }
            records.append(Record(
                    dt: t.dt,
                    note: note,
                    icon: icon,
                    color: normal
            )
            )
        }

        records.sort(by: { $0.dt > $1.dt })
        return records
    }

    func updateStatus(txt: String, color: UIColor) {
        DispatchQueue.main.async {
            self.errorLbl.setTextColor(color)
            self.errorLbl.setText(txt)
        }
    }

    func updateTable(_ data: [Record]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        tbl.setNumberOfRows(data.count, withRowType: "Row")

        for (i, e) in data.enumerated() {
            if let row = tbl.rowController(at: i) as? Row {

                row.row.setBackgroundColor(e.color.withAlphaComponent(0.14))

                row.direction.setText(e.icon)
                row.direction.setTextColor(e.color)

                row.value.setText(e.note)
                row.value.setTextColor(e.color)

                row.time.setText(formatter.string(from: e.dt))
                row.time.setTextColor(e.color)
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

    func fontColor(_ value: Float) -> UIColor {

        switch (value) {
        case 4.5..<10: return ok;
        case 4..<4.5, 10..<11: return warning;
        default: return danger
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
