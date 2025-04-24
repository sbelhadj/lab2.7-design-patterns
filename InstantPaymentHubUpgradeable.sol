// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract InstantPaymentHub is Ownable, Pausable, ReentrancyGuard, UUPSUpgradeable, Initializable {

    using Counters for Counters.Counter;
    Counters.Counter private _paymentCount;
    mapping(address => uint256) public balances;

    event PaymentMade(address indexed sender, address indexed receiver, uint256 amount);

    // Modifier to ensure the contract is not paused.
    modifier onlyWhenNotPaused() {
        require(!paused(), "Contract is paused");
        _;
    }

    /**
     * @dev Initializes the contract. The `Ownable` constructor automatically sets the owner.
     * This function is used for upgradeable contracts instead of the constructor.
     */
    function initialize() public initializer {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
    }

    /**
     * @notice Allows users to deposit Ether into the contract.
     * @dev The sender's balance is increased by the amount of Ether sent with the transaction.
     */
    function deposit() public payable whenNotPaused {
        balances[msg.sender] += msg.value;
    }

    /**
     * @notice Allows users to make an instant payment to another address.
     * @param recipient The address to which the payment is made.
     * @param amount The amount to be transferred in Wei.
     * @dev The sender must have sufficient balance to perform the transaction.
     */
    function instantPayment(address recipient, uint256 amount) public whenNotPaused nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit PaymentMade(msg.sender, recipient, amount);
    }

    /**
     * @notice Allows users to withdraw Ether from the contract.
     * @param amount The amount of Ether to withdraw in Wei.
     * @dev The sender must have sufficient balance to withdraw the specified amount.
     */
    function withdraw(uint256 amount) public whenNotPaused nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        // Using call to safely transfer Ether.
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        balances[msg.sender] -= amount;
    }

    /**
     * @notice Pauses the contract to stop deposits, payments, and withdrawals.
     * @dev Only the owner can pause the contract.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract to resume normal operation.
     * @dev Only the owner can unpause the contract.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @notice Creates a new payment hub contract using the Factory Pattern.
     * @dev This function allows the owner to deploy a new InstantPaymentHub contract.
     * @return A new InstantPaymentHub contract instance.
     */
    function createNewPaymentHub() public onlyOwner returns (InstantPaymentHub) {
        InstantPaymentHub newPaymentHub = new InstantPaymentHub();
        return newPaymentHub;
    }

    /**
     * @dev Override _authorizeUpgrade function to ensure only the owner can upgrade the contract.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
