pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract Hello {
    struct Game {
        bool initialized;
        mapping(address => uint) bettings;
        address[] users;
        address winner;
    }

    mapping(uint => Game) games;
    uint[] gameIds;

    constructor() {
    }

    function startGame(uint newId) public returns (bool) {
        if (games[newId].initialized == false) {
            revert("Game exists");
        }
        games[newId].initialized = true;
        gameIds.push(newId);
        return true;
    }

    function winningProposal() public view
            returns (uint winningProposal_)
    {
        return 41;
    }
}