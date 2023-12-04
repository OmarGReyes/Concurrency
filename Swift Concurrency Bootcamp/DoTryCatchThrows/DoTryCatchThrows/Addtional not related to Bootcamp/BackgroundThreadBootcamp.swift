//
//  BackgroundThreadBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 27/11/23.
//

import SwiftUI

final class BackgroundThreadBootcampViewModel: ObservableObject {
    @Published var dataArray = [String]()
    
    func fetchData() {
        DispatchQueue.global(qos: .background).async {
            let data = self.downloadData()
            DispatchQueue.main.async {
                self.dataArray = data
            }
        }
    }
    
    private func downloadData() -> [String] {
        var data: [String] = []
        
        for x in 0..<100 {
            data.append("\(x)")
            print(data)
        }
        return data
    }
}

struct BackgroundThreadBootcamp: View {
    @StateObject private var viewModel = BackgroundThreadBootcampViewModel()
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Text("Load data")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .onTapGesture {
                        viewModel.fetchData()
                    }
                ForEach(viewModel.dataArray, id: \.self) { item in
                    Text(item)
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct BackgroundThreadBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundThreadBootcamp()
    }
}
