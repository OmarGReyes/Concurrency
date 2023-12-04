//
//  MVVMAsyncAwait.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 30/11/23.
//

import SwiftUI

final class MyManagerClass {
    func getData() async throws -> String {
        "Some class data"
    }
}

actor MyManagerActor {
    func getData() async throws -> String {
        "Some actor data"
    }
}

@MainActor
final class MVVMAsyncAwaitBootcampViewModel: ObservableObject {
    private let managerClass = MyManagerClass()
    private let managerActor = MyManagerActor()
    
    @Published private(set) var myData = "Starting text"
    private var tasks: [Task<Void, Never>] = []
    
    func onCallActionButton() {
        let task = Task {
            do {
                myData = try await managerClass.getData()
            } catch {
                // TODO: Do something with the error
            }
        }
        
        tasks.append(task)
    }
    
    func cancelTasks() {
        tasks.forEach { $0.cancel() }
        tasks = []
    }
    
}

struct MVVMAsyncAwaitBootcamp: View {
    @StateObject private var viewModel = MVVMAsyncAwaitBootcampViewModel()
    var body: some View {
        VStack {
            Text(viewModel.myData)
            Button("Click me") {
                viewModel.onCallActionButton()
            }
        }
    }
}

struct MVVMAsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        MVVMAsyncAwaitBootcamp()
    }
}
