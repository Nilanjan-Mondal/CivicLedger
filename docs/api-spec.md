# CivicLedger — API Specification

Base URL: /api

---

## Authentication

POST /auth/register  
POST /auth/login  

---

## Issue Creation

POST /issues  
Auth: Citizen  
Form:
- photo (file)
- title
- description
- category
- lat
- lon

Server:
- Upload to Cloudinary
- Compute hash
- Store Mongo
- Call blockchain createIssue()

---

GET /issues  
Query:
- status
- category
- near

---

## Assignment

POST /issues/:id/assign  
Auth: Admin  
Body:
{
  "officerUserId": "...",
  "slaDays": 7
}

---

## Resolution Challenge

POST /issues/:id/resolution/challenge  
Auth: Officer  
Returns:
{
  "nonce": "...",
  "expiresAt": "..."
}

---

## Resolution Submission

POST /issues/:id/resolution/submit  
Auth: Officer  
Form:
- media
- nonce
- lat
- lon
- resolutionNote

Server:
- Validate nonce
- Validate geofence
- Upload media
- Compute hashes
- Call blockchain submitResolution()

---

## Confirm Resolution

POST /issues/:id/confirm  
Auth: Citizen  

---

## Dispute Resolution

POST /issues/:id/dispute  
Auth: Citizen  
Form:
- media (optional)
- reason
