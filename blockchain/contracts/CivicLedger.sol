// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * CivicLedger
 * - On-chain = process + proofs (hashes + timestamps + actors)
 * - Off-chain = media/content (Cloudinary/IPFS) and full search (Mongo)
 */
contract CivicLedger is AccessControl {
    bytes32 public constant ADMIN_ROLE  = keccak256("ADMIN_ROLE");
    bytes32 public constant OFFICER_ROLE = keccak256("OFFICER_ROLE");

    enum Status {
        NONE,
        OPEN,
        ASSIGNED,
        IN_PROGRESS,
        RESOLVED_PENDING,
        CLOSED,
        DISPUTED,
        ESCALATED
    }

    struct Issue {
        Status status;
        address creator;        // citizen wallet OR backend relayer identity (MVP)
        address officer;        // assigned officer
        uint64 createdAt;
        uint64 slaDueAt;        // set at assignment
        bytes32 metaHash;       // hash(description + category + geohash + etc.)
        bytes32 mediaHash;      // hash of the original issue media file
        bytes32 resolutionMediaHash;
        bytes32 resolutionProofHash; // hash(proof bundle JSON)
        bytes32 disputeHash;    // hash(dispute evidence JSON/media)
    }

    mapping(bytes32 => Issue) private issues;

    // ============ Events (Public Audit Trail) ============
    event IssueCreated(
        bytes32 indexed issueId,
        address indexed creator,
        bytes32 geoHash,
        bytes32 metaHash,
        bytes32 mediaHash,
        uint64 createdAt
    );

    event IssueAssigned(
        bytes32 indexed issueId,
        address indexed admin,
        address indexed officer,
        uint64 slaDueAt,
        uint64 assignedAt
    );

    event WorkAcknowledged(
        bytes32 indexed issueId,
        address indexed officer,
        uint64 acknowledgedAt
    );

    event ResolutionSubmitted(
        bytes32 indexed issueId,
        address indexed officer,
        bytes32 resolutionMediaHash,
        bytes32 resolutionProofHash,
        uint64 submittedAt
    );

    event ResolutionConfirmed(
        bytes32 indexed issueId,
        address indexed confirmer,
        uint64 confirmedAt
    );

    event ResolutionDisputed(
        bytes32 indexed issueId,
        address indexed disputer,
        bytes32 disputeHash,
        uint64 disputedAt
    );

    event IssueEscalated(
        bytes32 indexed issueId,
        address indexed actor,
        bytes32 reasonHash,
        uint64 escalatedAt
    );

    // ============ Constructor ============
    constructor(address initialAdmin) {
        require(initialAdmin != address(0), "admin=0");
        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
        _grantRole(ADMIN_ROLE, initialAdmin);
    }

    // ============ Views ============
    function getIssue(bytes32 issueId) external view returns (Issue memory) {
        return issues[issueId];
    }

    // ============ Core Workflow ============
    /**
     * Create Issue
     * geoHash: coarse geohash (privacy-friendly)
     * metaHash: hash of normalized metadata (title/desc/category/geohash/pointer hash etc.)
     * mediaHash: hash of uploaded media file
     *
     * Note: Anyone can create in MVP (citizen). In production you may restrict to verified identities.
     */
    function createIssue(
        bytes32 issueId,
        bytes32 geoHash,
        bytes32 metaHash,
        bytes32 mediaHash
    ) external {
        Issue storage it = issues[issueId];
        require(it.status == Status.NONE, "exists");

        it.status = Status.OPEN;
        it.creator = msg.sender;
        it.createdAt = uint64(block.timestamp);
        it.metaHash = metaHash;
        it.mediaHash = mediaHash;

        emit IssueCreated(issueId, msg.sender, geoHash, metaHash, mediaHash, it.createdAt);
    }

    /**
     * Assign Issue to officer + SLA due timestamp
     * Only Admin can assign.
     */
    function assignIssue(bytes32 issueId, address officer, uint64 slaDueAt) external onlyRole(ADMIN_ROLE) {
        Issue storage it = issues[issueId];
        require(it.status == Status.OPEN || it.status == Status.ESCALATED, "bad_state");
        require(officer != address(0), "officer=0");
        require(slaDueAt > block.timestamp, "sla_past");

        it.status = Status.ASSIGNED;
        it.officer = officer;
        it.slaDueAt = slaDueAt;

        emit IssueAssigned(issueId, msg.sender, officer, slaDueAt, uint64(block.timestamp));
    }

    /**
     * Officer acknowledges start of work (optional, but good for audit trail)
     */
    function acknowledgeWork(bytes32 issueId) external onlyRole(OFFICER_ROLE) {
        Issue storage it = issues[issueId];
        require(it.status == Status.ASSIGNED, "bad_state");
        require(it.officer == msg.sender, "not_assigned");

        it.status = Status.IN_PROGRESS;
        emit WorkAcknowledged(issueId, msg.sender, uint64(block.timestamp));
    }

    /**
     * Officer submits resolution evidence hashes.
     * Only the assigned officer can do this.
     */
    function submitResolution(
        bytes32 issueId,
        bytes32 resolutionMediaHash,
        bytes32 resolutionProofHash
    ) external onlyRole(OFFICER_ROLE) {
        Issue storage it = issues[issueId];
        require(
            it.status == Status.ASSIGNED || it.status == Status.IN_PROGRESS || it.status == Status.ESCALATED,
            "bad_state"
        );
        require(it.officer == msg.sender, "not_assigned");

        it.status = Status.RESOLVED_PENDING;
        it.resolutionMediaHash = resolutionMediaHash;
        it.resolutionProofHash = resolutionProofHash;

        emit ResolutionSubmitted(issueId, msg.sender, resolutionMediaHash, resolutionProofHash, uint64(block.timestamp));
    }

    /**
     * Citizen (or any verifier in MVP) confirms resolution.
     * In production you may restrict to reporter/local witnesses/verified identities.
     */
    function confirmResolution(bytes32 issueId) external {
        Issue storage it = issues[issueId];
        require(it.status == Status.RESOLVED_PENDING, "bad_state");

        it.status = Status.CLOSED;
        emit ResolutionConfirmed(issueId, msg.sender, uint64(block.timestamp));
    }

    /**
     * Citizen disputes resolution with disputeHash (evidence off-chain).
     */
    function disputeResolution(bytes32 issueId, bytes32 disputeHash) external {
        Issue storage it = issues[issueId];
        require(it.status == Status.RESOLVED_PENDING, "bad_state");

        it.status = Status.DISPUTED;
        it.disputeHash = disputeHash;

        emit ResolutionDisputed(issueId, msg.sender, disputeHash, uint64(block.timestamp));
    }

    /**
     * Admin/System escalates issue with a reasonHash (hash of escalation reason JSON).
     * This creates an immutable record that SLA was violated or issue requires higher attention.
     */
    function escalateIssue(bytes32 issueId, bytes32 reasonHash) external onlyRole(ADMIN_ROLE) {
        Issue storage it = issues[issueId];
        require(it.status != Status.NONE, "no_issue");
        require(it.status != Status.CLOSED, "closed");

        it.status = Status.ESCALATED;
        emit IssueEscalated(issueId, msg.sender, reasonHash, uint64(block.timestamp));
    }

    // ============ Admin helpers ============
    function grantOfficer(address officer) external onlyRole(ADMIN_ROLE) {
        require(officer != address(0), "officer=0");
        _grantRole(OFFICER_ROLE, officer);
    }

    function revokeOfficer(address officer) external onlyRole(ADMIN_ROLE) {
        _revokeRole(OFFICER_ROLE, officer);
    }
}
