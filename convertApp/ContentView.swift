//
//  ContentView.swift
//  convertApp
//
//  Created by 0x67 on 2024-05-12.
//  Copyright © 2024 Apple. All rights reserved.
//
import Spatial
import SwiftUI

struct ContentView: View, Sendable {
    @State private var isConverting = false
    @State private var conversionCompleted = false
    @State private var mvHEVCVideo: URL? = nil
    @State private var showVideoPlayer = false
    
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    conversionCompleted = false
                    isConverting = true
                    try await convert()
                    isConverting = false
                }
            }, label: {
                Text("Convert")
            }).buttonStyle(BorderedButtonStyle())
            
            if isConverting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            if conversionCompleted {
                Button(action: {
                    showVideoPlayer = true
                }, label: {
                    Text("Play")
                }).buttonStyle(BorderedButtonStyle())
                    .sheet(isPresented: $showVideoPlayer) {
                        VideoPlayerView(url: mvHEVCVideo!)
                }
            }
        }
    }
    
    private func convert() async throws {
        let sideBySideVideo = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        
        let fileName = sideBySideVideo.deletingPathExtension().lastPathComponent + "_MVHEVC.mov"
        // Saving to writable document root
        let mvHEVCVideo = URL(filePath: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent(fileName))
        
        debugPrint("saving path: \(mvHEVCVideo.path(percentEncoded: true))")
        
        if FileManager.default.fileExists(atPath: mvHEVCVideo.path(percentEncoded: true)) {
            try? FileManager.default.removeItem(atPath: mvHEVCVideo.path(percentEncoded: true))
        }
        
        let converter = try await SideBySideConverter(from: sideBySideVideo)
       
        
        await converter.transcodeToMVHEVC(output: mvHEVCVideo)
        
        print("MV-HEVC video encoded to \(mvHEVCVideo)")
        
        self.mvHEVCVideo = mvHEVCVideo
        
        conversionCompleted = true
    }
}

#Preview {
    ContentView()
}


private func convert() async throws {
    let sideBySideVideo = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
    let converter = try await SideBySideConverter(from: sideBySideVideo)
    
    let fileName = sideBySideVideo.deletingPathExtension().lastPathComponent + "_MVHEVC.mov"
    //        let mvHEVCVideo = sideBySideVideo.deletingLastPathComponent().appendingPathComponent(fileName)
    // Saving to writable document root
    let mvHEVCVideo = URL(filePath: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent(fileName))
    
    debugPrint("promised export path: \(mvHEVCVideo.path(percentEncoded: true))")
    
    if FileManager.default.fileExists(atPath: mvHEVCVideo.path(percentEncoded: true)) {
        try FileManager.default.removeItem(at: mvHEVCVideo)
    }
    
    await converter.transcodeToMVHEVC(output: mvHEVCVideo)
    
    print("MV-HEVC video encoded to \(mvHEVCVideo)")
}

#Preview {
    ContentView()
}



import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    var url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No update needed
    }
}
