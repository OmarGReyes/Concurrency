//
//  TaskBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 22/11/23.
//

import SwiftUI

final class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                let image = UIImage(data: data)
                self.image = image
                print("image returned succesfully")
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/5000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                let image = UIImage(data: data)
                self.image2 = image
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootCampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click me") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    @StateObject private var viewModel = TaskBootcampViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image2 = viewModel.image2 {
                Image(uiImage: image2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .onDisappear {
            fetchImageTask?.cancel()
        }
        .task {
            await viewModel.fetchImage()
        }
        .onAppear {
//            fetchImageTask = Task {
//                await viewModel.fetchImage()
//            }
//
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
            
//            Task(priority: .high) {
//                print("high: \(Thread.current) : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .userInitiated) {
//                print("userInitiated: \(Thread.current) : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .medium) {
//                print ("medium : \(Thread.current) : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .low) {
//                print("low : \(Thread.current) : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .utility) {
//                print("utility : \(Thread.current) : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .background) {
//                print("background: \(Thread.current) : \(Task.currentPriority.rawValue)")
//            }
            
//            Task(priority: .low) {
//                print("low : \(Thread.current) : \(Task.currentPriority.rawValue)")
//
//                Task {
//                    print("low Child: \(Thread.current) : \(Task.currentPriority.rawValue)")
//                }
//            }
//
//            Task(priority: .high) {
//                print("high : \(Thread.current) : \(Task.currentPriority.rawValue)")
//
//                Task {
//                    print("high Child: \(Thread.current) : \(Task.currentPriority.rawValue)")
//                }
//            }
//
//            Task(priority: .low) {
//                print("low : \(Thread.current) : \(Task.currentPriority.rawValue)")
//
//                // MARK: Try to not use. See documentation
//                Task.detached {
//                    print("D: \(Thread.current) : \(Task.currentPriority.rawValue)")
//                }
//            }
        }
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcamp()
    }
}
