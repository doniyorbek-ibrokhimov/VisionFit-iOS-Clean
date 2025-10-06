//
//  ElevenLabsStreamer.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//


import Foundation
import AVFoundation
import Combine

class ElevenLabsStreamer: NSObject, ObservableObject {
    var player: AVPlayer?
    private var tempFileURL: URL?
    private var statusObserver: AnyCancellable?
    var task: URLSessionDataTask?
    private var session = AVAudioSession.sharedInstance()

    @Published var isPlaying: Bool = false

    private func activateSession() {
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: []
            )
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        do {
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set audio session active: \(error)")
        }
        
        do {
            try session.overrideOutputAudioPort(.speaker)
        } catch {
            print("Failed to set audio session override: \(error)")
        }
    }

    func startStreaming(text: String) {
        player?.pause()
        isPlaying = true
        
        activateSession()

        guard let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/XrExE9yKIg1WjnnlVkGX/stream?output_format=mp3_44100_128") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Constants.elevenLabsToken, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_flash_v2_5"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to encode body: \(error)")
            return
        }

        tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("tts-stream.mp3")
        guard let fileURL = tempFileURL else { return }

        // Remove existing file if needed
        try? FileManager.default.removeItem(at: fileURL)

        task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                try data.write(to: fileURL)
                DispatchQueue.main.async {
                    self.playAudio(from: fileURL)
                }
            } catch {
                print("Failed to write audio file: \(error)")
            }
        }

        task?.resume()
    }

    private func playAudio(from url: URL) {
        activateSession()
        
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        if let player = player {
            player.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
        }

        statusObserver = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
                guard let me = self else { return }
                print("Audio finished playing")
                me.isPlaying = false
                me.deactivateSession()
            }
        
        if let player = player {
            player.play()
        }
    }

    func deactivateSession() {
        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
            
        } catch let error as NSError {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }

    func stop() {
        player?.pause()
        task?.cancel()
        isPlaying = false
    }
    
    @objc private func audioDidFinishPlaying(_ notification: Notification) {
        print("Audio finished playing")
        isPlaying = false
        // Handle what you want to do after playback ends
    }

    deinit {
        // Clean up the observer
        NotificationCenter.default.removeObserver(self)

        statusObserver?.cancel()
    }
}
