# CivicLedger — Threat Model

## 1. Officer Submits Fake Photo

Mitigation:
- In-app capture only
- Challenge nonce
- Geofence validation
- Blockchain anchoring of evidence hash

---

## 2. Officer Edits Resolution Later

Mitigation:
- Immutable blockchain event log
- Stored media hash comparison

---

## 3. Admin Deletes Complaint

Mitigation:
- Issue creation hash anchored on blockchain
- Public audit verification possible

---

## 4. Collusive Confirmations

Mitigation (MVP):
- Reporter-only confirmation

Mitigation (Future):
- Geofence-based confirmations
- Stake-based confirmation
- Reputation weighting

---

## 5. SLA Manipulation

Mitigation:
- SLA due timestamp stored on-chain during assignment
- Escalation event recorded immutably

---

## 6. Location Spoofing

Mitigation:
- Accuracy threshold
- Impossible movement detection
- Device attestation (future enhancement)
