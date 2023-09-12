//
//  ToDoListApp.swift
//  To Do List
//
//  Created by Ryan Rishi on 9/10/23.
//

import SwiftUI
import Firebase

@main
struct ToDoListApp: App {
    init() {
        FirebaseApp.configure()
        if Auth.auth().currentUser == nil{
            Auth.auth().signInAnonymously()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
    }
}
