//
//  StructClassActorBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 26/11/23.
//

import SwiftUI

final class StructClassActorsBootcampViewModel: ObservableObject {
    @Published var title = ""
    
    init() {
        print("ViewModel init")
    }
}

struct StructClassActorBootcamp: View {
    @StateObject private var viewModel = StructClassActorsBootcampViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
//        self.viewModel = viewModel
        print("View init")
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
            .onAppear {
//                runTest()
            }
    }
}

struct StructClassActorBootcampHomeView: View {
    @State private var isActive = false
    var body: some View {
        StructClassActorBootcamp(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}

struct StructClassActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActorBootcamp(isActive: false)
    }
}


struct MyStruct {
    var title: String
}

extension StructClassActorBootcamp {
    private func runTest() {
        print("Test started")
//        structTest1()
//        printDivider()
//        classTest1()
        
        structTest2()
        printDivider()
        classTest2()
    }
    
    private func printDivider() {
        print("""
        
        -------------------------------------------
        
        """
        )
    }
    
    private func structTest1() {
        let objectA = MyStruct(title: "Starting title!")
        print("StructA:", objectA.title)
        
        print("Passing VALUES from A to B")
        var objectB = objectA
        print("StructB:", objectB.title)
        
        objectB.title = "Second title!"
        print("StructB title changed")
        print("StructA:", objectA.title)
        print("StructB:", objectB.title)
    }
    
    private func classTest1() {
        let objectA = MyClass(title: "Starting class title!")
        print("Class A:", objectA.title)
        
        print("STEP 1: Passing REFERENCE from A to B")
        
        let objectB = objectA
        print("Class B:", objectB.title)
        
        objectB.title = "Second class title!"
        print("STEP 2: ClassB title changed")
        print("Class A:", objectA.title)
        print("Class B:", objectB.title)
    }
}

// Immutable struct

struct CustomStruct {
    let title: String
    
    /// As structs are immutable the fact of change the title implies recreate a new struct
    ///in memory so, this function is the same that the compiler do
    func updateTitle(newTitle: String) -> CustomStruct {
        .init(title: newTitle)
    }
}

struct MutatingStruct {
    private(set) var title: String // when i set this as private the init is private too
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorBootcamp {
    
    private func structTest2() {
        print ("structTest2")
        print("MyStruct")
        /// Lo colocamos variables porqué cuando escribo struct1.title = "Title2" estoy literalmente
        /// cambiando todo el objeto, no sólo cambiando la variable title. a diferencia de las clases que
        /// cambiamos la variable dentro del objeto
        var struct1 = MyStruct(title: "Title1")
        print ("Struct1: ", struct1.title)
        struct1.title = "Title2"
        print ("Struct1: ", struct1.title)
        
        print("CustomStruct")
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title)
        /// Here i crated a new struct and set as newValue for struct 2 because that what compilers does
        /// when i changed the title
        struct2 = CustomStruct (title: "Title2")
        print("Struct2: ", struct2.title)
        
        var struct3 = CustomStruct (title: "Title1")
        print ("Struct3:", struct3.title)
        struct3 = struct3.updateTitle (newTitle: "Title2")
        print ("Struct3: ", struct3.title)
        
        print("Mutating struct")
        var struct4 = MutatingStruct(title: "Title1")
        print ("Struct4 Mutating:", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print ("Struct4 Mutating:", struct4.title)
    }
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(title: String) {
        self.title = title
    }
}

extension StructClassActorBootcamp {
    private func classTest2() {
        print("Classtest2")
        
        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)
        class1.title = "Title2"
        print("Class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1")
        print("Class2: ", class2.title)
        class2.updateTitle(title: "Title2")
        print("Class2: ", class2.title)
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(title: String) {
        self.title = title
    }
}

extension StructClassActorBootcamp {
    private func actorTest1() async {
        let objectA = MyActor(title: "Starting actor title!")
        await print("Class A:", objectA.title)
        
        print("STEP 1: Passing REFERENCE from A to B")
        
        let objectB = objectA
        await print("Class B:", objectB.title)
        
        /// Esto no lo puedo hacer porqué las propeidades no se pueden mutar fuera del mismo actor
        ///objectB.title = "Second class title!"
        ///Por el contrario tengo que utilizar la función que se enceuntra dentro del Actor
        
        await objectB.updateTitle(title: "Second class title!")
        

        print("STEP 2: ClassB title changed")
        await print("Class A:", objectA.title)
        await print("Class B:", objectB.title)
    }
}
