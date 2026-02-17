# CivicLedger — Issue Lifecycle State Machine

## 1. States

| State | Description |
|--------|------------|
| OPEN | Issue created by citizen |
| ASSIGNED | Assigned to officer |
| IN_PROGRESS | Officer acknowledged work |
| RESOLVED_PENDING | Officer submitted resolution |
| CLOSED | Resolution verified |
| DISPUTED | Resolution contested |
| ESCALATED | SLA violated |

---

## 2. State Transitions

### 1. Create Issue
NONE → OPEN  
Actor: Citizen  
Blockchain Event: IssueCreated

---

### 2. Assign Issue
OPEN → ASSIGNED  
Actor: Admin  
Blockchain Event: IssueAssigned

---

### 3. Start Work (Optional)
ASSIGNED → IN_PROGRESS  
Actor: Officer  

---

### 4. Submit Resolution
ASSIGNED / IN_PROGRESS → RESOLVED_PENDING  
Actor: Officer  
Requirements:
- Live capture
- Valid nonce
- Geofence validation  
Blockchain Event: ResolutionSubmitted

---

### 5. Confirm Resolution
RESOLVED_PENDING → CLOSED  
Actor: Citizen  
Blockchain Event: ResolutionConfirmed

---

### 6. Dispute Resolution
RESOLVED_PENDING → DISPUTED  
Actor: Citizen  
Blockchain Event: ResolutionDisputed

---

### 7. Escalation
OPEN / ASSIGNED / IN_PROGRESS → ESCALATED  
Actor: System / Admin  
Condition: SLA deadline exceeded  
Blockchain Event: IssueEscalated

---

## 3. Authority Matrix

| Action | Citizen | Officer | Admin | System |
|--------|---------|---------|-------|--------|
| Create Issue | ✓ | ✗ | ✗ | ✗ |
| Assign Issue | ✗ | ✗ | ✓ | ✗ |
| Submit Resolution | ✗ | ✓ | ✗ | ✗ |
| Confirm | ✓ | ✗ | ✗ | ✗ |
| Dispute | ✓ | ✗ | ✗ | ✗ |
| Escalate | ✗ | ✗ | ✓ | ✓ |
