// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.5.16;

import "interfaces/IBlast.sol";
import "interfaces/IThrusterGas.sol";

contract ThrusterGas is IThrusterGas {
    IBlast public constant BLAST = IBlast(0x4300000000000000000000000000000000000002);
    address public manager;

    event ClaimGas(address indexed recipient, uint256 amount);

    modifier onlyManager() {
        require(msg.sender == manager, "FORBIDDEN");
        _;
    }

    constructor(address _manager) public {
        BLAST.configureClaimableGas();
        manager = _manager;
    }

    function claimGas(address _recipient, uint256 _minClaimRateBips) external onlyManager returns (uint256 amount) {
        if (_minClaimRateBips == 0) {
            amount = BLAST.claimMaxGas(address(this), _recipient);
        } else {
            amount = BLAST.claimGasAtMinClaimRate(address(this), _recipient, _minClaimRateBips);
        }
        emit ClaimGas(_recipient, amount);
    }

    function setManager(address _manager) external onlyManager {
        manager = _manager;
    }
}
