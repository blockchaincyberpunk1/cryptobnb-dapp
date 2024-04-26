// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title BookingContract
 * @dev Manages the bookings and reservations for properties on the platform, ensuring properties are not double-booked.
 */
contract BookingContract is AccessControl {
    struct Booking {
        uint256 propertyId;
        address guest;
        uint64 startDate;
        uint64 endDate;
        bool isActive;
    }

    uint256 public nextBookingId;

    mapping(uint256 => Booking) public bookings;
    mapping(uint256 => uint256[]) public propertyBookings; // Maps property ID to booking IDs
    mapping(address => uint256[]) public guestBookings; // Maps guest address to booking IDs

    bytes32 public constant HOST_ROLE = keccak256("HOST_ROLE");
    bytes32 public constant GUEST_ROLE = keccak256("GUEST_ROLE");

    event BookingCreated(uint256 indexed bookingId, uint256 propertyId, address indexed guest, uint64 startDate, uint64 endDate);
    event BookingCancelled(uint256 indexed bookingId);
    event BookingExtended(uint256 indexed bookingId, uint64 newEndDate);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Creates a new booking for a property.
     * @param _propertyId The ID of the property to book.
     * @param _guest The address of the guest making the booking.
     * @param _startDate The start date of the booking period (timestamp).
     * @param _endDate The end date of the booking period (timestamp).
     * @dev Checks for availability before confirming the booking.
     */
    function createBooking(uint256 _propertyId, address _guest, uint64 _startDate, uint64 _endDate) public onlyRole(GUEST_ROLE) {
        require(_endDate > _startDate, "Invalid booking period");
        require(checkAvailability(_propertyId, _startDate, _endDate), "Property not available");

        uint256 bookingId = nextBookingId++;
        bookings[bookingId] = Booking(_propertyId, _guest, _startDate, _endDate, true);
        propertyBookings[_propertyId].push(bookingId);
        guestBookings[_guest].push(bookingId);

        emit BookingCreated(bookingId, _propertyId, _guest, _startDate, _endDate);
    }

    /**
     * @notice Cancels an existing booking.
     * @param _bookingId The ID of the booking to cancel.
     */
    function cancelBooking(uint256 _bookingId) public {
        Booking storage booking = bookings[_bookingId];
        require(msg.sender == booking.guest, "Only the guest can cancel the booking");
        booking.isActive = false;

        emit BookingCancelled(_bookingId);
    }

    /**
     * @notice Extends an existing booking.
     * @param _bookingId The ID of the booking to extend.
     * @param _newEndDate The new end date of the booking period (timestamp).
     */
    function extendBooking(uint256 _bookingId, uint64 _newEndDate) public {
        Booking storage booking = bookings[_bookingId];
        require(msg.sender == booking.guest, "Only the guest can extend the booking");
        require(_newEndDate > booking.endDate, "New end date must be later than current end date");
        require(checkAvailability(booking.propertyId, booking.endDate, _newEndDate), "Extension period not available");

        booking.endDate = _newEndDate;

        emit BookingExtended(_bookingId, _newEndDate);
    }

    /**
     * @notice Checks if a property is available for booking within the specified period.
     * @param _propertyId The ID of the property to check.
     * @param _startDate The start date of the desired booking period (timestamp).
     * @param _endDate The end date of the desired booking period (timestamp).
     * @return available Returns true if the property is available, false otherwise.
     */
    function checkAvailability(uint256 _propertyId, uint64 _startDate, uint64 _endDate) public view returns (bool available) {
        for (uint256 i = 0; i < propertyBookings[_propertyId].length; i++) {
            Booking storage booking = bookings[propertyBookings[_propertyId][i]];
            if (booking.isActive && ((_startDate < booking.endDate && _startDate >= booking.startDate) || (_endDate > booking.startDate && _endDate <= booking.endDate))) {
                return false;
            }
        }
        return true;
    }
}
