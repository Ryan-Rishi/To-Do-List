//
//  TaskListViewModel.swift
//  To Do List
//
//  Created by Ryan Rishi on 9/12/23.
//

import Foundation
import Combine

class TaskListViewModel: ObservableObject {
    @Published var taskRepository = TaskList()
    @Published var taskCellViewModels = [TaskCellViewModel]()

    private var cancellables = Set<AnyCancellable>()
    init() {
        taskRepository.$tasks
            .map { tasks in
                tasks.map { task in
                    TaskCellViewModel(task: task)
                }
            }
            .assign(to: \.taskCellViewModels, on: self)
            .store(in: &cancellables)
    }

    func addTask(task: Task) {
        var taskWithTime = task
        taskWithTime.createdTime = Date()
        taskRepository.addTask(taskWithTime)
    }

    func updateTask(task: Task) {
        taskRepository.updateTask(task)
    }
}

