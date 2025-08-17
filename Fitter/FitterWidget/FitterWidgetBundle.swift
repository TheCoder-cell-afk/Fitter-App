//
//  FitterWidgetBundle.swift
//  FitterWidget
//
//  Created by Jabir Ould Mohamed on 7/15/25.
//

import WidgetKit
import SwiftUI

@main
struct FitterWidgetBundle: WidgetBundle {
    var body: some Widget {
        FitterWidget()
        FitterWidgetControl()
        FitterWidgetLiveActivity()
    }
}
