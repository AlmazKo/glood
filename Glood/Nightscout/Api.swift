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


public struct Treatment {
    let dt: Date
    let insulin: Float
    let carbs: Float
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
    private let session = URLSession.shared

    public func lastEntries(_ handler: @escaping ([Entry]) -> Void, _ errorHandler: @escaping (Error) -> Void) {

        makeRequest("/api/v1/entries/svg.json?count=50", { data -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                let result = self.parseEntries(json: json)
                handler(result)
            } catch {
                errorHandler(ApiError.wrongResponse)
            }

        }, errorHandler)
    }


    public func lastTreatments(_ handler: @escaping ([Treatment]) -> Void, _ errorHandler: @escaping (Error) -> Void) {

        makeRequest("/api/v1/treatments.json?count=50", { data -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                let result = self.parseTreatments(json: json)
                handler(result)
            } catch {
                errorHandler(ApiError.wrongResponse)
            }

        }, errorHandler)
    }


    private func parseEntries(json: [[String: Any]]) -> [Entry] {
        var records = [Entry]()

        for r in json {

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


    private func parseTreatments(json: [[String: Any]]) -> [Treatment] {
        var records = [Treatment]()

        for r in json {
            let rec = Treatment(
                    dt: Date(timeIntervalSince1970: r["timestamp"] as! Double / 1000),
                    insulin: r["insulin"] as? Float ?? 0,
                    carbs: r["carbs"] as? Float ?? 0
            )
            records.append(rec)
        }

        return records
    }


    private func makeRequest(_ path: String, _ handler: @escaping (Data) -> Void, _ errorHandler: @escaping (Error) -> Void) {

        let url = URL(string: host + path)!
        let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)

        session.dataTask(with: req, completionHandler: { (data, response, error) -> Void in
            if (data != nil) {
                let res = response as! HTTPURLResponse
                if (res.statusCode == 200) {
                    handler(data!)
                } else {
                    errorHandler(ApiError.wrongResponse)
                }
            } else {
                errorHandler(error ?? ApiError.unknownError)
            }

        }).resume()
    }
}
