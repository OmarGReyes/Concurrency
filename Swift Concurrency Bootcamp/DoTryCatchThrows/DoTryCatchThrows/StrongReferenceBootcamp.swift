//
//  StrongReferenceBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 29/11/23.
//

import SwiftUI

class StrongReferenceBootcampDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        print("fetching data...")
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Pera")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Manzana")
        print("Finished add Data")
    }
    
    private func handleResponse(imageData: Data?, urlResponse: URLResponse?) -> UIImage? {
        guard let data = imageData,
              let image = UIImage(data: data),
              let response = urlResponse as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        
        return image
    }

    
    func downloadWithAsyncAwait() async throws -> UIImage? {
        print("Downloading image...")
        let url = URL(string: "https://picsum.photos/5000")!
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            let image = handleResponse(imageData: data, urlResponse: response)
            print("Image downloaded")
            return image
        } catch {
            throw error
        }
    }
}

final class StrongReferenceTestViewModel: ObservableObject {
    @Published var dataArray = [String]()
    let manager = StrongReferenceBootcampDataManager()
    
    private var task: Task<(), Never>? = nil
    private var myTasks: [Task<(), Never>] = []
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        task = Task {
            for await value in manager.$myData.values {
                let ordered = value.sorted()
                await MainActor.run(body: {
                    self.dataArray = ordered
                })
            }
        }
        
        if let task = task {
            myTasks.append(task)
        }
        
//        let task2 = Task {
//            for await value in manager.$myNumbers.values {
//                let ordered = value.sorted()
//                await MainActor.run(body: {
//                    self.dataNumbers = ordered
//                })
//            }
//        }
//        myTasks.append(task2)
    }
    

    func start()  {
//        let startedTask = Task {
//                await self.manager.addData()
//        }
//
//        myTasks.append(startedTask)
        
        let myTitleTask = Task(priority: .low) {
            
            do {
                let image = try await self.manager.downloadWithAsyncAwait()
                print("Image size \(image?.size)")
            } catch {
                print(error.localizedDescription)
            }
            
        }

        myTasks.append(myTitleTask)
    }
    
    func cancelTask() {
        myTasks.forEach { $0.cancel() }
    }
    
    deinit {
        print("View model deinit")
    }

}

struct StrongReferenceTest: View {
    @StateObject var viewModel = StrongReferenceTestViewModel()
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.dataArray, id: \.self) { data in
                    Text("\(data)")
                        .font(.headline)
                }
            }
        }
        .onDisappear {
            viewModel.cancelTask()
        }
        .onAppear {
            viewModel.start()
        }
        .navigationTitle("With with a lot of tasks")
    }
}


struct StrongReferenceBootcamp: View {
//    @StateObject private var viewModel = StrongReferenceBootcampViewModel()
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: StrongReferenceTest()) {
                    Text("Show other thing")
                }
            }
        }
    }
}

struct StrongReferenceBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StrongReferenceBootcamp()
    }
}


//final class StrongReferenceDataService {
//    func getData() async -> String {
//        "Update data!"
//    }
//}

//final class StrongReferenceBootcampViewModel: ObservableObject {
//    @Published var data: String = "Some title"
//    let dataService = StrongReferenceDataService()
//
//    func updateData() {
//        /**
//         This create a strong reference it means that te viewModel will be not
//         deallocated until the async function finish
//         */
//        Task {
//            data = await dataService.getData()
//        }
//    }
//
//    // String reference too
//    func updateData2() {
//        Task {
//            self.data = await dataService.getData()
//        }
//    }
//
//    // Strong reference
//    func updateData3() {
//        Task { [self] in
//            self.data = await dataService.getData()
//        }
//    }
//
//    /**
//     The reason why we don't do this is because the reference are inside task, so instead of
//     magae the reference at refernce level we can manage at task level
//     */
//    func updateData4() {
//        Task { [weak self] in
//            if let data = await self?.dataService.getData() {
//                self?.data = data
//            }
//        }
//    }
//
//    // We don't manage the weak/strong
//    // because we will manage the task
//    func updateData5() {
//        Task {
//            self.data = await dataService.getData()
//        }
//    }
//
//    func cancelTasks() {
//
//    }
//}
