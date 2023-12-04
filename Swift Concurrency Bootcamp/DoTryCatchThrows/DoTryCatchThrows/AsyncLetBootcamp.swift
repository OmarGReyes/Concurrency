//
//  AsyncLetBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 23/11/23.
//

import SwiftUI

enum ImageQuality: String {
    case low
    case high
}

final class ImageDataManager {
    let lowQualityURL = "https://picsum.photos/200"
    let highQualityURL = "https://picsum.photos/5000"
    

    let url = URL(string: "https://picsum.photos/2000")!
    func fetchImage(quality: ImageQuality) async throws -> UIImage {
        var fetchURL: URL {
            switch quality {
            case .low:
                return URL(string: lowQualityURL)!
            case .high:
                return URL(string: highQualityURL)!
            }
        }

        do {
            print("Running operation at same time at thread: \(Thread.current)")
            let (data, _) = try await URLSession.shared.data(from: fetchURL)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

final class AsyncLetBootcampViewModel: ObservableObject {
    private let imageDataManager = ImageDataManager()
    @Published var images: [UIImage] = []
    @Published var title: String = ""
    
    func appendImage() {
        images.append(UIImage(systemName: "heart.fill")!)
    }
    
    func fetchImage(withQuality imageQuality: ImageQuality = .high) async {
        do {
            let fetchedImage = try await imageDataManager.fetchImage(quality: imageQuality)
            await MainActor.run(body: {
                self.images.append(fetchedImage)
                print("fetched image with quality: \(imageQuality.rawValue)")
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImagesToAttachFromView(_ imageQuality: ImageQuality = .low) async throws -> UIImage {
        do {
            let fetchedImage = try await imageDataManager.fetchImage(quality: imageQuality)
            print("fetched image with quality added to the array and waiting for other images: \(imageQuality.rawValue)")
            return fetchedImage
        } catch {
            throw error
        }
    }
    
    func fetchTitle() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await MainActor.run(body: {
            self.title = "AsyncLet Bootcamp 🥳"
        })
    }
}

struct AsyncLetBootcamp: View {
    @StateObject private var viewModel = AsyncLetBootcampViewModel()
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: nil, height: 150)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .onAppear {
//                viewModel.appendImage()
            }
            .task {
                /// In this first case every time that an image is fetched this image will be appended
                /// in the array so it will appear in order on fetching
                async let fetchImage1: () = viewModel.fetchImage(withQuality: .high)
                async let fetchImage2: () = viewModel.fetchImage(withQuality: .high)
                async let fetchImage3: () = viewModel.fetchImage(withQuality: .high)
                async let fetchImage4: () = viewModel.fetchImage(withQuality: .high)
                async let fetchTitle: () = viewModel.fetchTitle()
                
                let _ = await(fetchImage1, fetchImage2, fetchImage3, fetchImage4, fetchTitle)
                
                /// In this case below i'll wait until every image is fetched to display it in the view
                async let fetchImage5 = viewModel.fetchImagesToAttachFromView(.low)
                async let fetchImage6 = viewModel.fetchImagesToAttachFromView(.high)
                async let fetchImage7 = viewModel.fetchImagesToAttachFromView(.low)
                async let fetchImage8 = viewModel.fetchImagesToAttachFromView(.low)
                
                
                do {
                    let (image5, image6, image7, image8) = await (try fetchImage5, try fetchImage6, try fetchImage7, try fetchImage8)
                    viewModel.images.append(contentsOf: [image5, image6, image7, image8])
                } catch {
                    
                }
            }
        }
    }
    
//    func fetchImage() async ->
}

struct AsyncLetBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetBootcamp()
    }
}
