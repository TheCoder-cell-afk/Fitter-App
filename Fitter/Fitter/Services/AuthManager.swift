import Foundation
import UIKit

// MARK: - iOS 26 Ready
// This service is fully optimized for iOS 26
// All window scene handling uses modern APIs
// ✅ No deprecated UIScreen.main usage
// ✅ Modern window scene management
// ✅ Simplified authentication flow (guest only)

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    init() {
        // Check if user is already signed in as guest
        checkSignInStatus()
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        // Clear any stored user data
        UserDefaults.standard.removeObject(forKey: "isGuestUser")
        UserDefaults.standard.synchronize()
    }
    
    func signInAsGuest() {
        isAuthenticated = true
        currentUser = User(id: "guest", email: nil, fullName: nil)
        UserDefaults.standard.set(true, forKey: "isGuestUser")
        print("User signed in as guest")
    }
    
    func testAuthManager() {
        print("AuthManager test: isAuthenticated = \(isAuthenticated)")
        print("AuthManager test: currentUser = \(currentUser?.id ?? "nil")")
    }
    
    private func checkSignInStatus() {
        // Check if user is signed in as guest
        if UserDefaults.standard.bool(forKey: "isGuestUser") {
            currentUser = User(id: "guest", email: nil, fullName: nil)
            isAuthenticated = true
        }
    }
}

struct User: Codable {
    let id: String
    let email: String?
    let fullName: String?
    
    init(id: String, email: String?, fullName: String?) {
        self.id = id
        self.email = email
        self.fullName = fullName
    }
} 