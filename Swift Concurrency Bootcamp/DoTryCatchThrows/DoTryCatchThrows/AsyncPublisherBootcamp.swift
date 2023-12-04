//
//  AsyncPublisherBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 28/11/23.
//

import Combine
import SwiftUI

actor AsyncPublisherBootcampDataManager {
    @Published var myData: [String] = []
    @Published var myNumbers: [Int] = []
    
    func addNumbers() async {
        myNumbers.append(1)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(2)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(3)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(4)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(5)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(6)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(7)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(8)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(9)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(10)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(11)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        myNumbers.append(12)
    }
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Pera")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Manzana")
    }
    
    func addMango() {
        myData.append("Mango")
    }
}

final class AsyncPublisherBootcampViewModel: ObservableObject {
    @Published var dataArray = [String]()
    @Published var numbersArray = [Int]()
    var cancellables = Set<AnyCancellable>()
    let manager = AsyncPublisherBootcampDataManager()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        Task {
            /*
             Also we can play around with this values i mean we can use something like filter. map. etc...
             */
            for await value in await manager.$myData.values {
                // In this case we sorted alphabetically
                let ordered = value.sorted()
                await MainActor.run(body: {
                    self.dataArray = ordered
                })
            }	
            
            print("This line of code will never executed because the subscription will always be waiting for values")
        }
        
        // manager.$myNumbers.values is an asyncPublisher an this allow my to use async/await to subscribe to this piblisher and wait for new values
        
        /*
         
         El AynscPublisher sirve para poder subscribirme a una variable Published que puede estar constantemente emitiendo valores (es algo así como un sink) pero con async/await
         */
        Task {
            for await value in await manager.$myNumbers.values {
                let pairs = value.filter { number in
                    number % 2 == 0
                }
                
                await MainActor.run(body: {
                    self.numbersArray = pairs
                })
            }
        }
        
        
        // Combine way
        Task {
            await manager.$myData
                .receive(on: RunLoop.main)
                .sink { dataArray in
                    self.dataArray = dataArray
                }
                .store(in: &cancellables)
        }
    }
    
    func start() async {
        await manager.addData()
//        await manager.addNumbers()
    }
    
    func addMoreData() {
        Task {
            await manager.addMango()
        }
    }
}

struct AsyncPublisherBootcamp: View {
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.dataArray, id: \.self) { data in
                    Text("\(data)")
                        .font(.headline)
                }
            }
            
            Button("Add mango") {
                viewModel.addMoreData()
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

struct AsyncPublisherBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootcamp()
    }
}
