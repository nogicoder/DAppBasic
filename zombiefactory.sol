pragma solidity ^0.4.25;

// Main contract for Zombie creation
contract ZombieFactory {

    // New event to alert the user when a blockchain is updated
    event NewZombie(uint zombieId, string name, uint dna);

    // Set the total digits of the Zombie's DNA
    uint dnaDigits = 16;

    // Create a modulus to convert numbers into base-16
    uint dnaModulus = 10 ** dnaDigits;

    // Define a new Object with 2 attributes
    struct Zombie {
        string name;
        uint dna;
    }

    // Create an array of the newly created Object
    Zombie[] public zombies;

    // Create a key-value binding to assign each Zombie to one owner (only those authenticated can be assigned a zombie)
    mapping (uint => address) public zombieToOwner;

    // Create a key-value binding to return the number of zombie an user owns
    mapping (address => uint) ownerZombieCount;

    // Declare new function to create a Zombie instance with 2 params
    function _createZombie(string _name, uint _dna) internal {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}
