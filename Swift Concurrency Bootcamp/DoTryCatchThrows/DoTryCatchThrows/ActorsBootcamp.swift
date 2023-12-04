//
//  ActorsBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 27/11/23.
//

import SwiftUI

class MyDataManager {
    static let instance = MyDataManager()
    private init() { }
    
    var data: [String] = []
    
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> Void) {
        lock.async { [weak self] in
            self?.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self?.data.randomElement())
        }
    }
}

actor MyActorDataManager {
    static let instance = MyActorDataManager()
    private init() { }
    
    var data: [String] = []
    
    nonisolated let nonIsolatedData = "Non isolated string"
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    // Marked as non isolated in order to not use await when call
    // the actor itself is isolated but this function no
    nonisolated func getSavedData() -> String {
        "Non isolated function"
    }
}


struct HomeView: View {
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }.onAppear(perform: {
            // i can use this function here because is not isolated in the actor so i don't need a task
            // to execute it
            let newNonIsolatedString = manager.getSavedData()
            let nonIsolatedProperty = manager.nonIsolatedData
            Task {
                // As every property of the actor is safeThread we must wait for the resultr but what if
                // in my actor i have a function that i don't want to wait?
                let newData = manager.getSavedData()
            }
        })
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = text
                    })
                }
            }
        }
    }
}

struct BrowseView: View {
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Color.red.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }.onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = text
                    })
                }
            }
        }
    }
}


struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorsBootcamp()
    }
}
