// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "../libraries/StructData.sol";

// IVaultReader 接口用于提供查询与持仓相关的各种信息，帮助在合约中处理和管理用户的持仓、费用等。
// 该接口用于获取与仓位、市场、融资费用等相关的详细信息。

interface IVaultReader {
  
  // 定义一个结构体 PositionData，用于表示某个持仓的详细信息
  struct PositionData {
    uint256 sizeInUsd;             // 持仓的美元价值
    uint256 sizeInTokens;          // 持仓的代币数量
    uint256 collateralAmount;      // 持仓的保证金金额
    uint256 netValue;              // 持仓的净值（账户中的实际资产值）
    int256 pnl;                    // 持仓的盈亏（Profit and Loss）
    bool isLong;                   // 是否为多头持仓（true 表示多头，false 表示空头）
  }

  // 获取指定位置的持仓信息，返回 PositionData 结构体
  function getPositionInfo(
    bytes32 key,                   // 持仓的唯一标识符
    MarketPrices memory prices     // 市场价格信息
  ) external view returns (PositionData memory);

  // 获取指定持仓的负融资费用金额
  function getNegativeFundingFeeAmount(
    bytes32 key,                   // 持仓的唯一标识符
    MarketPrices memory prices     // 市场价格信息
  ) external view returns (uint256);

  // 判断指定持仓的保证金是否不足
  function willPositionCollateralBeInsufficient(
    MarketPrices memory prices,     // 市场价格信息
    bytes32 positionKey,            // 持仓的唯一标识符
    address market,                 // 市场地址
    bool isLong,                    // 是否为多头持仓
    uint256 sizeDeltaUsd,           // 持仓变化的美元价值
    uint256 collateralDeltaAmount   // 变化的保证金金额
  ) external view returns (bool);

  // 计算指定持仓的价格冲击对保证金的影响
  function getPriceImpactInCollateral(
    bytes32 positionKey,            // 持仓的唯一标识符
    uint256 sizeDeltaInUsd,         // 持仓变化的美元价值
    uint256 prevSizeInTokens,      // 持仓前的代币数量
    MarketPrices memory prices     // 市场价格信息
  ) external view returns (int256);

  // 获取指定持仓的盈亏情况
  function getPnl(
    bytes32 key,                   // 持仓的唯一标识符
    MarketPrices memory prices,    // 市场价格信息
    uint256 sizeDeltaUsd           // 持仓变化的美元价值
  ) external view returns (int256);

  // 获取指定持仓的美元价值
  // key：持仓的唯一标识符
  function getPositionSizeInUsd(bytes32 key) external view returns (uint256 sizeInUsd);

  // 获取指定持仓的代币数量
  // key：持仓的唯一标识符
  function getPositionSizeInTokens(bytes32 key) external view returns (uint256 sizeInTokens);

  // 获取指定市场的相关属性
  // market：市场地址
  function getMarket(address market) external view returns (MarketProps memory);

  // 获取持仓变化的费用（以美元为单位）
  function getPositionFeeUsd(
    address market,                 // 市场地址
    uint256 sizeDeltaUsd,           // 持仓变化的美元价值
    bool forPositiveImpact          // 是否考虑正向影响
  ) external view returns (uint256 positionFeeAmount);
}
