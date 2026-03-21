# Logging Tutorial

[中文](index.md)|[English](index.en.md)

## Tutorials

- [Component Tutorial](component-tutorial.en.md) | [组件开发教程](component-tutorial.md)
- [Multiprocessing Tutorial](multiprocessing-tutorial.en.md) | [多进程教程](multiprocessing-tutorial.md)
- [Event Mode Tutorial](event-mode-tutorial.en.md) | [事件模式教程](event-mode-tutorial.md)
- [Logging Tutorial](logging-tutorial.en.md) | [日志使用](logging-tutorial.md)

## Overview

This project uses Python's standard `logging` module for log management, providing unified log configuration and convenient utility functions.

## Log Levels

The logging system supports the following levels (from low to high):

| Level | Purpose |
|-------|---------|
| `DEBUG` | Debug information, detailed diagnostic information |
| `INFO` | General information, confirming the program is running as expected |
| `WARNING` | Warning information, indicating something unexpected happened |
| `ERROR` | Error information, the program encountered a serious problem |
| `CRITICAL` | Critical error, the program may not be able to continue |

## Basic Usage

### 1. Setup Logger

Configure the logger when the application starts using `setup_logger()`:

```python
from app.core.util.logger import setup_logger

# Setup application-level logger
logger = setup_logger("app", level="INFO")
```

### 2. Get Logger

Use `get_logger()` to retrieve a configured logger in modules or components:

```python
from app.core.util.logger import get_logger

logger = get_logger("my_module")
logger.info("Module loaded")
```

### 3. Use LogMixin Mixin Class

Provide logging functionality to classes, recommended for use in components:

```python
from app.core.util.logger import LogMixin

class MyComponent(LogMixin):
    def __init__(self):
        self.logger.info("Component initialized")
    
    def do_something(self):
        self.logger.debug("Starting operation")
        try:
            result = self._process()
            self.logger.info("Operation completed")
            return result
        except Exception as e:
            self.logger.error(f"Operation failed: {e}")
            raise
```

### 4. Log Different Levels

```python
logger.debug("Debug information")
logger.info("General information")
logger.warning("Warning information")
logger.error("Error information")
logger.critical("Critical error")
```

## Advanced Features

### 1. Exception Logging

Use `log_exception()` to log exception information:

```python
from app.core.util.logger import log_exception

try:
    risky_operation()
except Exception as e:
    log_exception(logger, "Operation failed", exc_info=True)
```

### 2. Function Entry/Exit Logging

```python
from app.core.util.logger import log_function_entry, log_function_exit

def my_function(arg1, arg2):
    log_function_entry(logger, "my_function", args=(arg1, arg2))
    
    try:
        result = arg1 + arg2
        log_function_exit(logger, "my_function", result)
        return result
    except Exception as e:
        logger.error(f"Function execution failed: {e}")
        raise
```

### 3. Timed Operation Decorator

Use the `@timed_operation` decorator to log operation duration:

```python
from app.core.util.logger import timed_operation

@timed_operation(logger, "database_query")
def query_database():
    # Execute database query
    pass
```

## Frontend Logging

Frontend logs are automatically forwarded to the Python logging system via the MiniBlink engine, no additional configuration required.

### Basic Usage

```javascript
console.log("Debug info");
console.info("General info");
console.warn("Warning info");
console.error("Error info");
console.debug("Debug info");
```

### Output Example

```
[CONSOLE][LOG] Debug info (file:index.html:10)
[CONSOLE][INFO] General info (file:index.html:11)
[CONSOLE][WARNING] Warning info (file:index.html:12)
[CONSOLE][ERROR] Error info (file:index.html:13)
[CONSOLE][DEBUG] Debug info (file:index.html:14)
```

### Log Level Mapping

| Frontend Method | Backend Log Level |
|-----------------|-------------------|
| `console.log()` | LOG |
| `console.info()` | INFO |
| `console.warn()` | WARNING |
| `console.error()` | ERROR |
| `console.debug()` | DEBUG |

