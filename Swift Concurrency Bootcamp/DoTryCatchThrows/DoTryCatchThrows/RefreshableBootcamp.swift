//
//  RefreshableBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 30/11/23.
//

import SwiftUI

final class RefreshableBootcampDataSource {
    func fetchData() async throws -> [String] {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return ["1", "2", "3", "4", "5", "6", "7"].shuffled()
    }
}

@MainActor
final class RefreshableBootcampViewModel: ObservableObject {
    private var tasks: [Task<Void, Never>] = []
    private var dataSource = RefreshableBootcampDataSource()
    @Published var data: [String] = []
    
    
    func fetchData() async {
        do {
            self.data = try await dataSource.fetchData()
        } catch {
            print("Error")
        }
    }
}

struct RefreshableBootcamp: View {
    @StateObject var viewModel = RefreshableBootcampViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.data, id: \.self) {
                        Text($0)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("My title")
        }
        .refreshable {
            await viewModel.fetchData()
        }
        .task {
            await viewModel.fetchData()
        }
    }
}

struct RefreshableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableBootcamp()
    }
}
