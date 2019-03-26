solidity ^0.5.7;

contract Steamchain {
    uint256 public gameCount = 0;
    mapping(uint => Game) public games;
    mapping(string => string) public gamesByAppID;

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
        games[gameCount] = Game(gameCount, _appID, _name);
        gamesByAppID[_appID] = _name;
    }
    
    function incrementCount() internal {
        gameCount += 1;
    }
}
