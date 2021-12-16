//
//  AppSettings.swift
//  URLSessionStartProject
//
//  Created by Alexey Pavlov on 29/11/21.
//

import Foundation

public final class ApplicationSettingsService {

    private enum UserDefaultsKey {
        static let login = "LOGIN_KEY"
        static let passwordRef = "PASSWORDREF_KEY"
        static let pushToken = "PUSH_TOKEN_KEY"
        static let vpnServers = "VPNSERVERS_KEY"
        static let currentHostListIndex = "CURRENT_HOST_LIST_INDEX_KEY"
        static let hostOptionsFavoritesBool = "HOST_OPTIONS_FAVORITES_BOOL_KEY"
        static let blacklist = "BLACKLIST_KEY"
        static let deviceId = "DEVICEID_KEY"

        static let firstTutorialPresentationFlag = "TutorialHasBeenLaunchedBeforeFlag"
        static let installLandingFlag = "InstallLandingFlag"
        static let firstAllowObjectsPresentationFlag = "AllowObjectsHasBeenLaunchedBeforeFlag"
        static let bufferClipboardFlag = "BufferClipboardFlag"
        static let masterServerURLObjectFlag = "masterServerFlag"
        static let isUserAcceptedPrivacyAndSecurity = "isUserAcceptedPrivacyAndSecurity"

        static let didShowGetAccountFreeScreen = "didShowGetAccountFreeScreen"
        static let isUserOrganic = "isUserOrganic"
    }
    
    // MARK: - Types
    
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    enum Const {
        static let keyReceiptFileModificationTimeStamp = "receipt_file_modification_timestamp"
        static let lastReceiptFileName = "last_receipt.json"
    }
    
    enum ShowEventType {
        case tutorial
        case allowObjects
        case installLanding
        
        var key: String {
            switch self {
            case .allowObjects:
                return UserDefaultsKey.firstAllowObjectsPresentationFlag
            case .tutorial:
                return UserDefaultsKey.firstTutorialPresentationFlag
            case .installLanding:
                return UserDefaultsKey.installLandingFlag
            }
        }
    }
    
    // MARK: - Private Properties

    private let passwordLock = NSLock()
    
    // MARK: - Initialization
    
    // MARK: - Public
  
}
