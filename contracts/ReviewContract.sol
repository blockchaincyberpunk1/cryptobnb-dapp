// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ReviewContract
 * @dev Manages user and property reviews on the platform, enabling accountability and trust.
 */
contract ReviewContract is AccessControl {
    struct Review {
        uint256 targetId; // Can be either propertyId or userId
        address reviewer;
        string reviewText;
        uint8 rating; // Rating out of 5
        uint256 timestamp;
    }

    // Define role for reviewers
    bytes32 public constant REVIEWER_ROLE = keccak256("REVIEWER_ROLE");

    // Reviews storage
    Review[] private reviews;

    // Mapping from targetId to list of review indexes for retrieval
    mapping(uint256 => uint256[]) private targetToReviews;

    // Events
    event ReviewAdded(uint256 indexed targetId, address indexed reviewer, uint8 rating, uint256 timestamp);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // Assign admin role to contract deployer
    }

    /**
     * @notice Allows a user to leave a review and rating for a property or guest.
     * @param _targetId The ID of the target being reviewed (propertyId or userId).
     * @param _reviewText Text content of the review.
     * @param _rating Rating given by the reviewer, out of 5.
     */
    function leaveReview(uint256 _targetId, string calldata _reviewText, uint8 _rating) external onlyRole(REVIEWER_ROLE) {
        require(_rating > 0 && _rating <= 5, "Invalid rating; must be between 1 and 5.");
        
        reviews.push(Review({
            targetId: _targetId,
            reviewer: msg.sender,
            reviewText: _reviewText,
            rating: _rating,
            timestamp: block.timestamp
        }));

        targetToReviews[_targetId].push(reviews.length - 1);

        emit ReviewAdded(_targetId, msg.sender, _rating, block.timestamp);
    }

    /**
     * @notice Retrieves all reviews related to a specific property or user.
     * @param _targetId The ID of the target whose reviews to retrieve.
     * @return reviewData An array of reviews for the given target.
     */
    function getReviews(uint256 _targetId) external view returns (Review[] memory reviewData) {
        uint256[] storage reviewIndexes = targetToReviews[_targetId];
        reviewData = new Review[](reviewIndexes.length);

        for (uint256 i = 0; i < reviewIndexes.length; i++) {
            reviewData[i] = reviews[reviewIndexes[i]];
        }

        return reviewData;
    }
}
