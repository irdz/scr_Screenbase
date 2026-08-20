# Firebase plists

`GoogleService-Info-Dev.plist` and `GoogleService-Info-Prod.plist` are iOS wiring for the same Dev/Prod split used by NoTicketNYC and WordSync.

Live GCP/Firebase projects are provisioned in SCR-33. Replace the placeholder values in these plists with the real iOS app configs from the Firebase console (or `firebase apps:sdkconfig`) once those projects exist.

Enable **Anonymous** Authentication and Firestore so `AuthManager` / `UserManager` can sign in and write `users/{uid}`.
