---
name: futu-stock-remote
description: Use Futu stock MCP over intranet - real-time quotes, K-lines, options, account for HK/US/CN via remote Streamable HTTP URL (OpenClaw agent)
metadata: {"openclaw": {"emoji": "📈", "requires": {"url": "http://{MCP_HOST}:8000/mcp"}, "primaryEnv": "MCP_SERVER_URL"}, "mode": "intranet"}
version: 1.0.0
---

# futu-stock-remote Skill（OpenClaw 内网调用）

面向 **OpenClaw AI Agent** 的富途行情 Skill。MCP 服务器与 OpenD 部署在**内网另一台机器**，本机通过 **Streamable HTTP URL** 连接，无需在本机安装 futu-mcp-server 或 OpenD。

**MCP 源码**: https://github.com/shuizhengqi1/futu-stock-mcp-server

---

## 一、前置条件（无需本机部署）

- **内网机器**已运行：
  - 富途 OpenD（如 `127.0.0.1:11111`）
  - futu-stock MCP 服务器（Streamable HTTP 模式，如 `0.0.0.0:8000`）
- **OpenClaw** 已配置该 MCP 服务器为 **URL 连接**，例如：
  - `http://192.168.1.100:8000/mcp`（将 `192.168.1.100` 换成实际内网 IP 或主机名）

**一键添加 Skill**：MCP 以 streamable-http 模式启动后，会同时提供 **Skill 拉取 URL**：`http://<内网机器>:<MCP端口+1>/skill`（例如 `http://192.168.1.100:8001/skill`）。将该链接发给 Agent，拉取到的内容里已包含当前 MCP 的地址，Agent 可直接据此添加本 Skill。

你作为 Agent **不需要**在本机执行 `executor.py`、`pipx install`、检查 OpenD 端口或配置 `OPEND_PATH`；只需在对话中**按下面规则调用 MCP 工具**即可。

---

## 二、整体流程

```
┌─────────────────────────────────────────────────────────────────────────┐
│  用户请求                                                                │
│     ├─ 有明确股票代码（如 HK.00700、US.AAPL）                              │
│     │   → 直接调用 get_stock_quote / get_market_snapshot /               │
│     │     get_history_kline / get_option_chain 等                        │
│     └─ 无股票代码（如「港股 10–50 元的股票」「纳斯达克涨幅前 20」）           │
│        → 使用 get_stock_filter 按条件筛选                                │
├─────────────────────────────────────────────────────────────────────────┤
│  需订阅后才有数据的工具                                                   │
│     → 先调用 subscribe，再调用 get_cur_kline / get_rt_data /            │
│       get_ticker / get_order_book / get_broker_queue                     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 三、查询逻辑（核心规则）

### 3.1 有明确股票代码

用户给出具体代码（如 `HK.00700`、`00700`、`腾讯` 且能映射到代码）时，直接按代码查询：

| 需求类型       | 推荐工具                | 示例参数 |
|----------------|-------------------------|----------|
| 实时报价       | `get_stock_quote` 或 `get_market_snapshot` | `{"symbols": ["HK.00700"]}` |
| 历史 K 线      | `get_history_kline`     | `{"symbol": "HK.00700", "ktype": "K_DAY", "start": "2026-01-01", "end": "2026-02-25"}` |
| 期权链         | `get_option_chain`      | `{"symbol": "HK.00700", "start": "2026-04-01", "end": "2026-06-30"}` |
| 需订阅的数据   | 先 `subscribe` 再查     | 见下方「需订阅的工具」 |

**股票代码格式**: `{市场}.{代码}`  
- 港股: `HK.00700`  
- 美股: `US.AAPL`  
- 沪市: `SH.600519`  
- 深市: `SZ.000001`  

### 3.2 无股票代码（条件筛选）

用户只给条件（如「港股 10–50 元的股票」「纳斯达克涨幅前 20」）时，使用 `get_stock_filter`：

```json
{
  "market": "HK.Motherboard",
  "base_filters": [{
    "field_name": 5,
    "filter_min": 10.0,
    "filter_max": 50.0,
    "sort_dir": 1
  }],
  "page": 1,
  "page_size": 50
}
```

**常用 market 值**:
- `HK.Motherboard` 港股主板
- `HK.GEM` 港股创业板
- `US.NASDAQ` 纳斯达克
- `US.NYSE` 纽交所
- `SH.3000000` 沪市主板
- `SZ.3000004` 深市创业板

**base_filters 常用 field_name**（富途 StockField）:
- 5: 当前价
- 6: 涨跌幅
- 7: 成交量
- 8: 成交额
- 1: 排序

---

## 四、可用工具速查

### 行情（多数无需订阅）
- `get_stock_quote`: 报价
- `get_market_snapshot`: 快照（含买卖盘）
- `get_history_kline`: 历史 K 线
- `get_cur_kline`: 当前 K 线（需先 subscribe 对应 K 线类型）
- `get_rt_data`: 实时数据（需 subscribe RT_DATA）
- `get_ticker`: 逐笔（需 subscribe TICKER）
- `get_order_book`: 买卖盘（需 subscribe ORDER_BOOK）
- `get_broker_queue`: 经纪队列（需 subscribe BROKER）

### 订阅
- `subscribe`: 订阅 QUOTE / ORDER_BOOK / TICKER / RT_DATA / BROKER / K_1M / K_DAY 等
- `unsubscribe`: 取消订阅

### 期权
- `get_option_chain`: 期权链
- `get_option_expiration_date`: 到期日
- `get_option_condor` / `get_option_butterfly`: 策略数据（部分接口可能弃用）

### 账户
- `get_account_list`: 账户列表
- `get_funds`: 资金
- `get_positions`: 持仓
- `get_max_power`: 最大交易力
- `get_margin_ratio`: 保证金比例

### 市场与筛选
- `get_market_state`: 市场状态
- `get_stock_basicinfo`: 证券基础信息
- `get_stock_list`: 证券列表
- **`get_stock_filter`**: 条件筛选（无代码时使用）

---

## 五、调用方式（Agent 行为）

- 通过 OpenClaw 已配置的 **futu-stock MCP 服务器（URL）** 调用上述工具。
- **不执行** `executor.py`、不执行 `--check-env` / `--call` / `--list`；由 OpenClaw 的 MCP 客户端根据配置的 URL 发起请求。
- 当用户问行情、持仓、筛选股票等时，选择对应工具并传入正确参数（股票代码格式、market、日期范围等）。

### 需订阅的工具

以下工具需先对标的和类型执行 `subscribe`，再查询：

1. 调用 `subscribe`，例如：
   - `{"symbols": ["HK.00700"], "sub_types": ["QUOTE", "K_DAY"]}`
2. 再调用 `get_cur_kline` / `get_rt_data` / `get_ticker` / `get_order_book` / `get_broker_queue` 等。

---

## 六、常见问题与限制

### 股票代码格式

必须使用 `{市场}.{代码}`：
- 港股: `HK.00700`（不是 `00700`）
- 美股: `US.AAPL`（不是 `AAPL`）

### get_stock_filter 限频

- 每 30 秒最多 10 次
- 每页最多 200 条
- 建议不超过 250 个筛选条件

### 历史 K 线限制

- 30 天内最多 30 只股票
- 需合理控制 `start` 和 `end` 范围

### 连接失败

- 确认 OpenClaw 中配置的 MCP 服务器 URL 正确（如 `http://内网IP:8000/mcp`）
- 确认内网机器上 MCP 已用 `--transport streamable-http` 启动且防火墙放行 8000 端口