### Notes

- Frontend logs are output to Python console by default
- Log level depends on the specific method called in frontend
- File path and line number are automatically recorded for easy debugging

## Using Logging in Components

### Example: Calculator Component

```python
from app.core.cell.icell import ICell
from app.core.util.logger import LogMixin

class CalculatorCell(ICell, LogMixin):
    """Calculator component"""
    
    @property
    def cell_name(self) -> str:
        return "calculator"
    
    def execute(self, command: str, *args, **kwargs):
        self.logger.debug(f"Executing command: {command}, args: {args}")
        
        if command == "add":
            result = self._add(args[0], args[1])
            self.logger.info(f"Addition result: {result}")
            return str(result)
        
        return "Unknown command"
    
    def _add(self, a: float, b: float) -> float:
        try:
            return a + b
        except Exception as e:
            self.logger.error(f"Addition calculation failed: {e}")
            raise
```

### Example: Event Handler

```python
from app.core.event.event_bus import EventBus
from app.core.event.event import Event
from app.core.util.logger import LogMixin

class MyEventHandler(LogMixin):
    def __init__(self, event_bus: EventBus):
        self.event_bus = event_bus
        self.logger.info("Event handler initialized")
    
    @event_bus.event("app.startup")
    def on_startup(self, event: Event):
        self.logger.info("Application startup event")
        self.logger.debug(f"Event data: {event.data}")
```

## Log Format

Default log format:

```
[LEVEL] logger_name: message
```

Example output:

```
[INFO] app.core.util.components_loader: Component loading completed
[WARNING] app.core.handler.message_handler: Unknown command: unknown
[ERROR] app.core.handler.title_bar_handler: Failed to toggle window state: name 'byref' is not defined
```

## Custom Log Configuration

### Change Log Level

Modify the log level in `main.py`:

```python
# Use DEBUG level for development
setup_logger("app", level="DEBUG")

# Use INFO level for production
setup_logger("app", level="INFO")
```

### Custom Log Format

```python
custom_format = "[%(asctime)s] [%(levelname)s] %(name)s:%(lineno)d - %(message)s"
logger = setup_logger("app", level="INFO", log_format=custom_format)
```

## Best Practices

1. **Choose appropriate log levels**
   - Use `DEBUG` for detailed debug information
   - Use `INFO` for important business processes
   - Use `WARNING` for recoverable exceptions
   - Use `ERROR` for errors that need attention
   - Use `CRITICAL` for errors that prevent the program from continuing

2. **Use LogMixin in components**
   - Inherit from `LogMixin` to automatically get the `logger` property
   - Logger name automatically uses the class name for easy tracking

3. **Log key operations**
   - Component initialization and destruction
   - Command execution and results
   - Exceptions and errors
   - Important state changes

4. **Avoid excessive logging**
   - Don't log extensively in loops
   - Don't log sensitive information (passwords, keys)
   - Use `DEBUG` level for detailed debug information

5. **Use structured logging**
   - Log messages should be clear and concise
   - Include sufficient context information
   - Use consistent formatting

## Common Questions

### Q: How do I view logs?

A: Logs are output to the console (stdout) by default. In the development environment, you can view log output directly in the terminal.

### Q: How do I write logs to a file?

A: The current version of the logging system only outputs to the console. To write to a file, you can modify `logger.py` to add a `FileHandler`.

### Q: How do I distinguish logs from different components?

A: Use different logger names. For example:
```python
logger1 = get_logger("component_a")
logger2 = get_logger("component_b")
```

### Q: How do I reduce log output in production?

A: Set the log level to `INFO` or `WARNING`:
```python
setup_logger("app", level="WARNING")
```

## Related Files

- `app/core/util/logger.py` - Logging module implementation
- `main.py` - Application entry point, logger initialization
- `app/components/` - Log usage examples for various components
