# 日志使用教程

[中文](index.md)|[English](index.en.md)

## 教程

- [Component Tutorial](component-tutorial.en.md) | [组件开发教程](component-tutorial.md)
- [Multiprocessing Tutorial](multiprocessing-tutorial.en.md) | [多进程教程](multiprocessing-tutorial.md)
- [Event Mode Tutorial](event-mode-tutorial.en.md) | [事件模式教程](event-mode-tutorial.md)
- [Logging Tutorial](logging-tutorial.en.md) | [日志使用](logging-tutorial.md)

## 概述

本项目使用 Python 标准库 `logging` 模块进行日志管理，提供了统一的日志配置和便捷的工具函数。

## 日志级别

日志系统支持以下级别（从低到高）：

| 级别 | 用途 |
|------|------|
| `DEBUG` | 调试信息，详细的诊断信息 |
| `INFO` | 一般信息，确认程序按预期运行 |
| `WARNING` | 警告信息，表示发生了意外情况 |
| `ERROR` | 错误信息，程序遇到了严重问题 |
| `CRITICAL` | 严重错误，程序可能无法继续运行 |

## 基本使用

### 1. 设置日志器

在应用程序启动时，通过 `setup_logger()` 配置日志器：

```python
from app.core.util.logger import setup_logger

# 设置应用级别的日志器
logger = setup_logger("app", level="INFO")
```

### 2. 获取日志器

在模块或组件中，使用 `get_logger()` 获取已配置的日志器：

```python
from app.core.util.logger import get_logger

logger = get_logger("my_module")
logger.info("模块已加载")
```

### 3. 使用 LogMixin 混入类

为类提供日志功能，推荐在组件中使用：

```python
from app.core.util.logger import LogMixin

class MyComponent(LogMixin):
    def __init__(self):
        self.logger.info("组件初始化")
    
    def do_something(self):
        self.logger.debug("开始执行操作")
        try:
            result = self._process()
            self.logger.info("操作完成")
            return result
        except Exception as e:
            self.logger.error(f"操作失败: {e}")
            raise
```

### 4. 记录不同级别的日志

```python
logger.debug("调试信息")
logger.info("普通信息")
logger.warning("警告信息")
logger.error("错误信息")
logger.critical("严重错误")
```

## 高级功能

### 1. 异常记录

使用 `log_exception()` 记录异常信息：

```python
from app.core.util.logger import log_exception

try:
    risky_operation()
except Exception as e:
    log_exception(logger, "操作失败", exc_info=True)
```

### 2. 函数入口/出口记录

```python
from app.core.util.logger import log_function_entry, log_function_exit

def my_function(arg1, arg2):
    log_function_entry(logger, "my_function", args=(arg1, arg2))
    
    try:
        result = arg1 + arg2
        log_function_exit(logger, "my_function", result)
        return result
    except Exception as e:
        logger.error(f"函数执行失败: {e}")
        raise
```

### 3. 计时操作装饰器

使用 `@timed_operation` 装饰器记录操作耗时：

```python
from app.core.util.logger import timed_operation

@timed_operation(logger, "database_query")
def query_database():
    # 执行数据库查询
    pass
```

## 前端日志

前端日志通过 MiniBlink 引擎自动转发到 Python 日志系统，无需额外配置。

### 基本使用

```javascript
console.log("调试信息");
console.info("普通信息");
console.warn("警告信息");
console.error("错误信息");
console.debug("调试信息");
```

### 输出示例

```
[CONSOLE][LOG] 调试信息 (file:index.html:10)
[CONSOLE][INFO] 普通信息 (file:index.html:11)
[CONSOLE][WARNING] 警告信息 (file:index.html:12)
[CONSOLE][ERROR] 错误信息 (file:index.html:13)
[CONSOLE][DEBUG] 调试信息 (file:index.html:14)
```

### 日志级别对应

| 前端方法 | 后端日志级别 |
|----------|-------------|
| `console.log()` | LOG |
| `console.info()` | INFO |
| `console.warn()` | WARNING |
| `console.error()` | ERROR |
| `console.debug()` | DEBUG |

### 注意事项

