//
//  TimerView.swift
//  iTaskr
//
//  Created by Sean Cooper on 9/2/23.
//

import SwiftUI

struct TimerView: View {
    @State var startDate = Date.now
    @State var timeElapsed: Int = 0
    @State var isTimerRunning = false
    @State var timeWhenPaused = 0
    //    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @EnvironmentObject var timerModel: TimerModel
    @State private var duration = 100
    
    var timeRemaining: Int {
        return duration - timeElapsed
    }
    
    var body: some View {
        VStack {
            Text("Time remaining: \(timerModel.timerStringValue)")
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    if timerModel.isStarted{
                        timerModel.updateTimer()
                    }
                }
            Button(timerModel.isStarted ? "Stop" : "Start") {
                if timerModel.isStarted {
                    timerModel.stopTimer()
                }else {
                    timerModel.startTimer()
                }
            }
            
            
            .font(.largeTitle)
        }
    }
    
}
