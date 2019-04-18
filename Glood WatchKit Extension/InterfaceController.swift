//
//  InterfaceController.swift
//  Glood WatchKit Extension
//
//  Created by Alexander on 16/04/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import WatchKit
import Foundation


let ok = UIColor(red: 4 / 255, green: 222 / 225, blue: 113 / 225, alpha: 1)
let warning = UIColor(red: 255 / 255, green: 230 / 225, blue: 32 / 225, alpha: 1)
let danger = UIColor(red: 255 / 255, green: 59 / 225, blue: 48 / 225, alpha: 1)


struct Rec {
    let color: UIColor
    let dt: Date
    let value: Float
    let direction: String
}


class InterfaceController: WKInterfaceController {

    let wrongColor = UIColor(red: 194 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1)

    @IBOutlet weak var tbl: WKInterfaceTable!

    @IBOutlet weak var errorLbl: WKInterfaceLabel!

    private var records = [Rec]()

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
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("willActivate")
//        loadLast()

        loadList()

    }

//    private func loadLast() {
//        let url = URL(string: "https://mike2015.herokuapp.com/api/v1/entries/current.json")!
//
//        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
//            self.handleResponse(data: data!)
//        })
//
//        dataTask.resume()
//    }

    private func loadList() {

        updateStatus(txt: "Loading ...", color: UIColor.white)
        let url = URL(string: "https://mike2015.herokuapp.com/api/v1/entries.json")!

        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in


            if (data != nil) {
                let res = response as! HTTPURLResponse
                if (res.statusCode == 200) {

                    self.handleResponse2(data: data!)
                } else {
                    self.updateStatus(txt: "Wrong response", color: UIColor.red)
                }
            } else {
                self.updateStatus(txt: "Fatal error", color: UIColor.red)
            }

        })

        dataTask.resume()
    }


    func updateStatus(txt: String, color: UIColor) {
        DispatchQueue.main.async {
            self.errorLbl.setTextColor(color)
            self.errorLbl.setText(txt)
        }
    }

    func handleResponse2(data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]


            for r in json {
                let value = r["sgv"] as! Float / 18
                //todo maybe need to use 'noise'

                let color: UIColor


                if (value < 6) {
                    color = ok
                } else if (value < 6.5) {
                    color = warning
                } else {
                    color = danger
                }

                let rec = Rec(
                        color: color,
                        dt: Date(timeIntervalSince1970: r["date"] as! Double / 1000),
                        value: value,
                        direction: r["direction"] as! String
                )
                records.append(rec)
            }

            DispatchQueue.main.async {
                self.errorLbl.setHidden(true)
                self.updateTable()
            }


        } catch {
            print(error)
        }
    }

    func updateTable() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm MMM dd"
        tbl.setNumberOfRows(records.count, withRowType: "Row")
        for (i, item) in records.enumerated() {
            if let row = tbl.rowController(at: i) as? Row {
                let dir = toDirSymbol(dir: item.direction)

                row.row.setBackgroundColor(item.color.withAlphaComponent(0.14))

                row.direction.setText(dir)
                row.direction.setTextColor(item.color)

                row.value.setText(String(format: "%.1f", arguments: [item.value]))
                row.value.setTextColor(item.color)

                row.time.setText(formatter.string(from: item.dt))
                row.time.setTextColor(item.color)
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
