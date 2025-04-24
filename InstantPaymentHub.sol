
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

contract InstantPaymentHub is Ownable, Pausable, ReentrancyGuard {

    using Counters for Counters.Counter;

    Counters.Counter private _paymentCount;

    mapping(address => uint256) public balances;

    event PaymentMade(address indexed sender, address indexed receiver, uint256 amount);

    modifier onlyWhenNotPaused() {

        require(!paused(), "Contract is paused");

        _;

    }

    // Déployer un nouveau contrat de paiement instantané

    constructor() {

        // Propriétaire défini à l'adresse qui déploie le contrat

    }

    // Fonction pour déposer de l'ether dans le contrat

    function deposit() public payable whenNotPaused {

        balances[msg.sender] += msg.value;

    }

    // Fonction pour effectuer un paiement instantané

    function instantPayment(address recipient, uint256 amount) public whenNotPaused nonReentrant {

        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        balances[recipient] += amount;

        emit PaymentMade(msg.sender, recipient, amount);

    }

    // Fonction pour retirer des fonds du contrat

    function withdraw(uint256 amount) public whenNotPaused nonReentrant {

        require(balances[msg.sender] >= amount, "Insufficient balance");

        payable(msg.sender).transfer(amount);

        balances[msg.sender] -= amount;

    }

    // Fonction pour mettre en pause le contrat en cas de besoin

    function pause() public onlyOwner {

        _pause();

    }

    // Fonction pour reprendre les opérations du contrat après une pause

    function unpause() public onlyOwner {

        _unpause();

    }

    // Fonction pour créer un nouveau contrat (Factory Pattern)

    function createNewPaymentHub() public onlyOwner returns (InstantPaymentHub) {

        InstantPaymentHub newPaymentHub = new InstantPaymentHub();

        return newPaymentHub;

    }

}
