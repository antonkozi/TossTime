//
//  TablesListView.swift
//  Toss_Time
//
//  Created by Ryan Ahrari on 11/11/21.
//
// This was created with SwiftUI, which we are not using so it doesn't exactly
// work, but is a good informational piece of code


//DONT TRY TO USE

import SwiftUI

struct TablesListView: View {
    @ObservedObject private var viewModel = TablesViewModel()
    var body: some View {
        NavigationView {
            List(viewModel.tables) { table in
                VStack(alignment: .leading){
                    Text(table.owner)
                        .font(.headline)
                    Text(table.rules)
                        .font(.subheadline)
                }
            }
            .navigationBarTitle("Tables")
            .onAppear(){
                self.viewModel.fetchData()
            }
        }
    }
}

struct TablesListView_Previews: PreviewProvider {
    static var previews: some View {
        TablesListView()
    }
}
