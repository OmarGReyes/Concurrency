//
//  SendableBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 27/11/23.
//

import SwiftUI

/*
 ¿Qué problema resuelve sendable?
 Cómo sabemos cada thread tiene su Stack y todos los threads comparten un Heap
 Entonces cuando creamos clases compartidas tenemos que hacerlas threadSafe (es decir un Actor)
 
 Entonces si lo que quiero es enviar una clase dentro de mi actor (esta clase no es threadSafe)
 
 por ejem
 */

actor CurrentUserManager {
    func updateDatabaseThreadSafe(userInfo: MyUserInfo) {
        
    }
    
    func updateDatabaseWithClass(userInfo: MyClassUserInfo) {
        
    }
}

/// Structs son thread safe por ende cuando las hago conformar sendable no tienen ningún warning o error
struct MyUserInfo: Sendable {
    let name: String
}

/// Classes no son thread safe por ende cuando conformo tengo un warning y se quita cuando coloco el final
/// Ahora el compiler sabe que nada va heredar de esta y todas sus variables son constante (let) como no tienen nada en ella que tiene que cambiar entonces la considera threadSafe porqué no puede venir ninguna otra clase a cambiar el nombre
///
/// Cuando coloco el var en la clases obtengo un warning ´Stored property 'lastName' of 'Sendable'-conforming class 'MyClassUserInfo' is mutable´
///
/// ¿Cómo solucionar?
/// Como le decimos que es sendable?
/// Usamos @unchecable pero no es recomendable le decimos al compiler que no checkee la "sendabilidad" de la clase porqué yo lo haré manualmente (al hacer esto no es sendable, sólo le decimos al compiler que no lo checkee.
///
/// Lo que hacemos es crear un nuevo queue y hacer los cambios en ese queue (nosotros mismo la ahcemos threadSafe). Pero esto no es recomendable
final class MyClassUserInfo: @unchecked Sendable {
    let name: String
    private var lastName: String
    
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
        self.lastName = "Gonzalez"
    }
    
    func updateLastName(lastName: String) {
        queue.async {
            self.lastName = lastName
        }
    }
}

final class SendableBootcampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = MyUserInfo(name: "User info")
        let myClassUserInfo = MyClassUserInfo(name: "Class user info")
        await manager.updateDatabaseThreadSafe(userInfo: info)
        await manager.updateDatabaseWithClass(userInfo: myClassUserInfo)
    }
}

struct SendableBootcamp: View {
    @StateObject private var viewModel = SendableBootcampViewModel()
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                await viewModel.updateCurrentUserInfo()
            }
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
