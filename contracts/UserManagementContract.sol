// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title UserManagementContract
 * @dev Manages user registrations, profile updates, and access to user profiles,
 * leveraging OpenZeppelin's Ownable and AccessControl for secure access management.
 */
contract UserManagementContract is Ownable, AccessControl {
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    struct UserProfile {
        string name;
        string contactInfo; // Generic string to hold contact information, could be an email or phone number.
        string bio; // Short bio or description about the user.
    }

    mapping(address => UserProfile) private userProfiles;

    event UserRegistered(address userAddress, string name);
    event UserProfileUpdated(address userAddress, string newName, string newContactInfo, string newBio);
    event UserRoleGranted(address userAddress, address grantedBy);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // Assign the deployer the default admin role.
    }

    /**
     * @dev Registers a new user on the platform.
     * @param userAddress address of the user to register.
     * @param name name of the user.
     * @param contactInfo contact information of the user.
     * @param bio short biography of the user.
     */
    function registerUser(address userAddress, string memory name, string memory contactInfo, string memory bio) public {
        require(!hasRole(USER_ROLE, userAddress), "UserManagement: user already registered.");
        userProfiles[userAddress] = UserProfile(name, contactInfo, bio);
        grantRole(USER_ROLE, userAddress);
        emit UserRegistered(userAddress, name);
    }

    /**
     * @dev Updates the profile of a registered user.
     * @param newName new name of the user.
     * @param newContactInfo new contact information of the user.
     * @param newBio new short biography of the user.
     */
    function updateProfile(string memory newName, string memory newContactInfo, string memory newBio) public {
        require(hasRole(USER_ROLE, msg.sender), "UserManagement: only registered users can update their profile.");
        UserProfile storage profile = userProfiles[msg.sender];
        profile.name = newName;
        profile.contactInfo = newContactInfo;
        profile.bio = newBio;
        emit UserProfileUpdated(msg.sender, newName, newContactInfo, newBio);
    }

    /**
     * @dev Retrieves the profile of a registered user.
     * @param userAddress address of the user whose profile to retrieve.
     * @return profile a struct containing the user's name, contact information, and bio.
     */
    function getUserProfile(address userAddress) public view returns (UserProfile memory profile) {
        require(hasRole(USER_ROLE, userAddress), "UserManagement: user must be registered to have a profile.");
        return userProfiles[userAddress];
    }

    /**
     * @dev Grants USER_ROLE to a user.
     * Overridden to emit a custom event.
     * @param userAddress address of the user to grant USER_ROLE.
     */
    function grantRole(bytes32 role, address userAddress) public override onlyRole(getRoleAdmin(role)) {
        super.grantRole(USER_ROLE, userAddress);
        emit UserRoleGranted(userAddress, msg.sender);
    }
}
