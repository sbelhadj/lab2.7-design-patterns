### **Lab 7 : Implémentation des Design Patterns solidity - Instant Payment Hub**

#### **Description du Lab**

Dans ce lab, vous apprendrez à utiliser des **design patterns** populaires dans le développement de smart contracts solidity. Ces patterns sont des solutions éprouvées qui permettent de résoudre des problèmes communs dans le développement de contrats intelligents, tels que la gestion des permissions, la sécurité des transactions et l’optimisation de l’extensibilité. Nous allons intégrer plusieurs **design patterns** dans un contrat **Instant Payment Hub** qui permettra de gérer des paiements instantanés.

Les **design patterns** que vous allez implémenter incluent :

*   **Ownable Pattern** : Assurer qu'un contrat a un propriétaire unique.
*   **Pausable Pattern** : Mettre en pause certaines fonctions du contrat en cas de problème.
*   **ReentrancyGuard Pattern** : Sécuriser les fonctions pour éviter les attaques par réentrance.
*   **Factory Pattern** : Créer dynamiquement des instances de contrats.

* * *

### **Prérequis**

Avant de commencer ce lab, assurez-vous d'avoir configuré votre environnement comme suit :

*   **Node.js >= 16.x**
*   **Metamask** ou un autre wallet Ethereum installé dans votre navigateur
*   **Compte Ethereum sur Sepolia Testnet**
*   **GitHub Codespaces** ou un IDE local avec **Hardhat** et **solidity** installés
*   **Infura/Alchemy** pour interagir avec Sepolia Testnet  
     

* * *

### **Objectifs du Lab**

1.  Appliquer des **design patterns** en solidity pour rendre le smart contract plus sûr et flexible.
2.  Implémenter les **patterns** suivants dans un contrat de paiement instantané (InstantPaymentHub) :  
     
    *   **Ownable** pour gérer un propriétaire unique.
    *   **Pausable** pour arrêter certaines fonctions en cas d'urgence.
    *   **ReentrancyGuard** pour éviter les attaques de réentrance.
    *   **Factory Pattern** pour permettre la création de plusieurs instances de contrats.  
         
3.  Déployer le contrat sur le testnet **Sepolia**.  
     

* * *

### **Étapes du Lab**

#### **1\. Préparer l'environnement**  
 

**Installer les dépendances** en utilisant npm :  
  
```bash  
cd lab-design-patterns-solidity

npm install

```

**Vérifier la configuration de Hardhat** pour vous assurer que vous avez un contrat déployé sur Sepolia, comme mentionné dans le **Lab 3**. Si vous avez déjà déployé le contrat, récupérez son adresse.  
  
 

* * *

#### **2\. Créer le contrat solidity avec les Design Patterns**

