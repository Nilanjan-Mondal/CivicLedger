# CivicLedger — System Requirements

## 1. Overview

CivicLedger is a hybrid Web2 + Web3 civic issue reporting and accountability platform.

It enables:
- Citizens to report civic problems.
- Authorities to assign and resolve them.
- Public verification of issue lifecycle.
- Tamper-evident audit logs anchored on blockchain.

Blockchain is used as an integrity and non-repudiation layer. Operational data remains off-chain.

---

## 2. Objectives

1. Ensure civic complaints cannot be silently deleted or altered.
2. Provide transparent workflow from issue creation to resolution.
3. Prevent false "resolved" status using live-capture verification.
4. Enable SLA-based escalation tracking.
5. Create publicly verifiable audit records of civic performance.

---

## 3. System Architecture

### Layer 1 — Mobile Application (React Native)
- Citizen reporting
- Officer resolution submission (live capture only)
- Confirmation/dispute flow

### Layer 2 — Backend (Node.js + Express)
- Authentication & authorization
- Media handling (Cloudinary)
- Data storage (MongoDB)
- Geofence validation
- Challenge/nonce validation
- SLA tracking
- Blockchain write integration

### Layer 3 — Storage
- MongoDB for structured data
- Cloudinary for media
- No media stored on-chain

### Layer 4 — Blockchain (Polygon Testnet)
- Immutable event anchoring
- Hash storage only
- Workflow transition records

---

## 4. User Roles

### Citizen
- Register/login
- Report issue
- View issues
- Endorse issues
- Confirm or dispute resolution

### Officer
- View assigned issues
- Submit resolution via in-app live capture
- Add resolution note

### Admin
- Assign issues
- Configure SLA
- Trigger escalations
- View performance analytics

---

## 5. Functional Requirements

### FR-1: Issue Creation
- Must capture media via in-app camera.
- Must record location.
- Must compute content/media hash.
- Must anchor creation event on blockchain.

### FR-2: Assignment
- Admin assigns issue to officer.
- SLA deadline must be recorded.
- Assignment event must be anchored on blockchain.

### FR-3: Resolution Submission
- Must use live capture only (no gallery upload).
- Must validate challenge nonce.
- Must verify geofence.
- Must store resolution hash on blockchain.

### FR-4: Verification
- Citizens can confirm resolution.
- Citizens can dispute with evidence.
- Events anchored on blockchain.

### FR-5: SLA Escalation
- System auto-detects overdue issues.
- Escalation event recorded on blockchain.

---

## 6. Non-Functional Requirements

- Security: JWT authentication, role-based access.
- Privacy: No PII stored on-chain.
- Scalability: Media off-chain.
- Availability: Retry-safe submission flow.
- Auditability: Blockchain-backed verification.
