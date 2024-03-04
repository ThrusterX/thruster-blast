// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is AccessControl, ERC20 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint8 private __decimals = 18;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function decimals() public view override returns (uint8) {
        return __decimals;
    }

    function setDecimals(uint8 _decimals) external {
        __decimals = _decimals;
    }

    function mint(address _to, uint256 _value) external {
        _mint(_to, _value);
    }

    function dummyFunction(bool _dummy, uint256 _dummy2) external pure returns (bool) {
        return _dummy2 > 0 ? _dummy : !_dummy;
    }

    function bridgeERC20To(
        address _localToken,
        address _remoteToken,
        address to,
        uint256 _amount,
        uint32 _minGasLimit,
        bytes calldata _extraData
    ) public {}
}
