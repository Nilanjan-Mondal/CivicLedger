const { expect } = require("chai");
const { ethers } = require("hardhat");

function b32(str) {
  return ethers.keccak256(ethers.toUtf8Bytes(str));
}

describe("CivicLedger", function () {
  it("creates, assigns, resolves, confirms", async function () {
    const [admin, officer, citizen] = await ethers.getSigners();

    const CivicLedger = await ethers.getContractFactory("CivicLedger");
    const c = await CivicLedger.deploy(admin.address);
    await c.waitForDeployment();

    // grant officer role
    await c.connect(admin).grantOfficer(officer.address);

    const issueId = b32("issue-1");
    const geoHash = b32("geohash");
    const metaHash = b32("meta");
    const mediaHash = b32("media");

    await expect(c.connect(citizen).createIssue(issueId, geoHash, metaHash, mediaHash))
      .to.emit(c, "IssueCreated");

    const slaDueAt = BigInt(Math.floor(Date.now() / 1000) + 7 * 24 * 3600);
    await expect(c.connect(admin).assignIssue(issueId, officer.address, slaDueAt))
      .to.emit(c, "IssueAssigned");

    const resMediaHash = b32("res-media");
    const proofHash = b32("proof");

    await expect(c.connect(officer).submitResolution(issueId, resMediaHash, proofHash))
      .to.emit(c, "ResolutionSubmitted");

    await expect(c.connect(citizen).confirmResolution(issueId))
      .to.emit(c, "ResolutionConfirmed");

    const issue = await c.getIssue(issueId);
    expect(issue.status).to.equal(5n); // CLOSED

  });
});
