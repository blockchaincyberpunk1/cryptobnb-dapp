// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PaymentContract
 * @dev Manages payments for property bookings, including holding funds in escrow and handling refunds and releases.
 */
contract PaymentContract is Ownable, ReentrancyGuard {
    // Event declarations
    event PaymentMade(address indexed payer, uint256 indexed bookingId, uint256 amount);
    event PaymentRefunded(address indexed payee, uint256 indexed bookingId, uint256 amount);
    event PaymentReleased(address indexed host, uint256 indexed bookingId, uint256 amount);

    // Struct to hold booking payment information
    struct PaymentInfo {
        uint256 amount;
        bool paid;
        bool refunded;
    }

    // Mapping to track payments for bookings
    mapping(uint256 => PaymentInfo) public bookingPayments;

    /**
     * @notice Handles the payment process for booking a property.
     * @dev Stores funds in the contract until the booking is either completed or cancelled.
     * @param bookingId The ID of the booking for which the payment is made.
     */
    function makePayment(uint256 bookingId) external payable nonReentrant {
        require(msg.value > 0, "Payment amount must be greater than 0");
        require(!bookingPayments[bookingId].paid, "Payment for this booking already made");

        bookingPayments[bookingId] = PaymentInfo(msg.value, true, false);

        emit PaymentMade(msg.sender, bookingId, msg.value);
    }

    /**
     * @notice Refunds payment to the guest in case of cancellation.
     * @dev Can only be called by the contract owner (platform/admin) under specific conditions.
     * @param bookingId The ID of the booking for which the refund is issued.
     * @param payee The address to which the refund will be made.
     */
    function refundPayment(uint256 bookingId, address payable payee) external onlyOwner nonReentrant {
        PaymentInfo storage payment = bookingPayments[bookingId];
        require(payment.paid, "No payment made for this booking");
        require(!payment.refunded, "Payment already refunded");

        payment.refunded = true;
        payee.transfer(payment.amount);

        emit PaymentRefunded(payee, bookingId, payment.amount);
    }

    /**
     * @notice Releases payment to the host upon successful completion of the stay.
     * @dev Can only be called by the contract owner (platform/admin) after confirming the stay was successful.
     * @param bookingId The ID of the booking for which the payment is released.
     * @param host The address of the property host to receive the payment.
     */
    function releasePayment(uint256 bookingId, address payable host) external onlyOwner nonReentrant {
        PaymentInfo storage payment = bookingPayments[bookingId];
        require(payment.paid, "No payment made for this booking");
        require(!payment.refunded, "Payment already refunded");

        host.transfer(payment.amount);

        emit PaymentReleased(host, bookingId, payment.amount);
    }
}
