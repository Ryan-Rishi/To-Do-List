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
    
    func loadData(){
        let userID = Auth.auth().currentUser?.uid
        
        db.collection("tasks")
        // we will sort by createdTime
            .order(by: "createdTime")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener{(QuerySnapshot , error) in
                // if QuerySnapshot is not nil
                if let QuerySnapshot = QuerySnapshot{
                    // get all documents that has fetched and
                    self.tasks =  QuerySnapshot.documents.compactMap { document in
                        do {
                            let x = try?  document.data(as: Task.self)
                            return x
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                        return nil
                    }
                }
            }
    }
    func addTask(_ task: Task) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            return
        }

        var addedTask = task
        addedTask.userID = userID
        
        var ref: DocumentReference? = nil
        ref = db.collection("tasks").addDocument(data: [
            "title": addedTask.title,
            "completed": addedTask.completed,
            "userID": userID,
            "createdTime": FieldValue.serverTimestamp() // Server-generated timestamp
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                // Do not manually set @DocumentID properties
                // addedTask.id = ref!.documentID
            }
        }
    }


    func updateTask(_ task: Task) {
        guard let taskID = task.id else {
            print("This task doesn't have an ID")
            return
        }

        do {
            try db.collection("tasks").document(taskID).setData(from: task) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated!")
                }
            }
        } catch let error {
            print("Error updating task in Firestore: \(error)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
}
