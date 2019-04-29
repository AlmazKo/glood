//
// Created by Aleksandr Suslov on 2019-04-23.
// Copyright (c) 2019 Alexander. All rights reserved.
//

import Foundation
import RxSwift

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
    let note: String
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

    public func lastEntries() -> Single<[Entry]> {

        return makeRequest("/api/v1/entries/svg.json?count=50")
                .map {
                    self.parseEntries($0)
                }
    }

    public func lastTreatments() -> Single<[Treatment]> {

        return makeRequest("/api/v1/treatments.json?count=50")
                .map {
                   try self.parseTreatments($0)
                }
    }


    private func parseEntries(_ json: [[String: Any]]) -> [Entry] {
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


    private func parseTreatments(_ json: [[String: Any]]) -> [Treatment] {
        var records = [Treatment]()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        for r in json {
            let d =  r["created_at"] as! String
            let rec = Treatment(
                    dt: dateFormatter.date(from: d)!,
                    note: r["notes"] as? String ?? "",
                    insulin: r["insulin"] as? Float ?? 0,
                    carbs: r["carbs"] as? Float ?? 0
            )
            records.append(rec)
        }

        return records
    }


    private func makeRequest(_ path: String) -> Single<[[String: Any]]> {

        let url = URL(string: host + path)!
        let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)

        return Single<[[String: Any]]>.create { single in
            let task = URLSession.shared.dataTask(with: req, completionHandler: { data, response, error in
                if let error = error {
                    single(.error(error))
                    return
                }

                let res = response as! HTTPURLResponse
                if (res.statusCode != 200) {
                    single(.error(ApiError.unknownError))
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                      let result = json as? [[String: Any]] else {

                    single(.error(ApiError.wrongResponse))
                    return
                }

                single(.success(result))
            })

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }


//
//
//        session.dataTask(with: req, completionHandler: { (data, response, error) -> Void in
//            if (data != nil) {
//                let res = response as! HTTPURLResponse
//                if (res.statusCode == 200) {
//                    handler(data!)
//                } else {
//                    errorHandler(ApiError.wrongResponse)
//                }
//            } else {
//                errorHandler(error ?? ApiError.unknownError)
//            }
//
//        }).resume()
    }
}
