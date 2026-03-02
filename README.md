
# Futu Stock MCP Server

[![Python Version](https://img.shields.io/badge/python-3.10%2B-blue)](https://www.python.org)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![OpenAPI](https://img.shields.io/badge/Futu-OpenAPI-orange)](https://openapi.futunn.com/futu-api-doc/)

基于[模型上下文协议(MCP)](https://github.com/cursor-ai/model-context-protocol)的富途证券行情交易接口服务器。将富途OpenAPI功能以标准化的MCP协议提供给AI模型使用，支持行情订阅、数据查询等功能。

## 🌟 特性

- 🔌 完全兼容 MCP 2.0 协议标准
- 📊 支持港股、美股、A股等市场的实时行情
- 🔄 支持实时数据订阅和推送
- 📈 支持K线、逐笔、买卖盘等多维度数据
- 🔒 安全的API调用和数据访问机制
- 🛠 提供完整的开发工具和示例代码

## ⚠️ 前置要求

在使用本项目之前，您需要：

1. 拥有富途证券账户并开通OpenAPI权限
2. 安装并运行富途的OpenD网关程序（[官方文档](https://openapi.futunn.com/futu-api-doc/intro/intro.html)）
3. 根据您的需求订阅相应的行情权限

## 🔒 安全提示

- 请勿在代码中硬编码任何账号密码信息
- 确保`.env`文件已添加到`.gitignore`中
- 妥善保管您的API访问凭证
- 遵守富途OpenAPI的使用条款和限制

## 📝 免责声明

本项目是一个开源工具，旨在简化富途OpenAPI的接入流程。使用本项目时请注意：

1. 遵守相关法律法规和富途OpenAPI的使用条款
2. 自行承担使用本项目进行交易的风险
3. 本项目不提供任何投资建议
4. 使用本项目前请确保您已获得所需的行情权限

## Features

- Standard MCP 2.0 protocol compliance
- Comprehensive Futu API coverage
- Real-time data subscription support
- Market data access
- Derivatives information
- Account query capabilities
- Resource-based data access
- Interactive prompts for analysis

## Prerequisites

- Python 3.10+
- Futu OpenAPI SDK
- Model Context Protocol SDK
- uv (recommended)

## 🚀 快速开始

### 方式一：通过 pipx 安装（推荐）

```bash
# 安装 pipx（如果还没有安装）
brew install pipx  # macOS
# 或者 pip install --user pipx  # 其他系统

# 安装包
pipx install futu-stock-mcp-server

# 运行服务器
futu-mcp-server
```

> **为什么使用 pipx？**
> - pipx 专门用于安装 Python 应用程序到全局环境
> - 自动管理独立的虚拟环境，避免依赖冲突
> - 命令直接可用，无需激活虚拟环境

### 方式二：通过 Docker 运行

```bash
# 拉取镜像
docker pull your-registry/futu-stock-mcp-server:latest

# 运行容器
docker run -d \
  --name futu-mcp-server \
  -p 8000:8000 \
  -e FUTU_HOST=127.0.0.1 \
  -e FUTU_PORT=11111 \
  your-registry/futu-stock-mcp-server:latest
```

### 方式三：从源码安装

1. Clone the repository:
```bash
git clone https://github.com/yourusername/futu-stock-mcp-server.git
cd futu-stock-mcp-server
```

2. Install uv:
```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

3. Create and activate a virtual environment:
```bash
# Create virtual environment
uv venv

# Activate virtual environment
# On macOS/Linux:
source .venv/bin/activate
# On Windows:
.venv\Scripts\activate
```

4. Install dependencies:
```bash
# Install in editable mode
uv pip install -e .
```

5. (可选) 如需从源码直接运行，通过环境变量配置服务：
```bash
export FUTU_HOST=127.0.0.1
export FUTU_PORT=11111
```

> **推荐方式**：在 MCP 客户端配置文件中使用 `env` 字段注入，无需创建 `.env` 文件，见下方 [MCP Server 配置](#-mcp-server-配置) 章节。

## Development

### Managing Dependencies

Add new dependencies to `pyproject.toml`:
```toml
[project]
dependencies = [
    # ... existing dependencies ...
    "new-package>=1.0.0",
]
```

Then update your environment:
```bash
uv pip install -e .
```

### Code Style

This project uses Ruff for code linting and formatting. The configuration is in `pyproject.toml`:

```toml
[tool.ruff]
line-length = 100
target-version = "py38"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "B", "UP"]
```

Run linting:
```bash
uv pip install ruff
ruff check .
```

Run formatting:
```bash
ruff format .
```

## 🔧 MCP Server 配置

### 在 Claude Desktop 中配置

1. **找到配置文件位置**：
   - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

2. **添加服务器配置**（所有参数均通过 `env` 字段注入，无需 `.env` 文件）：
```json
{
  "mcpServers": {
    "futu-stock": {
      "command": "futu-mcp-server",
      "env": {
        "FUTU_HOST": "127.0.0.1",
        "FUTU_PORT": "11111",
        "FUTU_ENABLE_POSITIONS": "1",
        "FUTU_ENABLE_TRADING": "0",
        "FUTU_TRADE_ENV": "SIMULATE",
        "FUTU_SECURITY_FIRM": "FUTUSECURITIES",
        "FUTU_TRD_MARKET": "HK"
      }
    }
  }
}
```

3. **使用 `python` 命令启动**（适用于源码开发场景）：
```json
{
  "mcpServers": {
    "futu-stock": {
      "command": "python",
      "args": ["-m", "futu_stock_mcp_server.server"],
      "env": {
        "FUTU_HOST": "127.0.0.1",
        "FUTU_PORT": "11111"
      }
    }
  }
}
```

4. **故障排除配置**：
如果上述配置不工作，可以尝试使用完整路径：
```json
{
  "mcpServers": {
    "futu-stock": {
      "command": "/Users/your-username/.local/bin/futu-mcp-server",
      "env": {
        "FUTU_HOST": "127.0.0.1",
        "FUTU_PORT": "11111"
      }
    }
  }
}
```

> **提示**：使用 `which futu-mcp-server` 命令查看完整路径

### 在其他 MCP 客户端中配置

#### 使用 Python MCP 客户端
```python
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def main():
    server_params = StdioServerParameters(
        command="futu-mcp-server",
        env={
            "FUTU_HOST": "127.0.0.1",
            "FUTU_PORT": "11111"
        }
    )
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # Initialize the connection
            await session.initialize()
            
            # List available tools
            tools = await session.list_tools()
            print("Available tools:", [tool.name for tool in tools.tools])
```
            
#### 使用 Node.js MCP 客户端
```javascript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const transport = new StdioClientTransport({
  command: "futu-mcp-server",
  env: {
    FUTU_HOST: "127.0.0.1",
    FUTU_PORT: "11111"
  }
});

const client = new Client({
  name: "futu-stock-client",
  version: "1.0.0"
}, {
  capabilities: {}
});

await client.connect(transport);
```

## 📋 使用方法

### 1. 启动服务器（独立运行）
```bash
# 通过 pip 安装后
futu-mcp-server

# 或从源码运行
python -m futu_stock_mcp_server.server
```

### 2. 环境变量配置

推荐在 MCP 客户端的 `env` 字段中直接配置，无需 `.env` 文件：

| 环境变量 | 说明 | 默认值 |
|---|---|---|
| `FUTU_HOST` | OpenD 地址 | `127.0.0.1` |
| `FUTU_PORT` | OpenD 端口 | `11111` |
| `FUTU_TRADE_ENV` | 交易环境 (`SIMULATE`/`REAL`) | `SIMULATE` |
| `FUTU_SECURITY_FIRM` | 券商 (`FUTUSECURITIES`/`FUTUINC`) | `FUTUSECURITIES` |
| `FUTU_TRD_MARKET` | 交易市场 (`HK`/`US`) | `HK` |
| `FUTU_DEBUG_MODE` | 调试日志开关 (`0`/`1`) | `0` |

### 3. 验证连接
启动服务器后，你应该看到类似的日志：
```
2024-10-02 14:20:52 | INFO | Initializing Futu connection...
2024-10-02 14:20:52 | INFO | Successfully initialized Futu connection
2024-10-02 14:20:52 | INFO | Starting MCP server in stdio mode...
2024-10-02 14:20:52 | INFO | Press Ctrl+C to stop the server
```

### 4. 在 AI 工具中使用
配置完成后，重启 Claude Desktop 或其他 MCP 客户端，你就可以：
- 查询股票实时行情
- 获取历史K线数据
- 订阅股票数据推送
- 查询账户信息
- 执行交易操作（需要交易权限）

## 🔧 故障排除

### 常见问题

#### 1. 命令 `futu-mcp-server` 找不到
```bash
# 确保已正确安装
pipx install futu-stock-mcp-server

# 检查命令是否可用
which futu-mcp-server

# 如果还是找不到，检查 PATH
echo $PATH | grep -o '[^:]*\.local/bin[^:]*'
```

#### 2. Ctrl+C 无法退出服务器
- 新版本已修复此问题
- 如果仍然遇到，可以使用 `kill -9 <pid>` 强制终止

#### 3. 连接富途 OpenD 失败
```bash
# 检查 OpenD 是否运行
netstat -an | grep 11111

# 检查环境变量
echo $FUTU_HOST
echo $FUTU_PORT
```

#### 4. Claude Desktop 无法识别服务器
- 确保配置文件路径正确
- 检查 JSON 格式是否有效
- 重启 Claude Desktop
- 查看 Claude Desktop 的日志文件

#### 5. 权限问题
```bash
# 确保有执行权限
chmod +x ~/.local/bin/futu-mcp-server

# 或者使用完整路径
python -m futu_stock_mcp_server.server
```

### 日志调试

本项目已根据 [MCP 官方文档](https://github.com/modelcontextprotocol/python-sdk) 的最佳实践配置了日志系统：

#### MCP 兼容的日志配置
- **文件日志**: 所有日志写入 `logs/futu_server.log`，自动轮转和清理
- **MCP Context 日志**: 工具执行期间通过 MCP Context 发送日志给客户端
- **stdout 保护**: 确保 stdout 仅用于 MCP JSON 通信，避免污染

#### 调试模式（仅开发时使用）
```bash
# 启用调试模式（会向 stderr 输出日志）
export FUTU_DEBUG_MODE=1
futu-mcp-server
```

**注意**: 在 MCP 客户端中不要启用调试模式，因为它会向 stderr 输出日志。

#### 日志文件位置
- 主日志文件：`./logs/futu_server.log`
- 自动轮转：500 MB 后轮转
- 自动清理：保留 10 天

详细的日志配置说明请参考 [docs/LOGGING.md](docs/LOGGING.md)。
            tools = await session.list_tools()

            # Call a tool
            result = await session.call_tool(
                "get_stock_quote",
                arguments={"symbols": ["HK.00700"]}
            )
            
            # Access a resource
            content, mime_type = await session.read_resource(
                "market://HK.00700"
            )
            
            # Get a prompt
            prompt = await session.get_prompt(
                "market_analysis",
                arguments={"symbol": "HK.00700"}
            )

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

## Changelog

Latest updates (`2026-03-02`) - v0.1.5:
- **环境变量优先配置**：`FUTU_HOST` / `FUTU_PORT` 现在直接通过 MCP 客户端 `env` 字段注入，无需 `.env` 文件。
- 移除 `python-dotenv` 导入，简化依赖。
- 新增 `python -m` 启动方式的配置示例。

Previous updates (`2026-03-02`) - v0.1.4:
- Added trading MCP tools: `unlock_trade`, `place_order`, `modify_order`, `cancel_order`, `cancel_all_orders`, order/deal query tools, fee/cashflow tools.
- Added position and trade feature switches: `FUTU_ENABLE_POSITIONS`, `FUTU_ENABLE_TRADING`.
- Added official Futu API to MCP mapping doc: [docs/FUTU_API_MCP_COVERAGE.md](docs/FUTU_API_MCP_COVERAGE.md).
- Kept backward compatibility: existing MCP tool names and argument contracts were not changed.

Full history: [CHANGELOG.md](CHANGELOG.md)

## Available API Methods

Full mapping document (official Futu API -> MCP tools): [docs/FUTU_API_MCP_COVERAGE.md](docs/FUTU_API_MCP_COVERAGE.md)

### Market Data Tools
- `get_stock_quote`: Get stock quote data
- `get_market_snapshot`: Get market snapshot
- `get_cur_kline`: Get current K-line data
- `get_history_kline`: Get historical K-line data
- `get_rt_data`: Get real-time data
- `get_ticker`: Get ticker data
- `get_order_book`: Get order book data
- `get_broker_queue`: Get broker queue data

### Subscription Tools
- `subscribe`: Subscribe to real-time data
- `unsubscribe`: Unsubscribe from real-time data

### Derivatives Tools
- `get_option_chain`: Get option chain data
- `get_option_expiration_date`: Get option expiration dates
- `get_option_condor`: Get option condor strategy data
- `get_option_butterfly`: Get option butterfly strategy data

### Account Query Tools
- `get_account_list`: Get account list
- `get_funds`: Get account funds information
- `get_positions`: Get account positions
- `get_position_list`: Get account positions with filters
- `get_max_power`: Get account buying power
- `get_margin_ratio`: Get margin ratio for a security

### Trading Tools
- `unlock_trade`: Unlock trade operations
- `place_order`: Place order
- `modify_order`: Modify order
- `cancel_order`: Cancel one order
- `cancel_all_orders`: Cancel all cancellable orders
- `get_order_list`: Query current order list
- `get_history_order_list`: Query historical orders
- `get_deal_list`: Query current deals
- `get_history_deal_list`: Query historical deals
- `get_order_fee`: Query order fee details
- `get_acc_cash_flow`: Query cash flow details
- `get_acc_trading_info`: Query trade capability/pre-check

### Market Information Tools
- `get_market_state`: Get market state
- `get_security_info`: Get security information
- `get_security_list`: Get security list

### Stock Filter Commands

#### get_stock_filter
Filter stocks based on various conditions.

Parameters:
- `base_filters` (optional): List of basic stock filters
  ```python
  {
      "field_name": int,  # StockField enum value
      "filter_min": float,  # Optional minimum value
      "filter_max": float,  # Optional maximum value
      "is_no_filter": bool,  # Optional, whether to skip filtering
      "sort_dir": int  # Optional, sort direction
  }
  ```
- `accumulate_filters` (optional): List of accumulate filters
  ```python
  {
      "field_name": int,  # AccumulateField enum value
      "filter_min": float,
      "filter_max": float,
      "is_no_filter": bool,
      "sort_dir": int,
      "days": int  # Required, number of days to accumulate
  }
  ```
- `financial_filters` (optional): List of financial filters
  ```python
  {
      "field_name": int,  # FinancialField enum value
      "filter_min": float,
      "filter_max": float,
      "is_no_filter": bool,
      "sort_dir": int,
      "quarter": int  # Required, financial quarter
  }
  ```
- `market` (optional): Market code (e.g. "HK.Motherboard", "US.NASDAQ")
- `page` (optional): Page number, starting from 1 (default: 1)
- `page_size` (optional): Number of results per page, max 200 (default: 200)

Supported Market Codes:
- `HK.Motherboard`: Hong Kong Main Board
- `HK.GEM`: Hong Kong GEM
- `HK.BK1911`: H-Share Main Board
- `HK.BK1912`: H-Share GEM
- `US.NYSE`: NYSE
- `US.AMEX`: AMEX
- `US.NASDAQ`: NASDAQ
- `SH.3000000`: Shanghai Main Board
- `SZ.3000001`: Shenzhen Main Board
- `SZ.3000004`: Shenzhen ChiNext

Example:
```python
# Get stocks with price between 10 and 50 HKD in Hong Kong Main Board
filters = {
    "base_filters": [{
        "field_name": 5,  # Current price
        "filter_min": 10.0,
        "filter_max": 50.0
    }],
    "market": "HK.Motherboard"
}
result = await client.get_stock_filter(**filters)
```

Notes:
- Limited to 10 requests per 30 seconds
- Each page returns maximum 200 results
- Recommended to use no more than 250 filter conditions
- Maximum 10 accumulate conditions of the same type
- Dynamic data sorting (like current price) may change between pages
- Cannot compare different types of indicators (e.g. MA5 vs EMA10)

## Resources

### Market Data
- `market://{symbol}`: Get market data for a symbol
- `kline://{symbol}/{ktype}`: Get K-line data for a symbol

## Prompts

### Analysis
- `market_analysis`: Create a market analysis prompt
- `option_strategy`: Create an option strategy analysis prompt

## Error Handling

The server follows the MCP 2.0 error response format:

```json
{
    "jsonrpc": "2.0",
    "id": "request_id",
    "error": {
        "code": -32000,
        "message": "Error message",
        "data": null
    }
}
```

## Security

- The server uses secure WebSocket connections
- All API calls are authenticated through the Futu OpenAPI
- Environment variables are used for sensitive configuration

## Development

### Adding New Tools

To add a new tool, use the `@mcp.tool()` decorator:

```python
@mcp.tool()
async def new_tool(param1: str, param2: int) -> Dict[str, Any]:
    """Tool description"""
    # Implementation
    return result
```

### Adding New Resources

To add a new resource, use the `@mcp.resource()` decorator:

```python
@mcp.resource("resource://{param1}/{param2}")
async def new_resource(param1: str, param2: str) -> Dict[str, Any]:
    """Resource description"""
    # Implementation
    return result
```

### Adding New Prompts

To add a new prompt, use the `@mcp.prompt()` decorator:

```python
@mcp.prompt()
async def new_prompt(param1: str) -> str:
    """Prompt description"""
    return f"Prompt template with {param1}"
```

## License

MIT License

## Available MCP Functions

### Market Data Functions

#### get_stock_quote
Get stock quote data for given symbols.
```python
symbols = ["HK.00700", "US.AAPL", "SH.600519"]
result = await session.call_tool("get_stock_quote", {"symbols": symbols})
```
Returns quote data including price, volume, turnover, etc.

#### get_market_snapshot
Get market snapshot for given symbols.
```python
symbols = ["HK.00700", "US.AAPL", "SH.600519"]
result = await session.call_tool("get_market_snapshot", {"symbols": symbols})
```
Returns comprehensive market data including price, volume, bid/ask prices, etc.

#### get_cur_kline
Get current K-line data.
```python
result = await session.call_tool("get_cur_kline", {
    "symbol": "HK.00700",
    "ktype": "K_1M",  # K_1M, K_5M, K_15M, K_30M, K_60M, K_DAY, K_WEEK, K_MON
    "count": 100
})
```

#### get_history_kline
Get historical K-line data.
```python
result = await session.call_tool("get_history_kline", {
    "symbol": "HK.00700",
    "ktype": "K_DAY",
    "start": "2024-01-01",
    "end": "2024-03-31"
})
```

#### get_rt_data
Get real-time trading data.
```python
result = await session.call_tool("get_rt_data", {"symbol": "HK.00700"})
```

#### get_ticker
Get ticker data (detailed trades).
```python
result = await session.call_tool("get_ticker", {"symbol": "HK.00700"})
```

#### get_order_book
Get order book data.
```python
result = await session.call_tool("get_order_book", {"symbol": "HK.00700"})
```

#### get_broker_queue
Get broker queue data.
```python
result = await session.call_tool("get_broker_queue", {"symbol": "HK.00700"})
```

### Subscription Functions

#### subscribe
Subscribe to real-time data.
```python
result = await session.call_tool("subscribe", {
    "symbols": ["HK.00700", "US.AAPL"],
    "sub_types": ["QUOTE", "TICKER", "K_1M"]
})
```
Subscription types:
- "QUOTE": Basic quote
- "ORDER_BOOK": Order book
- "TICKER": Trades
- "RT_DATA": Real-time data
- "BROKER": Broker queue
- "K_1M" to "K_MON": K-line data

#### unsubscribe
Unsubscribe from real-time data.
```python
result = await session.call_tool("unsubscribe", {
    "symbols": ["HK.00700", "US.AAPL"],
    "sub_types": ["QUOTE", "TICKER"]
})
```

### Options Functions

#### get_option_chain
Get option chain data.
```python
result = await session.call_tool("get_option_chain", {
    "symbol": "HK.00700",
    "start": "2024-04-01",
    "end": "2024-06-30"
})
```

#### get_option_expiration_date
Get option expiration dates.
```python
result = await session.call_tool("get_option_expiration_date", {
    "symbol": "HK.00700"
})
```

#### get_option_condor
Get option condor strategy data.
```python
result = await session.call_tool("get_option_condor", {
    "symbol": "HK.00700",
    "expiry": "2024-06-30",
    "strike_price": 350.0
})
```

#### get_option_butterfly
Get option butterfly strategy data.
```python
result = await session.call_tool("get_option_butterfly", {
    "symbol": "HK.00700",
    "expiry": "2024-06-30",
    "strike_price": 350.0
})
```

### Account Functions

#### get_account_list
Get account list.
```python
result = await session.call_tool("get_account_list", {"random_string": "dummy"})
```

#### get_funds
Get account funds information.
```python
result = await session.call_tool("get_funds", {"random_string": "dummy"})
```

#### get_positions
Get account positions.
```python
result = await session.call_tool("get_positions", {"random_string": "dummy"})
```

#### get_max_power
Get maximum trading power.
```python
result = await session.call_tool("get_max_power", {"random_string": "dummy"})
```

#### get_margin_ratio
Get margin ratio for a security.
```python
result = await session.call_tool("get_margin_ratio", {"symbol": "HK.00700"})
```

### Market Information Functions

#### get_market_state
Get market state.
```python
result = await session.call_tool("get_market_state", {"market": "HK"})
```
Available markets: "HK", "US", "SH", "SZ"

#### get_security_info
Get security information.
```python
result = await session.call_tool("get_security_info", {
    "market": "HK",
    "code": "00700"
})
```

#### get_security_list
Get security list for a market.
```python
result = await session.call_tool("get_security_list", {"market": "HK"})
```

#### get_stock_filter
Get filtered stock list based on conditions.
```python
result = await session.call_tool("get_stock_filter", {
    "market": "HK.Motherboard",
    "base_filters": [{
        "field_name": 1,  # Price
        "filter_min": 10.0,
        "filter_max": 50.0,
        "sort_dir": 1  # Ascending
    }],
    "page": 1,
    "page_size": 50
})
```

### Time Function

#### get_current_time
Get current server time.
```python
result = await session.call_tool("get_current_time", {"random_string": "dummy"})
```
Returns timestamp, formatted datetime, date, time and timezone. 
