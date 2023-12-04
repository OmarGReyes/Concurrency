//
//  TaskGroupBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 23/11/23.
//

import SwiftUI

final class TaskGroupBootcampDataManager {
    
    func fetchImagesWithAsyncLet(urlString: String) async throws -> [UIImage] {
        do {
            async let fetchImage1 = fetchImage(urlString: urlString)
            async let fetchImage2 = fetchImage(urlString: urlString)
            async let fetchImage3 = fetchImage(urlString: urlString)
            async let fetchImage4 = fetchImage(urlString: urlString)
            
            let (image1, image2, image3, image4) = await (try fetchImage1,
                                                          try fetchImage2,
                                                          try fetchImage3,
                                                          try fetchImage4)

            return [image1, image2, image3, image4]
        } catch {
            throw error
        }
    }
    
    func fetchImagesWithTaskGroup(urlString: String) async throws -> [UIImage] {
        let urlStrings = [
            urlString,
            urlString,
            urlString,
            urlString,
            urlString,
            urlString
        ]
        
        /// Of: es del tipo que vana a traer los childTask, como en este caso los child tasks son los del la linea 48
        /// Entonces por eso lo colocamos opcionales, es decir, ese es el valor que van a traer los childTask
        /// lo hacemos de esa manera por si algún childTask falla entonces no se vaya todo a la verga, si no que tire un nil
        /// posteriormente en la linea 56 lo que hace,os es esperar todos los resultados de ese task (UIImage?) y le hacemos un
        /// if-letazo
        let result = try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)
            
            for string in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: string)
                }
            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            
            return images
        }
        
        return result
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let fetchURL = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do {
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

final class TaskGroupBootcampViewModel: ObservableObject {
    let manager = TaskGroupBootcampDataManager()
    @Published var images: [UIImage] = []
    
    func fetchImagesFromUrlAsyncLet(_ urlString: String = "https://picsum.photos/2000") async {
        do {
//            print
            let downloadedImages = try await manager.fetchImagesWithAsyncLet(urlString: urlString)
            await MainActor.run {
                self.images = downloadedImages
            }
        } catch {
            // Do nothing
        }
    }
    
    func fetchImagesFromUrlWithTaskGroup(_ urlString: String = "https://picsum.photos/200") async {
        if let images = try? await manager.fetchImagesWithTaskGroup(urlString: urlString) {
            await MainActor.run {
                self.images = images
            }
        }
    }

}

struct TaskGroupBootcamp: View {
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
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
            }.navigationTitle("TaskGroup Bootcamp 🥳")
        }
        .task {
//            await viewModel.fetchImagesFromUrlAsyncLet()
            await viewModel.fetchImagesFromUrlWithTaskGroup()
        }
    }
}

struct TaskGroupBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupBootcamp()
    }
}
