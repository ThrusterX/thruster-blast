// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "interfaces/IThrusterPoolDeployer.sol";

import "contracts/ThrusterPool.sol";

contract ThrusterPoolDeployer is IThrusterPoolDeployer {
    struct Parameters {
        address factory;
        address token0;
        address token1;
        uint24 fee;
        int24 tickSpacing;
    }

    /// @inheritdoc IThrusterPoolDeployer
    Parameters public override parameters;

    address public immutable override factory;
    address private constant BLAST = 0x4300000000000000000000000000000000000002;

    modifier onlyFactory() {
        require(msg.sender == factory);
        _;
    }

    constructor(address _factory) {
        IBlast(BLAST).configureClaimableGas();
        factory = _factory;
    }

    /// @inheritdoc IThrusterPoolDeployer
    function deploy(address _factory, address token0, address token1, uint24 fee, int24 tickSpacing)
        external
        override
        onlyFactory
        returns (address pool)
    {
        parameters = Parameters({factory: _factory, token0: token0, token1: token1, fee: fee, tickSpacing: tickSpacing});
        pool = address(new ThrusterPool{salt: keccak256(abi.encode(token0, token1, fee))}());
        delete parameters;
    }

    function claimGas(address _recipient) external override onlyFactory returns (uint256 amount) {
        amount = IBlast(BLAST).claimMaxGas(address(this), _recipient);
    }
}
