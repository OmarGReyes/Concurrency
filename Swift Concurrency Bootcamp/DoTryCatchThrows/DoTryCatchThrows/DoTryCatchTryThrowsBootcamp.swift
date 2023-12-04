//
//  DoTryCatchTryThrowsBootcamp.swift
//  DoTryCatchThrows
//
//  Created by Omar Gonzalez on 22/11/23.
//

import SwiftUI

enum CustomErrors: String, Error {
    case customError = "Random error"
    
    var localizedCustomDescription: String {
        switch self {
        case .customError:
            return "Random error"
        }
    }
}

class DoTryCatchTryThrowsBootcampDataManager {
    let isActive = false
    func getTitle() -> (title: String?, error: CustomErrors?) {
        if isActive {
            return ("NEW TEXT", nil)
        } else {
            return (nil, CustomErrors.customError)
        }
    }
    
    func getTitleTwo() -> Result<String, CustomErrors> {
        if isActive {
            return .success("NEW TEXT TWO")
        } else {
            return .failure(CustomErrors.customError)
        }
    }
    
    func getTitleThree() throws -> String {
        if isActive {
            return "NEW TEXT THREE"
        } else {
            throw CustomErrors.customError
        }
    }

}

class DoTryCatchTryThrowsBootcampViewModel: ObservableObject {
    let manager = DoTryCatchTryThrowsBootcampDataManager()
    @Published var text = "Starting text."
    @Published var secondText = "Starting second text"
    @Published var thirdText = "Starting third text"
    
    func fetchTitle() {
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedCustomDescription
        }
    }
    
    func fetchTitleTwo() {
        let result = manager.getTitleTwo()
        switch result {
        case .success(let newTitleTwo):
            self.secondText = newTitleTwo
        case .failure(let error):
            self.secondText = error.localizedCustomDescription
        }
    }
    
    func fetchTitleThree() {
        do {
            self.thirdText = try manager.getTitleThree()
        } catch let error as CustomErrors {
            self.thirdText = error.rawValue
        } catch {
            self.thirdText = error.localizedDescription
        }
    }
}

struct DoTryCatchTryThrowsBootcamp: View {
    @StateObject private var viewModel = DoTryCatchTryThrowsBootcampViewModel()
    var body: some View {
        VStack {
            Text(viewModel.text)
                .frame(width: 300, height: 100)
                .background(Color.red)
                .onTapGesture {
                    viewModel.fetchTitle()
                }
            Text(viewModel.secondText)
                .frame(width: 300, height: 100)
                .background(Color.blue)
                .onTapGesture {
                    viewModel.fetchTitleTwo()
                }
            Text(viewModel.thirdText)
                .frame(width: 300, height: 100)
                .background(Color.green)
                .onTapGesture {
                    viewModel.fetchTitleThree()
                }
        }
    }
}

struct DoTryCatchTryThrowsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        DoTryCatchTryThrowsBootcamp()
    }
}
