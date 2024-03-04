// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.5.16;

import "interfaces/IThrusterFactory.sol";

import "contracts/ThrusterGas.sol";
import "contracts/ThrusterPair.sol";

contract ThrusterFactory is IThrusterFactory, ThrusterGas {
    uint256 public yieldCut;
    address public yieldTo;
    address public yieldToSetter;
    address public pointsAdmin;

    mapping(address => mapping(address => address)) public getPair;
    mapping(address => bool) public pairExists;
    address[] public allPairs;

    address private constant BLAST_POINTS = 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    event SetYieldTo(address indexed yieldTo);
    event SetYieldToSetter(address indexed newYieldToSetter);
    event SetYieldCut(uint256 yieldCut);
    event Swap(
        address indexed pair,
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(address indexed pair, uint112 reserve0, uint112 reserve1);
    event Transfer(address indexed pair, address indexed from, address indexed to, uint256 value);

    constructor(address _yieldToSetter, address _pointsAdmin) public ThrusterGas(_yieldToSetter) {
        yieldToSetter = _yieldToSetter;
        pointsAdmin = _pointsAdmin;
        IBlastPoints(BLAST_POINTS).configurePointsOperator(_pointsAdmin);
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "ThrusterFactory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "ThrusterFactory: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "ThrusterFactory: PAIR_EXISTS"); // single check is sufficient
        bytes memory bytecode = type(ThrusterPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IThrusterPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        pairExists[pair] = true;
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setYieldTo(address _yieldTo) external {
        require(msg.sender == yieldToSetter, "ThrusterFactory: FORBIDDEN");
        yieldTo = _yieldTo;
        emit SetYieldTo(_yieldTo);
    }

    function setYieldToSetter(address _newYieldToSetter) external {
        require(msg.sender == yieldToSetter, "ThrusterFactory: FORBIDDEN");
        require(_newYieldToSetter != address(0), "ThrusterFactory: ZERO_ADDRESS");
        yieldToSetter = _newYieldToSetter;
        emit SetYieldToSetter(_newYieldToSetter);
    }

    function setYieldCut(uint256 _yieldCut) external {
        require(msg.sender == yieldToSetter, "ThrusterFactory: FORBIDDEN");
        require(_yieldCut < 6 && _yieldCut > 0, "ThrusterFactory: INVALID_YIELD_CUT"); // Yield cut is 16-50% of the LP yield
        yieldCut = _yieldCut;
        emit SetYieldCut(_yieldCut);
    }

    function emitSync(uint112 reserve0, uint112 reserve1) external {
        require(pairExists[msg.sender], "ThrusterFactory: PAIR_DOES_NOT_EXIST");
        emit Sync(msg.sender, reserve0, reserve1);
    }

    function emitTransfer(address from, address to, uint256 liquidity) external {
        require(pairExists[msg.sender], "ThrusterFactory: PAIR_DOES_NOT_EXIST");
        emit Transfer(msg.sender, from, to, liquidity);
    }

    function emitSwap(
        address sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external {
        require(pairExists[msg.sender], "ThrusterFactory: PAIR_DOES_NOT_EXIST");
        emit Swap(msg.sender, sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }
}
