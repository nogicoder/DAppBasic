// Specify Solidity version
pragma solidity ^0.4.25;

// Import the contract from other file
import "./zombiefactory.sol";

// Create new contract for the Interface with other external contracts and functions inside them
contract KittyInterface {

  // Get the return values of the Kitty with its id being passed in the function
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes // The information we want (at index 10)
  );
}

// Create a new contract to modify the Zombie's features
// This is an inheritance of the main contract to reuse functions without flooding the script file 
contract ZombieFeeding is ZombieFactory {

  // The address of an user
  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  
  // Only declare it without binding to any value (not making it a state variable)
  KittyInterface kittyContract;

  // Make a function to create an Interface based on a dynamic address
  function setKittyContractAddress(address _address) external {
    kittyContract = KittyInterface(_address);
  }

  // Declare a function to reset the readyTime
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

  // Check if the Zombie's readyTime has passed yet 
  function _isReady(Zombie storage _zombie) internal view returns (bool) {
      return (_zombie.readyTime <= now);
  }

  // Declare a function to pass the Kitty's info in to modify the Zombie's feature
  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) public {
    
    // Only if the request maker is the Zombie's owner
    require(msg.sender == zombieToOwner[_zombieId]);

    // Get the Zombie at a certain id and store it in the storage, not in the chain
    Zombie storage myZombie = zombies[_zombieId];

    // It's required for the Zombie to passed the readyTime before taking in the newDna again
    require(_isReady(myZombie));

    // Set the new zombie's DNA
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    

    // If the target's species is a kitty, plus 99 to its dna's final 2 digits
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }

    // Then create the new Zombie as usual 
    _createZombie("NoName", newDna);

    // Reset the readyTime after the Zombie feed on the new kittyDna
    _triggerCooldown(myZombie);
  }

  // Pass the kitty to the ZombieFeeding machine
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    
    // Get the value of the Kitty's DNA
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);

    // Parse that info to the function including the keyword "kitty"
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}
