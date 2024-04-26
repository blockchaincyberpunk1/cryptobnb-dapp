// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title DisputeResolutionContract
 * @dev Manages and resolves disputes between hosts and guests over bookings or transactions.
 */
contract DisputeResolutionContract is AccessControl {
    struct Dispute {
        uint256 disputeId;
        uint256 bookingId;
        address complainant;
        string description;
        bool resolved;
    }

    // State variables
    uint256 public nextDisputeId;
    mapping(uint256 => Dispute) public disputes;

    // Define roles
    bytes32 public constant ARBITRATOR_ROLE = keccak256("ARBITRATOR_ROLE");

    // Events
    event DisputeRaised(uint256 indexed disputeId, uint256 indexed bookingId, address indexed complainant);
    event DisputeResolved(uint256 indexed disputeId, uint256 bookingId);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // Assign admin role to the deployer
        _setupRole(ARBITRATOR_ROLE, msg.sender); // Optionally assign the arbitrator role to the deployer
    }

    /**
     * @notice Allows a user to raise a dispute over a booking or transaction.
     * @param _bookingId The ID of the booking related to the dispute.
     * @param _description A brief description of the dispute.
     */
    function raiseDispute(uint256 _bookingId, string calldata _description) external {
        disputes[nextDisputeId] = Dispute({
            disputeId: nextDisputeId,
            bookingId: _bookingId,
            complainant: msg.sender,
            description: _description,
            resolved: false
        });

        emit DisputeRaised(nextDisputeId, _bookingId, msg.sender);
        nextDisputeId++;
    }

    /**
     * @notice Resolves a dispute, typically after review by an admin or arbitrator.
     * @param _disputeId The ID of the dispute to resolve.
     */
    function resolveDispute(uint256 _disputeId) external onlyRole(ARBITRATOR_ROLE) {
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Dispute already resolved");

        dispute.resolved = true;

        emit DisputeResolved(_disputeId, dispute.bookingId);
    }
}
