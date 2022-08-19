//
//  OnBoardingView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/18/22.
//

import SwiftUI

struct OnBoardingView: View {
    var body: some View {
        TabView{
            PresentAssign()
                .tabItem {
                    Text("Add Assignments")
                }
            PresentNotification()
                .tabItem {
                    Text("Notifications")
                }
            PresentDynamic()
                .tabItem {
                    Text("Dynamic")
                }
            PresentReady()
                .tabItem {
                    Text("Ready")
                }
        }.tabViewStyle(.page(indexDisplayMode: .always))
    }
}
struct PresentReady: View{
    @State private var ready = false
    @Environment (\.dismiss) var dismiss
    var body: some View{
        VStack{
            Rectangle()
                .frame(width: .infinity, height: .infinity)
                .foregroundColor(Color(.systemGray5))
                .cornerRadius(20)
                .overlay {
                    VStack{
                        Text("Ready?")
                            .font(.system(size: 60, weight: .heavy, design: .rounded))
                        Button {
                            ready = true
                            simpleSuccess()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                dismiss()
                            }
                        } label: {
                            Image(systemName: ready ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.green)
                                .animation(.easeInOut, value: ready)
                        }
                    }.padding()
                }
        }.padding()
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct PresentDynamic: View{
    var body: some View{
        VStack{
            Rectangle()
                .frame(width: .infinity, height: .infinity)
                .foregroundColor(Color(.systemGray5))
                .cornerRadius(20)
                .overlay {
                    VStack{
                        Circle()
                            .foregroundColor(Color(.systemGray3))
                            .padding()
                            .overlay {
                                Text("Dynamically Filter And Organize Assignments and Tests")
                                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                        Image(systemName: "folder.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                    }.padding()
                    }
                }
        }.padding()
    }
}

struct PresentNotification: View{
    var body: some View{
        VStack{
            Rectangle()
                .frame(width: .infinity, height: .infinity)
                .foregroundColor(Color(.systemGray5))
                .cornerRadius(20)
                .overlay {
                    VStack(alignment: .center) {
                        Text("Delivers Reminders For Upcoming Assignments And Tests")
                            .underline()
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        Rectangle()
                            .frame(minWidth: 320, idealWidth: 350, maxWidth: 375, minHeight: 70, maxHeight: 70)
                            .cornerRadius(30)
                            .foregroundColor(Color(.systemGray3))
                            .overlay {
                                HStack{
                                    Image("Logo")
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Notification")
                                        .font(.system(size: 20, weight: .light, design: .rounded))
                                    Text("Your Biology Assignment Is Due In Two Days")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                }.padding()
                            }
                        Rectangle()
                            .frame(minWidth: 320, idealWidth: 350, maxWidth: 375, minHeight: 70, maxHeight: 70)
                            .cornerRadius(30)
                            .foregroundColor(Color(.systemGray3))
                            .overlay {
                                HStack{
                                    Image("Logo")
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Notification")
                                        .font(.system(size: 20, weight: .light, design: .rounded))
                                    Text("Your ELA Assignment Is Due In One Day")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                }.padding()
                            }
                        Rectangle()
                            .frame(minWidth: 320, idealWidth: 350, maxWidth: 375, minHeight: 70, maxHeight: 70)
                            .cornerRadius(30)
                            .foregroundColor(Color(.systemGray3))
                            .overlay {
                                HStack{
                                    Image("Logo")
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Notification")
                                        .font(.system(size: 20, weight: .light, design: .rounded))
                                    Text("Your Algebra Test Is In Two Days")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                }.padding()
                            }
                    }
                }
        }.padding()
    }
}

struct PresentAssign: View{
    var body: some View{
        VStack(alignment: .center){
            Rectangle()
                .frame(width: .infinity, height: .infinity)
                .foregroundColor(Color(.systemGray5))
                .cornerRadius(20)
                .overlay {
                    VStack(alignment: .leading){
                    Text("Add Assignments")
                            .underline()
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(.orange)
                        HStack{
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.red)
                            .cornerRadius(20)
                            Rectangle()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                            Rectangle()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.green)
                                .cornerRadius(20)
                        }
                        HStack{
                            Rectangle()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                                Rectangle()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.green)
                                    .cornerRadius(20)
                                Rectangle()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.red)
                                    .cornerRadius(20)
                        }
                        HStack{
                            Rectangle()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.red)
                                .cornerRadius(20)
                                Rectangle()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.blue)
                                    .cornerRadius(20)
                                Rectangle()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.green)
                                    .cornerRadius(20)
                        }
                        HStack{
                        Text("In A Nice Organized Grid")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                            .underline(true, color: .black)
                            Image(systemName: "square.grid.2x2.fill")
                                .foregroundColor(.blue)
                        }
                    }.padding()
                }
        }.background(Color(.systemGray6))
            .padding()
    }
}
