//
//  AppCore.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//

import SwiftUI

final class AppCore: ObservableObject {
    static let shared = AppCore()
    private init() {}
    
    @AppStorage(Keys.isDebugModeEnabled)
    var isDebugModeEnabled: Bool = false
    
    @AppStorage(Keys.lang)
    var language: Language = .en

    @MainActor
    func toggleLanguage() {
        language = language == .ru ? .en : .ru
    }
    
    @AppStorage(Keys.token)
    var token: String?
    
    @AppStorage(Keys.isFcmTokenSent)
    var isFcmTokenSent: Bool = false
    
    @AppStorage(Keys.fcmToken)
    var fcmToken: String?
    
    @Published var pdfURL: URL?
    
    @MainActor
    func showPDFViewer(for url: URL) {
        pdfURL = url
    }
    
    @MainActor
    func setToken(_ token: String) {
        self.token = token
    }
    
    @MainActor
    func showError(msg: String? = nil) {
        showToast(msg: msg, type: .error)
    }
    
    @Published var toastMsg: String?
    @Published var toastType: ToastType = .error
    
    @MainActor
    func showToast(msg: String? = nil, type: ToastType) {
        toastType = type
        toastMsg = msg
    }
    
    @MainActor
    func logout() {
        resetDefaults()
        token = nil
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    func removeFromAppStorage(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Keys
    enum Keys {
        static let token = "token"
        static let lang = "lang"
        static let isDebugModeEnabled = "isDebugModeEnabled"
        static let isFcmTokenSent = "isFcmTokenSent"
        static let fcmToken = "fcmToken"
    }
}


enum Language: String, Identifiable, CaseIterable {
    case ru = "ru"
    case en = "en"
    
    var title: String {
        switch self {
        case .ru: "Русский"
        case .en: "English"
        }
    }
    
    var id: String { self.rawValue }
    
    var locale: Locale {
        switch self {
        case .ru: Locale(identifier: "ru_RU")
        case .en: Locale(identifier: "en_EN")
        }
    }
    
    enum Keys {
        static let token = "token"
    }
}
