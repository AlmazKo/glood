//
//  ViewController.swift
//  Glood
//
//  Created by Alexander on 16/04/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit
import RxSwift

import EventKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    let api = Api()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        loadLast()


/*        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(store: eventStore)
        case .denied:
            print("Access denied")
        case .notDetermined:
            // 3
            eventStore.requestAccess(to: .event, completion:
                {[weak self] (granted: Bool, error: Error?) -> Void in
                    if granted {
                        self!.insertEvent(store: eventStore)
                    } else {
                        print("Access denied")
                    }
            })
        default:
            print("Case default")
        }*/
    }

    func insertEvent(store: EKEventStore) {
        // 1
        let calendars = store.calendars(for: .event)

        for calendar in calendars {
            // 2
            if calendar.title == "Spike3" {


//                store.event(withIdentifier: "Gloodd")
                // 3
                let startDate = Date()
                // 2 hours
                let endDate = startDate.addingTimeInterval(2 * 60 * 60)

                // 4
                let event = EKEvent(eventStore: store)

                event.calendar = calendar

                event.title = "New Meeting"
                event.startDate = startDate
                event.endDate = endDate


                // 5
                do {
                    try store.save(event, span: .thisEvent)
                } catch {
                    print("Error saving event in calendar")
                }
            }
        }
    }


    private func loadLast() {
        label.text = "Loading..."
//        let url = URL(string: "https://mike2015.herokuapp.com/api/v1/entries/current.json")!
//
//        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
//            self.handleResponse(data: data!)
//        })
//
//        dataTask.resume()

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        Single.zip(api.lastEntries(), api.lastTreatments(), resultSelector: { (entries: [Entry], treatments: [Treatment]) in
                    return entries
                })


                .observeOn(MainScheduler.instance)
                .subscribe(
                        onSuccess: { entries in
                            self.label.text = "last bb: " + formatter.string(from: entries[0].dt)
                        },
                        onError: { error in
                            self.label.text = "Error "
                        })
    }

//    func handleResponse(data: Data) {
//        let formatter = DateFormatter()
//        do {
//            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
//            let date = json[0]["date"] as! Double
//            //print(date)
//
//            let dt = Date(timeIntervalSince1970: date / 1000)
//            formatter.dateFormat = "HH:mm"
//            DispatchQueue.main.async {
//                self.label.text = "last: " + formatter.string(from: dt)
//            }
//        } catch {
//            print(error)
//        }
//    }
}

