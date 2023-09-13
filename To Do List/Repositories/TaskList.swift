//
//  TaskList.swift
//  To Do List
//
//  Created by Ryan Rishi on 9/12/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation


class TaskList : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    let db = Firestore.firestore()
    let baseURL = "https://firestore.googleapis.com/v1/projects/todolist-d0e93/databases/(default)/documents/tasks"

    
    @Published var tasks = [Task]()
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.loadData()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func loadData() {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching tasks: \(error)")
                return
            }

            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let documents = json["documents"] as? [[String: Any]] {
                        
                        var newTasks: [Task] = []
                        
                        for document in documents {
                            if let fields = document["fields"] as? [String: Any],
                               let titleField = fields["title"] as? [String: Any],
                               let title = titleField["stringValue"] as? String,
                               let completedField = fields["completed"] as? [String: Any],
                               let completed = completedField["booleanValue"] as? Bool {
                                
                                let task = Task(title: title, completed: completed)
                                newTasks.append(task)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tasks = newTasks
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                }
            }
        }
        task.resume()
    }


    func addTask(_ task: Task) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            return
        }

        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let taskData: [String: Any] = [
            "fields": [
                "title": ["stringValue": task.title],
                "completed": ["booleanValue": task.completed],
                "userID": ["stringValue": userID]
            ]
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: taskData, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            print("Error encoding task: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error adding task: \(error)")
            } else {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.loadData()  // Refetch all tasks
                }
            }
        }

        task.resume()
    }





    func updateTask(_ task: Task) {
        guard let taskID = task.id else {
            print("This task doesn't have an ID")
            return
        }

        guard let url = URL(string: "\(baseURL)/\(taskID)?updateMask.fieldPaths=title,completed") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "UPDATE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let taskData: [String: Any] = [
            "fields": [
                "title": ["stringValue": task.title],
                "completed": ["booleanValue": task.completed]
            ]
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: taskData, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            print("Error encoding task: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error updating task: \(error)")
            } else if let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Task updated: \(json)")
            }
        }

        task.resume()
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
}
