//
//  VideoRecorderDelegate.swift
//  PipecatClientIOSGeminiLiveWebSocket
//
//  Created by Doniyorbek Ibrokhimov on 27/04/25.
//


import AVFoundation
import UIKit

public protocol VideoRecorderDelegate {
    func streamVideo() -> AsyncStream<Data>
    var streamContinuation: AsyncStream<Data>.Continuation? { get set }
}