1.  Créez un fichier contracts/InstantPaymentHub.sol dans le répertoire **contracts/**.
2.  Implémentez un contrat de paiement instantané utilisant plusieurs **design patterns** :  
     

```solidity

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

contract InstantPaymentHub is Ownable, Pausable, ReentrancyGuard {

    using Counters for Counters.Counter;

    Counters.Counter private \_paymentCount;

    mapping(address => uint256) public balances;

    event PaymentMade(address indexed sender, address indexed receiver, uint256 amount);

    modifier onlyWhenNotPaused() {

        require(!paused(), "Contract is paused");

        \_;

    }

    // Déployer un nouveau contrat de paiement instantané

    constructor() {

        // Propriétaire défini à l'adresse qui déploie le contrat

    }

    // Fonction pour déposer de l'ether dans le contrat

    function deposit() public payable whenNotPaused {

        balances\[msg.sender\] += msg.value;

    }

    // Fonction pour effectuer un paiement instantané

    function instantPayment(address recipient, uint256 amount) public whenNotPaused nonReentrant {

        require(balances\[msg.sender\] >= amount, "Insufficient balance");

        balances\[msg.sender\] -= amount;

        balances\[recipient\] += amount;

        emit PaymentMade(msg.sender, recipient, amount);

    }

    // Fonction pour retirer des fonds du contrat

    function withdraw(uint256 amount) public whenNotPaused nonReentrant {

        require(balances\[msg.sender\] >= amount, "Insufficient balance");

        payable(msg.sender).transfer(amount);

        balances\[msg.sender\] -= amount;

    }

    // Fonction pour mettre en pause le contrat en cas de besoin

    function pause() public onlyOwner {

        \_pause();

    }

    // Fonction pour reprendre les opérations du contrat après une pause

    function unpause() public onlyOwner {

        \_unpause();

    }

    // Fonction pour créer un nouveau contrat (Factory Pattern)

    function createNewPaymentHub() public onlyOwner returns (InstantPaymentHub) {

        InstantPaymentHub newPaymentHub = new InstantPaymentHub();

        return newPaymentHub;

    }

}

```

**Explication des Design Patterns appliqués :**

*   **Ownable** : Le contrat est contrôlé par un propriétaire unique. Seul le propriétaire peut exécuter certaines actions, telles que mettre en pause le contrat.
*   **Pausable** : Le contrat permet de mettre en pause certaines fonctions (comme les paiements) en cas d'urgence.
*   **ReentrancyGuard** : Le contrat utilise un modificateur nonReentrant pour protéger contre les attaques de réentrance.
*   **Factory Pattern** : La fonction createNewPaymentHub permet de créer de nouvelles instances du contrat **InstantPaymentHub**, ce qui est utile pour déployer plusieurs hubs de paiement.  
     

* * *

#### **3\. Déployer le contrat sur Sepolia**

1.  **Créer un script de déploiement** dans **scripts/deploy.js** :  
     

```javascript

async function main() {

    const \[deployer\] = await ethers.getSigners();

    console.log("Déployé par : ", deployer.address);

    const Contract = await ethers.getContractFactory("InstantPaymentHub");

    const contract = await Contract.deploy();

    console.log("Contrat déployé à l'adresse : ", contract.address);

}

main()

    .then(() => process.exit(0))

    .catch((error) => {

        console.error(error);

        process.exit(1);

    });

```

**Exécuter le script de déploiement** :  
  
```bash  
npx hardhat run scripts/deploy.js --network sepolia

```

2.   Cela déploiera le contrat sur le testnet Sepolia et vous donnera l'adresse du contrat déployé.  
      
     

* * *

#### **4\. Interagir avec le contrat via Hardhat**

1.  **Créer un script d'interaction** dans **scripts/interact.js** pour tester le contrat **InstantPaymentHub** déployé :  
      
     

```javascript

async function main() {

    const \[deployer\] = await ethers.getSigners();

    const contractAddress = "VOTRE\_ADRESSE\_DE\_CONTRAT"; // Remplacez par l'adresse du contrat déployé

    const contract = await ethers.getContractAt("InstantPaymentHub", contractAddress);

    // Déposer des fonds dans le contrat

    const depositTx = await contract.deposit({ value: ethers.utils.parseEther("1.0") });  // Déposer 1 Ether

    await depositTx.wait();

    console.log("1 Ether déposé dans le contrat");

    // Effectuer un paiement instantané

    const recipient = "ADRESSE\_D\_UN\_UTILISATEUR"; // Remplacez par l'adresse du destinataire

    const paymentTx = await contract.instantPayment(recipient, ethers.utils.parseEther("0.5"));

    await paymentTx.wait();

    console.log("0.5 Ether payé à", recipient);

    // Retirer des fonds du contrat

    const withdrawTx = await contract.withdraw(ethers.utils.parseEther("0.2"));

    await withdrawTx.wait();

    console.log("0.2 Ether retiré du contrat");

}

main()

    .then(() => process.exit(0))

    .catch((error) => {

        console.error(error);

        process.exit(1);

    });

```

**Exécuter le script d'interaction** :  
  
```bash  
npx hardhat run scripts/interact.js --network sepolia

```

2.   Cela interagira avec le contrat déployé en effectuant des transactions de dépôt, de paiement et de retrait.  
     

* * *

#### **5\. Vérification des résultats sur Sepolia via Etherscan**

*   Une fois que vous avez effectué des transactions, vous pouvez vérifier leur état sur Sepolia Etherscan
*   Recherchez l'adresse du contrat déployé et consultez les transactions pour vérifier les paiements effectués.

* * *

### **Ressources supplémentaires**

*   **solidity Documentation** : solidity Documentation
*   **OpenZeppelin Contracts** : OpenZeppelin Contracts
*   **Hardhat Documentation** : Hardhat Documentation
*   **Sepolia Testnet** : Sepolia Etherscan  
     

* * *

### **Fichiers du Projet**

Voici un aperçu des fichiers et dossiers dans le repo pour ce lab :

```lua

lab-design-patterns-solidity/

│

├── contracts/

│   └── InstantPaymentHub.sol

│

├── scripts/

│   ├── deploy.js

│   └── interact.js

│

├── test/

│   └── instant-payment-hub.test.js (optionnel pour les tests unitaires)

│

├── hardhat.config.js

├── package.json

└── README.md

```

* * *

### **Objectifs de l'étudiant après ce lab**

*   Comprendre et appliquer les **design patterns** courants en solidity, notamment **Ownable**, **Pausable**, **ReentrancyGuard**, et **Factory**.
*   Savoir comment déployer un contrat avec ces patterns et interagir avec lui via Hardhat.

Appliquer des bonnes pratiques de sécurité et d'extensibilité dans le développement de smart contracts.
