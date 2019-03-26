pragma solidity ^0.5.7;

contract Steamchain {
    uint256 public gameCount = 0;
    mapping(uint => Game) public games;
    mapping(string => Game) public gamesByAppID;

    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    struct Game {
        uint id;
        string appID;
        string name;
    }

    constructor() public {
        owner = msg.sender;
    }

    function addGame(
        string memory _appID,
        string memory _name
    )
        public
        onlyOwner
    {
        incrementCount();
        Game memory game = Game(gameCount, _appID, _name);
        games[gameCount] = game;
        gamesByAppID[_appID] = game;
    }
    
    function incrementCount() internal {
        gameCount += 1;
    }
}
