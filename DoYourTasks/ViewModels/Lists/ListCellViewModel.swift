//
//  ListCellViewModel.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 31/10/2020.
//

import Foundation
import Combine

final class ListCellViewModel: Identifiable, ObservableObject {
    @Published private(set) var list: ListModel
    
    private var cancellable = Set<AnyCancellable>()
    
    var id = ""
    
    static var placeholder: ListCellViewModel {
        ListCellViewModel(list: ListModel.placeholder)
    }
    
    init(list: ListModel) {
        self.list = list
        
        $list
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellable)
    }
    
    public var name: String {
        list.name
    }
}
