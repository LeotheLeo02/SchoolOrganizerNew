//
//  EditTestView.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI
import CoreHaptics

struct EditTestView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    var test: FetchedResults<Tests>.Element
    @Environment(\.dismiss) var dismiss
    @State private var score = ""
    @State private var goodscore = false
    @State private var badscore = false
    @State private var name = ""
    @State private var engine: CHHapticEngine?
    var body: some View {
        Form {
            Section{
                TextField("Score", text: Binding(
                    get: {score},
                    set: {score = $0.filter{"0123456789".contains($0)}}))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .keyboardType(.numberPad)
                    .onAppear(){
                        let initial = String(test.score)
                        score = initial
                        name = test.testname!
                        prepareHaptics()
                    }
            } header: {
                Text("Score")
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
            }
            Button {
                UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                    var identifiers: [String] = [name]
                    print("\(name)")
                   for notification:UNNotificationRequest in notificationRequests {
                       if notification.identifier == "identifierCancel" {
                          identifiers.append(notification.identifier)
                       }
                   }
                   UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                    print("Deleted Notifcation")
                }
                dismiss()
                deleteTest()
            } label: {
                HStack{
                    Spacer()
                Text("Delete Test")
                    .bold()
                    .foregroundColor(.red)
                    Spacer()
                }
            }
            .toolbar{
                ToolbarItem(placement: .keyboard){
                    Button {
                        var number: Int64 = NumberFormatter().number(from: "0" + score) as! Int64
                        if number > 100{
                            number = 100
                        }
                        if number >= 80{
                            goodscore.toggle()
                            complexSuccess()
                        }
                        if number < 70 {
                            badscore.toggle()
                        }
                        TestDataController().editTestScore(test: test, testscore: number, context: managedObjContext)
                        dismiss()
                    } label: {
                        HStack{
                        Text("Add Score")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Image(systemName: "plus.app.fill")
                        }
                    }

                }
            }

        }
        .alert(Text("Good Job! 👍"), isPresented: $goodscore, actions: {
            Button {
                
            } label: {
                Text("Thanks!")
            }

        }, message: {
            Text("You Earned This!")
        })
        .alert(isPresented: $badscore){
            Alert(title: Text("It's Ok.😌"), message: Text("You learned your mistakes"), dismissButton: .cancel(Text("Agreed")))
        }
    }
    private func deleteTest() {
        withAnimation {
            test.managedObjectContext?.delete(test)
            TestDataController().save(context: managedObjContext)
        }
    }
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}
