//
//  ContentView.swift
//  PhDownloader Example
//
//  Created by Hoc Nguyen T. on 10/19/22.
//

import SwiftUI
import PhDownloader
import Combine
import RxSwift

struct ItemRow: View {
  let item: Item
  let onTapItem: () -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      Text("Id: \(item.request.identifier)")
        .foregroundColor(.primary)
        .font(.headline)
      
      Text("State: \(item.state.debugDescription)")
        .foregroundColor(color(for: item.state))
        .font(.subheadline)
    }.onTapGesture { onTapItem() }
  }
}

struct ContentView: View {
  @ObservedObject
  var viewModel = ViewModel()

  var body: some View {
    NavigationView {
      List {
        ForEach(self.viewModel.items, id: \.request.identifier) { item in
          ItemRow(
            item: item,
            onTapItem: { self.viewModel.onTap(item: item) }
          )
        }
      }.navigationTitle("PhDownloader Example")
    }
  }
}

func color(for state: PhDownloadState) -> Color {
  switch state {

  case .undefined:
    return .gray
  case .enqueued:
    return .orange
  case .downloading:
    return .init(red: 0x00 / 255.0, green: 0xC8 / 255.0, blue: 0x53 / 255.0, opacity: 1)
  case .completed:
    return .blue
  case .failed:
    return .red
  case .cancelled:
    return .pink
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
