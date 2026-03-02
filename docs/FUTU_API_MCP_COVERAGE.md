# Futu API -> MCP 封装覆盖清单

更新时间：2026-03-02

## 目标与兼容性

- 目标：将 Futu OpenAPI 能力通过 MCP 工具统一暴露，重点补齐交易与持仓链路。
- 兼容策略：**不修改任何既有 MCP 工具名与参数**，仅新增工具和配置开关。
- 当前 MCP 工具总数：`43`。

官方参考：
- Trade Overview: <https://openapi.futunn.com/futu-api-doc/trade/overview.html>
- Quote Overview: <https://openapi.futunn.com/futu-api-doc/quote/overview.html>

## 新增配置开关

| 配置项 | 默认值 | 作用范围 |
|---|---:|---|
| `FUTU_ENABLE_TRADING` | `0` | 控制主动交易工具（下单/改单/撤单、订单/成交/费用/现金流水等） |
| `FUTU_ENABLE_POSITIONS` | `1` | 控制持仓工具（`get_positions` / `get_position_list`） |

## Trade Overview 覆盖映射

| 官方 Trade 接口 | MCP 工具 | 状态 | 说明 |
|---|---|---|---|
| `place_order` | `place_order` | 已实现 | 受 `FUTU_ENABLE_TRADING` 控制 |
| `modify_order` | `modify_order` | 已实现 | 受 `FUTU_ENABLE_TRADING` 控制 |
| `cancel_order` | `cancel_order` | 已实现 | 受 `FUTU_ENABLE_TRADING` 控制 |
| `get_order_list` | `get_order_list` | 已实现 | 受 `FUTU_ENABLE_TRADING` 控制 |
| `get_position_list` | `get_position_list` | 已实现 | 受 `FUTU_ENABLE_POSITIONS` 控制 |
| `get_asset_list` | `get_asset_list` | 兼容映射 | 复用 `accinfo_query`（与 `get_funds` 一致） |
| `get_acc_list` | `get_acc_list` | 已实现 | `get_account_list` 官方命名别名 |
| `get_fund_list` | `get_fund_list` | 已实现 | `get_funds` 官方命名别名 |
| `get_history_order_list` | `get_history_order_list` | 已实现 | 受 `FUTU_ENABLE_TRADING` 控制 |
| `get_history_deal_list` | `get_history_deal_list` | 已实现 | 受 `FUTU_ENABLE_TRADING` 控制 |
| `get_history_position_list` | `get_history_position_list` | 已暴露（受限） | 当前 `futu-api` 无对应 SDK 方法，返回明确错误 |
| `get_history_asset_list` | `get_history_asset_list` | 已暴露（受限） | 当前 `futu-api` 无对应 SDK 方法，返回明确错误 |
| `get_history_fund_list` | `get_history_fund_list` | 已暴露（受限） | 当前 `futu-api` 无对应 SDK 方法，返回明确错误 |

## MCP 工具全量清单

### 行情与订阅

- `get_stock_quote`
- `get_market_snapshot`
- `get_cur_kline`
- `get_history_kline`
- `get_rt_data`
- `get_ticker`
- `get_order_book`
- `get_broker_queue`
- `subscribe`
- `unsubscribe`
- `get_market_state`
- `get_security_info`
- `get_security_list`
- `get_stock_filter`

### 期权与衍生品

- `get_option_chain`
- `get_option_expiration_date`
- `get_option_condor`
- `get_option_butterfly`

### 账户、持仓、交易

- `get_account_list`
- `get_acc_list`
- `get_funds`
- `get_fund_list`
- `get_asset_list`
- `get_positions`
- `get_position_list`
- `get_max_power`
- `get_margin_ratio`
- `unlock_trade`
- `place_order`
- `modify_order`
- `cancel_order`
- `cancel_all_orders`
- `get_order_list`
- `get_history_order_list`
- `get_deal_list`
- `get_history_deal_list`
- `get_order_fee`
- `get_acc_cash_flow`
- `get_acc_trading_info`
- `get_history_position_list`
- `get_history_asset_list`
- `get_history_fund_list`

### 通用

- `get_current_time`

## 关键官方链接（交易）

- Place Order: <https://openapi.futunn.com/futu-api-doc/en/trade/place-order.html>
- Modify Order: <https://openapi.futunn.com/futu-api-doc/en/trade/modify-order.html>
- Cancel Order: <https://openapi.futunn.com/futu-api-doc/en/trade/cancel-order.html>
- Get Order List: <https://openapi.futunn.com/futu-api-doc/en/trade/get-order-list.html>
- Get Position List: <https://openapi.futunn.com/futu-api-doc/en/trade/get-position-list.html>
- Get Acc List: <https://openapi.futunn.com/futu-api-doc/en/trade/get-acc-list.html>
- Get Fund List: <https://openapi.futunn.com/futu-api-doc/en/trade/get-fund-list.html>
- Get History Order List: <https://openapi.futunn.com/futu-api-doc/en/trade/get-history-order-list.html>
- Get History Deal List: <https://openapi.futunn.com/futu-api-doc/en/trade/get-history-deal-list.html>
- Get History Position List: <https://openapi.futunn.com/futu-api-doc/en/trade/get-history-position-list.html>
- Get History Asset List: <https://openapi.futunn.com/futu-api-doc/en/trade/get-history-asset-list.html>
- Get History Fund List: <https://openapi.futunn.com/futu-api-doc/en/trade/get-history-fund-list.html>

