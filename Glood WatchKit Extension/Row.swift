//
// Created by Aleksandr Suslov on 2019-04-17.
// Copyright (c) 2019 Alexander. All rights reserved.
//

import WatchKit

class Row: NSObject {
    @IBOutlet weak var row: WKInterfaceGroup!
    @IBOutlet weak var direction: WKInterfaceLabel!
    @IBOutlet weak var value: WKInterfaceLabel!
    @IBOutlet weak var time: WKInterfaceLabel!
}
