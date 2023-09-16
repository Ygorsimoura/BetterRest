//
//  ContentView.swift
//  BetterRest
//
//  Created by Ygor Simoura on 14/09/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = DefaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var DefaultWakeTime: Date {
        var componets = DateComponents()
        componets.hour = 7
        componets.minute = 0
        return Calendar.current.date(from: componets) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
           
                Form{
                    VStack(alignment: .leading, spacing: 20){
                        Text("When do you wanna wake up?")
                            .font(.headline)
                        DatePicker("Select the time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                        
                    Section(header: Text("Desired amount of sleep") ){
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount,in: 4...12, step: 0.25)
                    }
                    
                    
                    
                    Section{
                        Picker("Daily coffe intake", selection: $coffeAmount){
                            ForEach(1...20, id: \.self){
                                Text("\($0)")
                            }
                        }
                    }

                }
                .navigationTitle("BetterRest")
                        .toolbar {
                            Button("Calculate", action: calculateBadTime)
                        }
                        .alert(alertTitle, isPresented: $showingAlert){
                            Button("OK") {}
                    }message: {
                        Text(alertMessage)
                    }
            }
    }
    func calculateBadTime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal badtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem to calculating your badtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
