//
//  AsyncAwaitClass.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 22/11/23.
//

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Title2: \(Thread.current)"
            
            DispatchQueue.main.async {
                self.dataArray.append(title)
                self.dataArray.append("Title3: \(Thread.current)")
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1 is main thread: \(Thread.isMainThread)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2 is main thread: \(Thread.isMainThread)"
        self.dataArray.append(author2)
        
        await MainActor.run(body: {
            let author3 = "Author3 is main thread: \(Thread.isMainThread)"
            self.dataArray.append(author3)
            
        })
        
        await addSomething()
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        let something1 = "Something1 is main thread: \(Thread.isMainThread)"
        await MainActor.run(body: {
            self.dataArray.append(something1)
            
            let something2 = "Something2 is main thread: \(Thread.isMainThread)"
            self.dataArray.append(something2)
        })
        
    }
}

struct AsyncAwaitBootcamp: View {
    @StateObject private var viewModel = AsyncAwaitBootcampViewModel()
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { string in
                Text(string)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor1()
                let finalText = "Final text inside task after await: \(Thread.isMainThread)"
                viewModel.dataArray.append(finalText)
            }
            
            let finalText = "Final outside Task is main thread: \(Thread.isMainThread)"
            viewModel.dataArray.append(finalText)
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

struct AsyncAwaitClass_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootcamp()
    }
}
