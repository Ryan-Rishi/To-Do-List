//
//  TaskListViewModel.swift
//  To Do List
//
//  Created by Ryan Rishi on 9/12/23.
//

import Foundation
import Combine


class TaskListViewModel : ObservableObject {
    @Published var taskRepository = TaskList()
    @Published var TaskCellViewModels = [TaskCellViewModel]()
    
    private var cancellabels = Set<AnyCancellable>()
    
    init() {
        taskRepository.$tasks.map{ tasks in
            tasks.map{ task in
                TaskCellViewModel(task : task)
                
            }
        }
        .assign(to: \.TaskCellViewModels, on: self)
        .store(in: &cancellabels)
    }
    
    func addTask(task: Task){
        taskRepository.addTask(task)
    }
}
