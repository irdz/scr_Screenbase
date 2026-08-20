# Firebase plists

`GoogleService-Info-Dev.plist` and `GoogleService-Info-Prod.plist` are iOS wiring for the same Dev/Prod split used by NoTicketNYC and WordSync.

`GoogleService-Info-Dev.plist` is the live iOS config for `screenbase-dev-svc`. Replace the placeholder values in `GoogleService-Info-Prod.plist` with the real Prod app config from the Firebase console (or `firebase apps:sdkconfig`) once that project exists.

Enable **Anonymous** Authentication and Firestore so `AuthManager` / `UserManager` can sign in and write `users/{uid}`.
