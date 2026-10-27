# Hardening for production

| Gap in the demo | Production answer |
|---|---|
| The request is simulated in the app | Push through APNs (paid developer account) |
| The user approves without proving they started the sign-in | Number matching: the sign-in page shows a number typed in the app (NIST SP 800-63B-4, CISA) |
| Any public key is accepted at enrollment | Enroll only from a session already authenticated, and bind the key to the account |
| Nothing proves the request comes from the genuine app | App Attest |
| Repeated push requests can wear the user down (push bombing) | Number matching, rate limiting, alert on repeated denials |

Out-of-band approval is not phishing-resistant: a user can approve a sign-in started by an attacker on a fake page. Passkeys cover phishing-resistant sign-in; approval covers the details of an operation, which WebAuthn cannot sign.
