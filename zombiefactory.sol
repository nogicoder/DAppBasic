// Specify solidity version
pragma solidity ^0.4.25;

// Main contract for Zombie creation
contract ZombieFactory {

    // New event to alert the user when a blockchain is updated
    event NewZombie(uint zombieId, string name, uint dna);

    // Set the total digits of the Zombie's DNA
    uint dnaDigits = 16;

    // Create a modulus to convert numbers into base-16
    uint dnaModulus = 10 ** dnaDigits;

    // Set standard cooldown time
    uint cooldownTime = 1 days;

    // Define a new Object with 4 attributes
    struct Zombie {
        string name;
        uint dna;
        // Zombie that wins more battle level up faster with access to more abilities
        uint32 level;

        // Time before a zombie can feed/ attack again
        uint32 readyTime;
    }

    // Create an array of the newly created Object
    Zombie[] public zombies;

    // Create a key-value binding to assign each Zombie to one owner (only those authenticated can be assigned a zombie)
    mapping (uint => address) public zombieToOwner;

    // Create a key-value binding to return the number of zombie an user owns
    mapping (address => uint) ownerZombieCount;

    // Declare new function to create a Zombie instance with 2 params.
    // Internal function for other inherit contract to re-use this function (not enabled in Private)
    function _createZombie(string _name, uint _dna) internal {

        // Push the newly created Zombie instance to the array, and declare an id after (= current array length - 1)
        // The readyTime is passed in as the time a Zombie can feed on its victim again in the future
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime))) - 1;

        // Assign the id to the key-value binding
        zombieToOwner[id] = msg.sender;

        // Assign the count to the key-value binding
        ownerZombieCount[msg.sender]++;

        // Trigger the event
        emit NewZombie(id, _name, _dna);
    }

    // Declare a function to generate random DNA based on name of the Zombie
    // View since this function only take the data and read without modifying the data
    function _generateRandomDna(string _str) private view returns (uint) {

        // Convert the string to uint after encode the string to bytes
        uint rand = uint(keccak256(abi.encodePacked(_str)));

        // Convert to base-16 to qualify to be a Zombie's DNA
        return rand % dnaModulus;
    }

    // Declare a function to generate random DNA and then create a new Zombie based on that DNA
    function createRandomZombie(string _name) public {

        // Only user who never owned a Zombie before can create one 
        require(ownerZombieCount[msg.sender] == 0);

        // Generate a random zombieDna
        uint randDna = _generateRandomDna(_name);

        // Create a random Zombie with the random Dna
        _createZombie(_name, randDna);
    }

}
