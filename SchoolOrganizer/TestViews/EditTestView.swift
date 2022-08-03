//
//  EditTestView.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct EditTestView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    var test: FetchedResults<Tests>.Element
    @Environment(\.dismiss) var dismiss
    @State private var score = ""
    @State private var goodscore = false
    @State private var badscore = false
    @State private var name = ""
    var body: some View {
        Form {
            Section{
                var number: Int64 = NumberFormatter().number(from: "0" + score) as! Int64
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
                    }
                    .onSubmit {
                        if number > 100{
                            number = 100
                        }
                        if number >= 80{
                            goodscore.toggle()
                        }
                        if number < 70 {
                            badscore.toggle()
                        }
                        TestDataController().editTestScore(test: test, testscore: number, context: managedObjContext)
                        dismiss()
                    }
            } header: {
                Text("Score")
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
            }
            Button {
                UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                    var identifiers: [String] = [name]
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


        }.alert(isPresented: $goodscore){
            Alert(title: Text("Nice Job!👍"), message: Text("You Earned This!"), dismissButton: .cancel(Text("Thanks!")))
        }
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
}
