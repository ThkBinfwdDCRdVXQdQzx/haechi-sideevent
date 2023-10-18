pragma solidity >=0.7.0 <0.9.0;

import {Context} from "./context.sol";
import {IERC20} from "./IERC20.sol";
import {Ownable} from "./ownable.sol";

contract Hello is Context, Ownable {
    struct Game {
        bool initialized;
        mapping(address => uint) bettings;
        uint totalBettings;
        address[] users;
        address winner;
    }

    mapping(uint => Game) public games;
    uint[] public gameIds;
    address public tokenContract;
    uint public feePercent = 10;

    constructor(address initialOwner) Ownable(initialOwner) {
        
    }


    function setErc20(address newContract) public onlyOwner returns (bool) {
        tokenContract = newContract;
        return true;
    }

    function startGame(uint newId) public returns (bool) {
        require(games[newId].initialized == false, "Game exists");
        games[newId].initialized = true;
        gameIds.push(newId);
        return true;
    }

    function listGameIds() public view returns (uint[] memory) {
        return gameIds;
    }

    function bet(uint gameId, uint amount) public returns (bool) {
        require(games[gameId].initialized, "Game Initialized");
        require(games[gameId].winner == address(0), "Finished");
        require(IERC20(tokenContract).balanceOf(msg.sender) >= amount, "Enough balance");

        require(IERC20(tokenContract).transferFrom(msg.sender, address(this), amount), "Transfer should success");
        if (games[gameId].bettings[msg.sender] == 0) {
            games[gameId].users.push(msg.sender);
        }
        games[gameId].bettings[msg.sender] += amount;
        games[gameId].totalBettings += amount;
        return true;
    }

    function finish(uint gameId, address winner) public onlyOwner returns (uint) {
        require(games[gameId].initialized, "Game Initialized");
        require(games[gameId].winner == address(0), "Finished");
        games[gameId].winner = winner;
        require(IERC20(tokenContract).transfer(winner, games[gameId].totalBettings), "Reward should success");
        return games[gameId].totalBettings;
    }

    function gameUsers(uint gameId) public view returns (address[] memory) {
        require(games[gameId].initialized, "Game Initialized");
        return games[gameId].users;
    }

    function getBetting(uint gameId, address better) public view returns (uint) {
        require(games[gameId].initialized, "Game Initialized");
        return games[gameId].bettings[better];
    }

    function myBetting(uint gameId) public view returns (uint) {
        require(games[gameId].initialized, "Game Initialized");
        return games[gameId].bettings[msg.sender];
    }
}