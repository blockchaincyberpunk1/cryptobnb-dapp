// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title PropertyListingContract
 * @dev Manages the property listings on the platform, allowing for addition, 
 * updating, and removal of property listings by their respective owners.
 */
contract PropertyListingContract is Ownable, AccessControl {
    bytes32 public constant HOST_ROLE = keccak256("HOST_ROLE");

    struct Property {
        uint256 id;
        address owner;
        string title;
        string description;
        string location;
        bool isActive;
    }

    Property[] public properties;

    mapping(uint256 => address) public propertyToOwner;
    mapping(address => uint256[]) public ownerToProperties;

    event PropertyAdded(uint256 indexed propertyId, address indexed owner, string title);
    event PropertyUpdated(uint256 indexed propertyId, string newTitle, string newDescription, string newLocation);
    event PropertyRemoved(uint256 indexed propertyId);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Adds a new property listing to the platform.
     * @dev Only users with the HOST_ROLE can add properties.
     * @param _title The title of the property listing.
     * @param _description A description of the property.
     * @param _location The location of the property.
     */
    function addProperty(string memory _title, string memory _description, string memory _location) public onlyRole(HOST_ROLE) {
        uint256 propertyId = properties.length;
        properties.push(Property(propertyId, msg.sender, _title, _description, _location, true));
        propertyToOwner[propertyId] = msg.sender;
        ownerToProperties[msg.sender].push(propertyId);

        emit PropertyAdded(propertyId, msg.sender, _title);
    }

    /**
     * @notice Updates a property listing by its owner.
     * @dev Only the property owner can update their property listing.
     * @param _propertyId The ID of the property to update.
     * @param _newTitle The new title of the property.
     * @param _newDescription The new description of the property.
     * @param _newLocation The new location of the property.
     */
    function updateProperty(uint256 _propertyId, string memory _newTitle, string memory _newDescription, string memory _newLocation) public {
        require(propertyToOwner[_propertyId] == msg.sender, "Only the property owner can update the listing");
        
        Property storage property = properties[_propertyId];
        property.title = _newTitle;
        property.description = _newDescription;
        property.location = _newLocation;

        emit PropertyUpdated(_propertyId, _newTitle, _newDescription, _newLocation);
    }

    /**
     * @notice Removes a property listing from the platform.
     * @dev Only the property owner can remove their listing. Marks the property as inactive.
     * @param _propertyId The ID of the property to remove.
     */
    function removeProperty(uint256 _propertyId) public {
        require(propertyToOwner[_propertyId] == msg.sender, "Only the property owner can remove the listing");
        
        Property storage property = properties[_propertyId];
        property.isActive = false;

        emit PropertyRemoved(_propertyId);
    }

    /**
     * @notice Retrieves the details of a property listing.
     * @param _propertyId The ID of the property to retrieve.
     * @return property A struct containing the property's details.
     */
    function getProperty(uint256 _propertyId) public view returns (Property memory property) {
        return properties[_propertyId];
    }
}