### 交易与持仓开关

- 账户/持仓/交易类工具受服务端环境变量控制（如 `FUTU_ENABLE_TRADING`、`FUTU_ENABLE_POSITIONS`）。若返回“功能未开启”类错误，说明服务端未开放相应功能，无需在本机安装或配置。

---

## 七、OpenClaw 配置（内网 URL）

在 OpenClaw 侧仅需添加「通过 URL 连接的 MCP 服务器」，无需配置 `command` / `args` 或本机环境变量。

### 方式一：支持 URL 的 MCP 配置

若 OpenClaw 或所用插件（如 MCP Bridge）支持按 URL 添加 MCP 服务器，将地址设为内网机器的 Streamable HTTP 端点，例如：

```json
{
  "mcpServers": {
    "futu-stock": {
      "url": "http://192.168.1.100:8000/mcp"
    }
  }
}
```

或将 `192.168.1.100` 替换为实际内网 IP 或主机名。

### 方式二：插件配置示例（MCP Bridge 等）

若使用带 `url` 的插件配置：

```json
{
  "plugins": {
    "entries": {
      "openclaw-mcp-bridge": {
        "config": {
          "servers": [
            {
              "name": "futu-stock",
              "url": "http://192.168.1.100:8000/mcp",
              "prefix": "futu"
            }
          ]
        }
      }
    }
  }
}
```

### 内网机器端需已完成的准备

- 启动 OpenD（如 `127.0.0.1:11111`）
- 启动 MCP 服务器并监听 HTTP，例如：
  - `futu-mcp-server --host 127.0.0.1 --port 11111 --transport streamable-http --mcp-host 0.0.0.0 --mcp-port 8000`
- 防火墙放行 8000 端口（仅内网即可）

---

## 八、使用流程速查（Agent）

1. **有股票代码** → 用 `get_stock_quote` / `get_market_snapshot` / `get_history_kline` / `get_option_chain` 等，参数中代码使用 `市场.代码` 格式。
2. **无股票代码、只有条件** → 用 `get_stock_filter`，填对 `market` 和 `base_filters`（及可选 `accumulate_filters` / `financial_filters`）。
3. **要当前 K 线/逐笔/买卖盘/经纪队列** → 先 `subscribe` 对应标的和类型，再调相应 get 工具。
4. **账户/资金/持仓** → 调 `get_account_list` / `get_funds` / `get_positions` 等；若报功能未开启，则为服务端配置限制，无需在本机处理。
5. **报错或连接失败** → 提醒用户检查内网 MCP 服务是否启动、URL 是否正确、网络/防火墙是否可达。

---

*本 Skill 供 OpenClaw 通过内网 URL 使用 futu-stock MCP，不涉及本机安装 OpenD 或 futu-mcp-server。*