- 前端日志默认会输出到 Python 控制台
- 日志级别取决于前端调用的具体方法
- 文件路径和行号会自动记录，方便定位问题

## 在组件中使用日志

### 示例：计算器组件

```python
from app.core.cell.icell import ICell
from app.core.util.logger import LogMixin

class CalculatorCell(ICell, LogMixin):
    """计算器组件"""
    
    @property
    def cell_name(self) -> str:
        return "calculator"
    
    def execute(self, command: str, *args, **kwargs):
        self.logger.debug(f"执行命令: {command}, 参数: {args}")
        
        if command == "add":
            result = self._add(args[0], args[1])
            self.logger.info(f"加法结果: {result}")
            return str(result)
        
        return "Unknown command"
    
    def _add(self, a: float, b: float) -> float:
        try:
            return a + b
        except Exception as e:
            self.logger.error(f"加法计算失败: {e}")
            raise
```

### 示例：事件处理器

```python
from app.core.event.event_bus import EventBus
from app.core.event.event import Event
from app.core.util.logger import LogMixin

class MyEventHandler(LogMixin):
    def __init__(self, event_bus: EventBus):
        self.event_bus = event_bus
        self.logger.info("事件处理器初始化")
    
    @event_bus.event("app.startup")
    def on_startup(self, event: Event):
        self.logger.info("应用启动事件")
        self.logger.debug(f"事件数据: {event.data}")
```

## 日志格式

默认日志格式为：

```
[LEVEL] logger_name: message
```

示例输出：

```
[INFO] app.core.util.components_loader: 组件加载完成
[WARNING] app.core.handler.message_handler: 未知的命令: unknown
[ERROR] app.core.handler.title_bar_handler: 切换窗口状态失败: name 'byref' is not defined
```

## 自定义日志配置

### 修改日志级别

在 `main.py` 中修改日志级别：

```python
# 开发环境使用 DEBUG 级别
setup_logger("app", level="DEBUG")

# 生产环境使用 INFO 级别
setup_logger("app", level="INFO")
```

### 自定义日志格式

```python
custom_format = "[%(asctime)s] [%(levelname)s] %(name)s:%(lineno)d - %(message)s"
logger = setup_logger("app", level="INFO", log_format=custom_format)
```

## 最佳实践

1. **选择合适的日志级别**
   - 使用 `DEBUG` 记录详细的调试信息
   - 使用 `INFO` 记录重要的业务流程
   - 使用 `WARNING` 记录可恢复的异常情况
   - 使用 `ERROR` 记录需要关注的错误
   - 使用 `CRITICAL` 记录导致程序无法继续的错误

2. **在组件中使用 LogMixin**
   - 继承 `LogMixin` 类可以自动获得 `logger` 属性
   - 日志器名称自动使用类名，便于追踪

3. **记录关键操作**
   - 组件初始化和销毁
   - 命令执行和结果
   - 异常和错误情况
   - 重要状态变化

4. **避免过度日志**
   - 不要在循环中记录大量日志
   - 敏感信息（密码、密钥）不要记录到日志中
   - 使用 `DEBUG` 级别记录详细调试信息

5. **使用结构化日志**
   - 日志消息应该清晰、简洁
   - 包含足够的上下文信息
   - 使用一致的格式

## 常见问题

### Q: 如何查看日志？

A: 日志默认输出到控制台（stdout）。在开发环境中，你可以直接在终端查看日志输出。

### Q: 如何将日志写入文件？

A: 当前版本的日志系统只输出到控制台。如需写入文件，可以修改 `logger.py` 添加 `FileHandler`。

### Q: 不同组件的日志如何区分？

A: 使用不同的日志器名称。例如：
```python
logger1 = get_logger("component_a")
logger2 = get_logger("component_b")
```

### Q: 如何在生产环境中减少日志输出？

A: 将日志级别设置为 `INFO` 或 `WARNING`：
```python
setup_logger("app", level="WARNING")
```

## 相关文件

- `app/core/util/logger.py` - 日志模块实现
- `main.py` - 应用入口，日志初始化
- `app/components/` - 各组件的日志使用示例
