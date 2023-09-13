//
//  TaskCellViewModel.swift
//  To Do List
//
//  Created by Ryan Rishi on 9/12/23.
//

import Foundation
import Combine

class TaskCellViewModel : ObservableObject, Identifiable {
    @Published var task : Task
    var id = ""
    @Published var completionStateIconName = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(task: Task) {
        self.task = task
        
        $task
            .map{ task in
                task.completed ? "checkmark.circle.fill" : "circle"
                
            }
        //assign the result of map operation to CompeletionStateIconName property using combine
            .assign(to: \.completionStateIconName , on: self)
            .store(in: &cancellables)
        
        $task
            .compactMap{ task in
                task.id
                
            }
        //assign the result of map operation to CompeletionStateIconName property using combine
            .assign(to: \.id , on: self)
            .store(in: &cancellables)
        
        // Any time there is a change or Edit it will updated
        // we want to send the update only when stop typing
        
        
        
    }
}
