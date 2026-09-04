# Firebase plists

`GoogleService-Info-Dev.plist` and `GoogleService-Info-Prod.plist` are iOS wiring for the same Dev/Prod split used by NoTicketNYC and WordSync.

* **Dev:** live iOS config for `screenbase-dev-svc`
* **Prod:** live iOS config for `screenbase-prod-svc-h7p2` (bundle `com.getscreenbase.Screenbase`)

Enable **Anonymous** Authentication and Firestore so `AuthManager` / `UserManager` can sign in and write `users/{uid}`.
