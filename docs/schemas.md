# CivicLedger — Database Schemas

## users

{
  "_id": ObjectId,
  "role": "citizen | officer | admin",
  "name": String,
  "email": String,
  "passwordHash": String,
  "walletAddress": String,
  "reputation": Number,
  "createdAt": Date,
  "updatedAt": Date
}

---

## issues

{
  "_id": ObjectId,
  "issueId": String,
  "chainIssueId": String,
  "title": String,
  "description": String,
  "category": String,
  "location": {
    "lat": Number,
    "lon": Number,
    "geoHash": String
  },
  "media": {
    "cloudinaryUrl": String,
    "mediaHash": String
  },
  "status": String,
  "createdByUserId": ObjectId,
  "assignedOfficerUserId": ObjectId,
  "slaDueAt": Date,
  "endorseCount": Number,
  "resolution": {
    "resolutionNote": String,
    "resolutionMediaHash": String,
    "proofBundleHash": String
  },
  "blockchainTxs": {
    "createTx": String,
    "assignTx": String,
    "resolveTx": String,
    "confirmTx": String,
    "disputeTx": String,
    "escalateTx": String
  },
  "createdAt": Date,
  "updatedAt": Date
}

---

## challenges

{
  "_id": ObjectId,
  "issueId": ObjectId,
  "officerUserId": ObjectId,
  "nonce": String,
  "expiresAt": Date,
  "used": Boolean
}
