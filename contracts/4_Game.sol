pragma solidity >=0.7.0 <0.9.0;

// import {Context} from "./context.sol";
// import {IERC20} from "./IERC20.sol";
// import {Ownable} from "./ownable.sol";
import {IERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/interfaces/IERC20.sol";
import {Context} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/utils/Context.sol";
import {Ownable} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol";

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";
import {AccessControl } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/AccessControl.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.2/contracts/access/AccessControl.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol

contract GameContract is Context, AccessControl {
    struct Game {
        bool initialized;
        mapping(address => uint) bettings;
        uint totalBettings;
        address[] users;
        address winner;
    }

    event GameStart(uint gameId);
    event Bat(address batter, uint amount);
    event GameFinish(address winner, uint reward, uint fee);
    event Withdraw(address withdrawer, uint amount);

    mapping(uint => Game) public games;
    uint[] public gameIds;
    address public tokenContract;
    uint public feePercent = 20;
    uint public feeTotal = 0;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    function setErc20(address newContract) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        tokenContract = newContract;
        return true;
    }

    function startGame(uint newId) public returns (bool) {
        require(games[newId].initialized == false, "Game exists");
        games[newId].initialized = true;
        gameIds.push(newId);
        emit GameStart(newId);
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
        emit Bat(msg.sender, amount);
        return true;
    }

    function finish(uint gameId, address winner) public onlyRole(DEFAULT_ADMIN_ROLE) returns (uint) {
        require(games[gameId].initialized, "Game Initialized");
        require(games[gameId].winner == address(0), "Finished");
        games[gameId].winner = winner;
        uint reward = ((100 - feePercent) * games[gameId].totalBettings) / 100;
        uint fee = games[gameId].totalBettings - reward;
        require(fee + reward == games[gameId].totalBettings, "reward + fee = total");
        require(reward >= 0 && fee >= 0 && games[gameId].totalBettings >= 0, "all positive");

        require(IERC20(tokenContract).transfer(winner, reward), "Reward should success");
        feeTotal += fee;
        emit GameFinish(winner, reward, fee);
        return reward;
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

    function withdrawAll() public onlyRole(DEFAULT_ADMIN_ROLE) returns (uint amount) {
        require(feeTotal > 0, "No fee");
        require(IERC20(tokenContract).transfer(msg.sender, feeTotal), "transfer fee");
        amount = feeTotal;
        feeTotal = 0;
        emit Withdraw(msg.sender, amount);
    }
}