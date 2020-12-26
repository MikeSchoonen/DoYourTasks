//
//  LazyGridSelection.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 19/12/2020.
//

import SwiftUI

struct LazyGridSelection: View {
    private var columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    @State private var selectedItems: [Item] = []
    @State private var items: [Item] = [
        .init(name: "First item"),
        .init(name: "Second item"),
        .init(name: "Third item"),
        .init(name: "Fourth item"),
        .init(name: "Fifth item"),
        .init(name: "Sixth item"),
        .init(name: "Seventh item"),
        .init(name: "Eigth item"),
        .init(name: "Nineth item"),
        .init(name: "Tenth item")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(items) { item in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .aspectRatio(1, contentMode: .fit)
                                .foregroundColor(color(for: item))
                            Text(item.name)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            if selectedItems.contains(where: { $0.id == item.id }) {
                                selectedItems.removeAll { $0.id == item.id ? true : false }
                            } else {
                                selectedItems.append(item)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select items")
        }
    }
    
    func color(for item: Item) -> Color {
        selectedItems.contains(where: { $0.id == item.id }) ? Color.green : Color.orange
    }
}

struct Item: Identifiable {
    let id = UUID()
    var name: String
}

struct LazyGridSelection_Previews: PreviewProvider {
    static var previews: some View {
        LazyGridSelection()
    }
}
