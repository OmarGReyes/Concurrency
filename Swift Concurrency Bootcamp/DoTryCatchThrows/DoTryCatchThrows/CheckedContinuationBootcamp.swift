//
//  CheckedContinuationBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 23/11/23.
//

import SwiftUI

final class CheckedContinuationBootcampNetworkManager {
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage?) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completionHandler(UIImage(systemName: "heart.fill"))
        }
    }
    
    // My approach
    func getHearImageWithContinuation() async throws -> UIImage? {
        return await withCheckedContinuation({ continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                continuation.resume(returning: UIImage(systemName: "trash"))
            }
        })
    }
    
    // Approach from this video
    func getHeartFromDatabaseContinuation() async -> UIImage? {
        await withCheckedContinuation({ continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        })
    }
}

final class CheckedContinuationBootcampViewModel: ObservableObject {
    let url = URL(string: "https://picsum.photos/200")!
    let networkManager = CheckedContinuationBootcampNetworkManager()
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    @Published var image3: UIImage? = nil
    @Published var image4: UIImage? = nil
    
    func getData() async {
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        do {
            let data = try await networkManager.getData(url: url)
            await MainActor.run {
                self.image = UIImage(data: data)
            }
        } catch {
            print(error)
        }
    }
    
    func getData2() async {
        if let data = try? await networkManager.getData2(url: url) {
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
        }
    }
    
    func getHeart() {
        networkManager.getHeartImageFromDatabase { image in
            if let image = image {
                DispatchQueue.main.async { [weak self] in
                    self?.image3 = image
                }
            }
        }
    }
    func getHeart2() async {
        if let image = try? await networkManager.getHearImageWithContinuation() {
            await MainActor.run(body: {
                self.image4 = image
            })
        }
//        networkManager.getHearImageWithContinuation { image in
//            if let image = image {
//                DispatchQueue.main.async { [weak self] in
//                    self?.image4 = image
//                }
//            }
//        }
    }
    
}

struct CheckedContinuationBootcamp: View {
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image3 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image4 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }.task {
            await viewModel.getData()
            await viewModel.getData2()
            viewModel.getHeart()
            await viewModel.getHeart2()
        }
    }
}

struct CheckedContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
