//
//  ContentView.swift
//  VideoSharingTest
//
//  Created by MinKyeongTae on 2023/03/12.
//

import SwiftUI
import Photos

final class MainViewModel: ObservableObject {
  @Published var isActivityViewPresented = false
  private let videoURLString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
  var videoURL: URL?
  
  func onAppear() {
    let urlString = videoURLString
    DispatchQueue.global(qos: .background).async { [weak self] in
      guard
        let self,
        let url = URL(string: urlString),
        let urlData = try? Data(contentsOf: url),
        var urlToSave = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
      }
      urlToSave.appendPathComponent("tempFile.mp4")
      self.videoURL = urlToSave
      // file:///var/mobile/Containers/Data/Application/DDA44E20-53B3-4DDA-A3FC-3E5FE08D5F38/Documents.tempFile.mp4
      DispatchQueue.main.async {
        try? urlData.write(to: urlToSave)
        // self.videoURL?.startAccessingSecurityScopedResource()
        self.isActivityViewPresented = true
      }
    }
  }
}

struct ContentView: View {
  @StateObject private var viewModel = MainViewModel()
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
    }
    .padding()
    .onAppear {
      viewModel.onAppear()
    }
    .sheet(
      isPresented: Binding(
        get: { viewModel.isActivityViewPresented },
        set: { _, _ in
          
        }),
      content: {
        if let url = viewModel.videoURL {
          ActivityViewController(activityItems: [url])
        } else {
          Text("Fuck")
        }
      }
    )
  }
}

struct ActivityViewController: UIViewControllerRepresentable {
  var activityItems: [Any]
  var applicationActivities: [UIActivity]? = nil
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
    let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
