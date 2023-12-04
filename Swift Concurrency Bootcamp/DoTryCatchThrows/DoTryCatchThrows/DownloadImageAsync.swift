//
//  DownloadImageAsync.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 22/11/23.
//

import Combine
import SwiftUI

class DownloadImageAsyncImageLoader {
    let url = URL(string: "https://picsum.photos/200")!
    func downLoadWithEscaping(
        completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
            
            URLSession.shared.dataTask(with: url) { [weak self] imageData, urlResponse, error in
                let image = self?.handleResponse(imageData: imageData, urlResponse: urlResponse)
                completionHandler(image, nil)
            }
            .resume()
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
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsyncAwait() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            let image = handleResponse(imageData: data, urlResponse: response)
            return image
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var imageTwo: UIImage? = nil
    @Published var imageThree: UIImage? = nil
    var cancellables = Set<AnyCancellable>()
    let loader = DownloadImageAsyncImageLoader()
    
    func fetchImage() {
        loader.downLoadWithEscaping { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    func fetchImageWithCombine() {
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { image in
                self.imageTwo = image
            }
            .store(in: &cancellables)
        
    }
    
    func downloadWithAsync() async {
        let image = try? await loader.downloadWithAsyncAwait()
        await MainActor.run {
            self.imageThree = image
        }
    }
}

struct DownloadImageAsync: View {
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
            
            if let imageTwo = viewModel.imageTwo {
                Image(uiImage: imageTwo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
            
            if let imageThree = viewModel.imageThree {
                Image(uiImage: imageThree)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }.onAppear {
            viewModel.fetchImage()
            viewModel.fetchImageWithCombine()
            Task {
                await viewModel.downloadWithAsync()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
