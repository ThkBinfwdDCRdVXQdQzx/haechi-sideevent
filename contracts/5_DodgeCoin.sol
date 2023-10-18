pragma solidity >=0.7.0 <0.9.0;

import {ERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/AccessControl.sol";

contract UNITCoin is ERC20, AccessControl {
    string constant _name = "Intergalactic Currency";
    string constant _symbol = "UNIT";
    address public gameContract;

    constructor() ERC20(_name, _symbol) {
        _mint(msg.sender, 1000 * 10 **18);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }


    function mint(uint amount) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        _mint(msg.sender, amount);
        return true;
    }

    function setGameContract(address _gameContract) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        gameContract = _gameContract;
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        if (spender != gameContract) {
            _spendAllowance(from, spender, amount);
        }
        _transfer(from, to, amount);
        return true;
    }
}