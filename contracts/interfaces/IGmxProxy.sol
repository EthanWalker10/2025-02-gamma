// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "../interfaces/gmx/IGmxReader.sol";

/**
 * 用于与 GMX 协议进行交互的智能合约接口。提供用于创建、管理和结算交易订单，以及管理相关信息（例如杠杆仓位、费用、价格等）的函数。允许代理合约与 GMX 进行交互，执行各种交易、订单处理和结算操作。
 */

interface IGmxProxy {

// 描述订单的基本数据，包括市场、杠杆交易的代币、交换路径、大小变化、初始抵押品等。
  struct OrderData {
    address market; // 交易的市场地址（例如ETH/USD交易对）
    address indexToken; //  用于该市场的标的资产地址。
    address initialCollateralToken; // 初始的抵押代币地址。
    address[] swapPath; // 交换路径
    bool isLong; // 订单是多头（true）还是空头（false）
    uint256 sizeDeltaUsd; // 订单的大小变化（以USD为单位）
    uint256 initialCollateralDeltaAmount; // 初始抵押品的变化量
    uint256 amountIn; // 输入的代币数量
    uint256 callbackGasLimit; // 回调函数的gas限制
    uint256 acceptablePrice; // 可接受的价格
    uint256 minOutputAmount; // 最小输出数量
  }

// 表示订单执行后的结果
  struct OrderResultData {
    Order.OrderType orderType; // 订单类型，可能是开盘、平仓等
    bool isLong; // 订单是多头（true）还是空头（false）
    uint256 sizeDeltaUsd; // 订单的大小变化（以USD为单位）
    address outputToken; // 输出代币地址
    uint256 outputAmount; // 输出代币数量
    bool isSettle; // 是否结算
  }

  // 该函数用于获取执行交易时的gas限制。
  function getExecutionGasLimit(Order.OrderType orderType, uint256 callbackGasLimit) external view returns (uint256 executionGasLimit);

  // 用于设置杠杆交易的vault。每个市场可能有一个单独的perp vault，通过该函数将特定的perp vault与市场绑定
  function setPerpVault(address perpVault, address market) external;

  // 创建一个新的订单。这个函数会返回一个订单的唯一标识符（bytes32），用于追踪订单的状态。
  function createOrder(Order.OrderType orderType, OrderData memory orderData) external returns (bytes32);

  // 用于结算一个订单，可能是一个平仓操作，返回一个订单的唯一标识符。
  function settle(OrderData memory orderData) external returns (bytes32);

  // 取消当前的订单。
  function cancelOrder() external;

  // 领取交易的返还的抵押品。
  function claimCollateralRebates(address[] memory, address[] memory, uint256[] memory, address) external;

  // 退还执行费用，通常由合约的调用者（如Keeper）承担。
  function refundExecutionFee(address caller, uint256 amount) external;

  function withdrawEth() external returns (uint256);

  function lowerThanMinEth() external view returns (bool);

// 返回一个队列状态（bytes32 和 bool），该状态可以用于检查当前操作的进度或状态。
  function queue()
        external
        view
        returns (bytes32, bool); //NOTE: added by fuzzer
}
