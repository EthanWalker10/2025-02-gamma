// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IGmxProxy.sol";
import "./IVaultReader.sol";
// import "../libraries/Order.sol";



/**
 * 定义了一个与 GMX 协议交互的永续合约仓库（Perpetual Vault）接口。主要功能是管理杠杆交易和订单执行流程，处理抵押品、交易以及仓位管理等操作。它允许与GMX的合约代理（IGmxProxy）、仓位读写器（IVaultReader）以及市场数据交互。
 */
interface IPerpetualVault {
  // 返回与该仓库相关联的主交易代币的地址。通常是用于交易的标的资产，例如ETH、BTC等。
  function indexToken() external view returns (address); 

  // 返回一个ERC20代币的接口，用于表示该仓库使用的抵押代币。仓库使用这种代币作为抵押品来支持杠杆交易。
  function collateralToken() external view returns (IERC20);

  // 表示该仓库是否处于锁仓状态。
  function isLock() external view returns (bool);

  // 返回一个 bytes32 类型的值，表示当前仓位的唯一标识符（position key）。这个键是仓库管理当前仓位的标识，可以用于查询仓位的状态或执行操作。
  function curPositionKey() external view returns (bytes32);

  // 返回一个 IGmxProxy 接口实例，表示与 GMX 协议的代理交互的接口。通过这个代理，可以创建订单、结算仓位、获取市场数据等。
  function gmxProxy() external view returns (IGmxProxy);

  // 返回市场的地址，通常是一个特定交易对的合约地址，例如 ETH/USDT 或 BTC/USDT 交易对。
  function market() external view returns (address);

  // 返回一个 IVaultReader 接口实例，用于读取仓库的状态和信息。VaultReader 是一个帮助合约读取仓位、资产、费用等信息的工具。
  function vaultReader() external view returns (IVaultReader);


  function run(
    bool isOpen, // 指示该操作是否用于打开新仓位（true）或是关闭已有仓位（false）。
    bool isLong, // 表示该仓位是做多（true）还是做空（false）。
    MarketPrices memory prices, //  包含市场价格信息的结构体，用于计算操作的执行价格。
    bytes[] memory metadata //  一个字节数组，包含与操作相关的附加数据，用于在交易时传递信息。
  ) external;

  // 用于执行下一个预定的操作。例如，如果之前的操作是开仓，下一步可能是增加仓位、平仓等。
  function runNextAction(MarketPrices memory prices, bytes[] memory metadata) external;

  // 取消当前的操作流程。这通常用于中止当前的交易或仓位管理操作。
  function cancelFlow() external;

  // 取消正在进行的交易订单。可以在市场条件不符合预期时使用该方法取消订单。
  function cancelOrder() external;

  // 领取仓库产生的抵押品返还。例如，如果仓位成功平仓并有资金返还，用户可以通过这个函数领取返还的部分
  function claimCollateralRebates(uint256[] memory) external;

  // 订单执行后调用的函数，用于处理订单执行后的状态更新。
  function afterOrderExecution(
    bytes32 requestKey, // 请求的唯一标识符
    bytes32 positionKey, // 仓位的唯一标识符
    IGmxProxy.OrderResultData memory, // 订单执行结果
    MarketPrices memory // 当前市场价格信息，用于更新仓位的状态。
  ) external;

  // 当仓位被强制平仓时，执行此函数。它用于处理仓位被清算后的后续操作，例如释放资金、更新仓位状态等。
  function afterLiquidationExecution() external;

  // 当订单被取消时，执行此函数。它用于处理订单取消后的操作，例如返回资金、更新仓位等
  function afterOrderCancellation(
    bytes32 key, // 订单的唯一标识符
    Order.OrderType, // 订单类型(开仓或平仓)
    IGmxProxy.OrderResultData memory // 订单取消后的结果数据
  ) external;
}
