//
//  CheckSplitterApp.swift
//  CheckSplitter
//
//  Created by KhusainovMehrubon on 26/07/24.
//

import SwiftUI

@main
struct CheckSplitterApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
              
                ContentView()
                
                NavigationView{
                    //RecognizePhoto()
                }
                .tabItem{
                    Image(systemName: "star.fill")
                    Text("Beta Сканер")
                }
            }
            
        }
    }
}
