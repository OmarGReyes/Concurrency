//
//  GlobalActorBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 27/11/23.
//

import SwiftUI

protocol DataManagerProtocol {
    func getDataFromDatabase() async -> [String]
}

/*
 Qué necesito para un global actor?
 En este caso necesitamos una instancia compartido de nuestro DataManagerActor
 
 Lo que queremos hacer es que la función viewModel.getData esté aislada junto con el actor, es decir: lo contrario a nonisolate, nonisolate busca hacer que una fcunión dentro de un actor no esté islated mientras que este lo que buscar es agarrar una función desde fuera y asilarla con el actor
 */

@globalActor struct MyFirstGlobalActor {
    static var shared = DataManager()
}

actor DataManager: DataManagerProtocol {

    static let shared = DataManager()

    var myNewVar = 1

    func getDataFromDatabase() -> [String] {
        return ["1", "2", "3", "4", "5"]
    }
}

/*
 Cuando marcamos una propiedad como MainActor, esto significa que el compilador ahora nos lanzará un error
 para hacernos saber que ahora esa propiedad sólo puede ser modificada desde el mainActor y no desde cualquier otro actor. para ellos tenemos dos optionces:
 1) Utilizar el buen MainActor.run(body: {})
 
 ¿Pero qué pasa si tenemos múltiples propiedades que queremos compartir? Nuestro código se vería algo así:
 @MainActor @Published var dataArray1: [String] = []
 @MainActor @Published var dataArray2: [String] = []
 @MainActor @Published var dataArray3: [String] = []
 @MainActor @Published var dataArray4: [String] = []
 
 2) Para solucionar esto se marca toda la clase como un MainActor (o cualquier otro actor) (pero no lo sé rick) y las funciones que no necesiten de un await se pueden marcar como nonisolated
 */

@MainActor
final class GlobalActorBootcampViewModel: ObservableObject {
    let manager: DataManagerProtocol = MyFirstGlobalActor.shared
    @MainActor @Published var dataArray: [String] = []
    
    @MyFirstGlobalActor
    func getData() async {
        let data = await manager.getDataFromDatabase()
        await MainActor.run {
            self.dataArray = data
        }
    }
}

struct GlobalActorBootcamp: View {
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }.task {
            await viewModel.getData()
        }
    }
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
