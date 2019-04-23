//
// Created by Aleksandr Suslov on 2019-04-23.
// Copyright (c) 2019 Alexander. All rights reserved.
//

import Foundation


public enum ApiError: Error {
    case wrongResponse
    case unknownError
    case outOfStock
}


public struct Entry {
    let dt: Date
    let value: Float
    let direction: Direction
}

public enum Direction: String, CaseIterable {
    case DoubleUp = "⇈"
    case SingleUp = "↑"
    case FortyFiveUp = "↗"
    case Flat = "↝"
    case FortyFiveDown = "↘"
    case SingleDown = "↓"
    case DoubleDown = "⇊"
    case Unknown = "?"

    static func parse(_ label: String) -> Direction {
        return self.allCases.first {
            "\($0)" == label
        } ?? Unknown
    }
}


public class Api {
    private let host = "https://mike2015.herokuapp.com"
    private let session =  URLSession.shared

    public func lastEntries(_ handler: @escaping ([Entry]) -> Void, _ errorHandler: @escaping (Error) -> Void) {

        let url = URL(string: host + "/api/v1/entries.json")!
        let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)

        let dataTask = session.dataTask(with: req, completionHandler: { (data, response, error) -> Void in


            do {
                if (data != nil) {
                    let res = response as! HTTPURLResponse
                    if (res.statusCode == 200) {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String: Any]]
                        let result = self.parseEntries(json: json)

                        handler(result)
                    } else {
                        errorHandler(ApiError.wrongResponse)
                    }
                } else {
                    errorHandler(error ?? ApiError.unknownError)
                }
            } catch let error {
                errorHandler(error)
            }
        })

        dataTask.resume()
    }


    private func parseEntries(json: [[String: Any]]) -> [Entry] {
        var records = [Entry]()

        for r in json {
            if (r["type"] as! String != "sgv") {
                continue
            }

            let value = r["sgv"] as! Float / 18
            //todo maybe need to use 'noise'

            let rec = Entry(
                    dt: Date(timeIntervalSince1970: r["date"] as! Double / 1000),
                    value: value,
                    direction: Direction.parse(r["direction"] as! String)
            )
            records.append(rec)
        }

        return records
    }

}
