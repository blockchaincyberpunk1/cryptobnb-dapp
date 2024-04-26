# CryptoBNB Smart Contracts

## Summary
These smart contracts form the backbone of the CryptoBNB decentralized application (dApp). They handle various aspects of property management, bookings, payments, dispute resolution, user management, reviews, and tokenization within the platform. Below are brief descriptions of each contract:

### BookingContract.sol
Manages property bookings and reservations, ensuring properties are not double-booked. It allows guests to create, cancel, and extend bookings.

### DisputeResolutionContract.sol
Handles and resolves disputes between hosts and guests over bookings or transactions. Disputes can be raised by users and resolved by designated arbitrators.

### PaymentContract.sol
Manages payments for property bookings, including holding funds in escrow, issuing refunds, and releasing payments to hosts upon successful stays.

### PropertyListingContract.sol
Manages property listings on the platform, allowing for addition, updating, and removal of property listings by their respective owners.

### ReviewContract.sol
Enables users to leave reviews and ratings for properties or other users, fostering trust and accountability within the platform.

### TokenContract.sol
Implements tokenization for rentals, rewards, or property investments within the platform. It allows minting tokens, transferring tokens, and tokenizing properties.

### UserManagementContract.sol
Manages user registrations, profile updates, and access to user profiles. It allows users to register, update their profiles, and grants roles for access management.

## Note
The development of these smart contracts is still in progress. Further testing, optimization, and integration with the CryptoBNB dApp are ongoing.
