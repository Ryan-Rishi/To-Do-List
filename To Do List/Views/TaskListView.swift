//
//  TaskListView.swift
//  To Do List
//
//  Created by Ryan Rishi on 9/12/23.
//

import SwiftUI
import CoreLocation

struct TaskListView: View {
    @ObservedObject var taskListVM = TaskListViewModel()
    @State private var currentLocation: String = "Fetching location..."
    @State private var locationManager = CLLocationManager()
    
    // Declare flag to hide and show specific cell when user presses "Add New Task"
    @State var presentAddNewItem = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Display the current location
                Text("Current Location: Lat \(taskListVM.taskRepository.latitude), Lon \(taskListVM.taskRepository.longitude)")
                    .padding()
                
                List {
                    ForEach(taskListVM.taskCellViewModels) { taskCellVM in
                        TaskCell(taskCellVM: taskCellVM) { task in
                            self.taskListVM.updateTask(task: task)
                        }
                    }
                    if presentAddNewItem {
                        TaskCell(taskCellVM: TaskCellViewModel(task: Task(title: "", completed: false))) { task in
                            self.taskListVM.addTask(task: task)
                            // Hide the text field after insertion
                            self.presentAddNewItem.toggle()
                        }
                    }
                }
                Spacer()
                HStack(alignment: .top) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                    Button("Add New Task") {
                        self.presentAddNewItem.toggle()
                    }
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationBarTitle("Tasks")
            .onAppear {
                let coordinator = Coordinator(locationManager: self.locationManager, locationString: self.$currentLocation)
                self.locationManager.delegate = coordinator
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            }
        }
        .padding(.leading, -8.0)
    }
}

class Coordinator: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager
    @Binding var currentLocation: String
    
    init(locationManager: CLLocationManager, locationString: Binding<String>) {
        self.locationManager = locationManager
        _currentLocation = locationString
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = "Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)"
        }
    }
}


struct TaskCell: View {
    
    @ObservedObject var taskCellVM: TaskCellViewModel
    //when user make changes on the cellVM then put it back to datastucture type
    var onCommit : (Task) -> (Void) = { _ in }
    var body: some View {
        HStack {
            //CompeletionStateIconName
            // if statement to check if it completed or not
            Image(systemName: taskCellVM.task.completed ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 20, height: 20)
            //when user tap on image it change
                .onTapGesture {
                    self.taskCellVM.task.completed.toggle()
                }
            TextField("Enter Task Title", text: $taskCellVM.task.title, onCommit: {
                self.onCommit(self.taskCellVM.task)
            })
        }
    }
}


struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}
