//
//  Task.swift
//  To Do List
//
//  Created by Ryan Rishi on 9/12/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Task : Codable, Identifiable {
    @DocumentID var id : String?
    var title : String
    var completed : Bool
    var createdTime: Date = Date()
    var userID : String?

}


#if DEBUG
let tastDataTasks = [
    Task(title: "implement the ui", completed: true),
    Task(title: "connected to firebase ", completed: false),
    Task(title: "????? ", completed: false),
    Task(title: "Profit ", completed: false)

]


#endif
