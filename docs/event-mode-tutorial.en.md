# Event Mode Tutorial

[中文](index.md)|[English](index.en.md)

## Tutorials

- [Component Tutorial](component-tutorial.en.md) | [组件开发教程](component-tutorial.md)
- [Multiprocessing Tutorial](multiprocessing-tutorial.en.md) | [多进程教程](multiprocessing-tutorial.md)
- [Event Mode Tutorial](event-mode-tutorial.en.md) | [事件模式教程](event-mode-tutorial.md)
- [Logging Tutorial](logging-tutorial.en.md) | [日志使用](logging-tutorial.md)

This tutorial introduces the **Event Mode** in Cellium, which is a communication approach based on the Publish-Subscribe pattern. Unlike Command Mode, Event Mode enables more flexible decoupled communication between components.

> **"In Cellium, events are a more flexible way to connect—you only need to focus on 'what happened', while the event bus handles propagation, routing, and responses."**

## 1. Event Mode Overview

The core concept of Event Mode is that **Publishers** and **Subscribers** do not need to reference each other directly, but instead communicate through an **Event Bus**. When a publisher triggers an event, all handlers subscribed to that event will receive the notification and execute.

The advantages of this pattern include:
- **Loose Coupling**: Publishers and subscribers do not know about each other
- **Multicast Support**: One event can be subscribed to by multiple handlers simultaneously
- **Dynamic Management**: Event subscriptions can be dynamically added or removed at runtime
- **Broadcast Communication**: One event can trigger multiple different response actions

Event Mode is particularly suitable for the following scenarios:
- Scenarios where one action needs to trigger multiple responses
- Scenarios where components need to communicate across different levels
- Scenarios requiring plugin-based architectures
- Scenarios requiring runtime dynamic extension capabilities

## 2. Event Bus Basics

Cellium provides a global Event Bus, exported through the `app.core.bus` module. To use Event Mode, you first need to import the relevant APIs:

```python
from app.core.bus import event_bus, on, emit, EventBus
```

### 2.1 Event Bus Object

The Event Bus is the core of the entire Event Mode, responsible for managing event registration, triggering, and dispatching. The following are the main functions of the Event Bus:

```python
from app.core.bus import event_bus

# Use the global Event Bus directly
event_bus.on("user.login", user_login_handler)
event_bus.emit("user.login", {"username": "admin"})
```

### 2.2 Event Types

Cellium uses strings to identify event types, rather than enums. This design provides greater flexibility and supports dynamic event names and pattern matching:

```python
# Static event names
"user.login"

# Namespaced event names
"user.login"
"user.logout"
"admin.created"

# Pattern-matched event names
"user.*"
"*.login"
"user.#.created"
```

### 2.3 Event Data

Events can carry arbitrary data, passed through keyword arguments:

```python
# Pass data when triggering an event
event_bus.emit("user.login", username="admin", role="administrator", login_time="2024-01-01")

# Handler receives data
@on("user.login")
def handle_user_login(**kwargs):
    print(f"User {kwargs.get('username')} has logged in")
```

## 3. Static Event Subscription

Static event subscription is the most basic form of event subscription, using the `@on()` or `@event()` decorator to mark handler functions.

### 3.1 Using the @on Decorator

The `@on()` decorator is the simplest event subscription method, accepting an event name as a parameter:

```python
from app.core.bus import on

@on("user.login")
def handle_user_login(**kwargs):
    """User login event handler"""
    username = kwargs.get("username", "Unknown User")
    print(f"User {username} has logged in")
    print(f"Login time: {kwargs.get('login_time', 'Unknown')}")

# Can also be written this way (same effect)
@on("user.logout")
def handle_user_logout(**kwargs):
    """User logout event handler"""
    username = kwargs.get("username", "Unknown User")
    print(f"User {username} has logged out")
```

### 3.2 Using the @event Decorator

The `@event()` decorator is an alias for the `@on()` decorator, providing the same functionality but semantically emphasizing that this is an event handler:

```python
from app.core.bus import event

@event("order.created")
def handle_order_created(**kwargs):
    """Order created event handler"""
    order_id = kwargs.get("order_id")
    amount = kwargs.get("amount")
    print(f"New order created: Order ID={order_id}, Amount={amount}")
```

### 3.3 Registering Handlers

Handlers decorated with `@on()` or `@event()` are automatically registered with the Event Bus. Sometimes you need to register manually, and the Event Bus also provides a `register()` method:

```python
from app.core.bus import event_bus

def custom_handler(**kwargs):
    """Manually registered event handler"""
    print(f"Received event data: {kwargs}")

# Manual registration
event_bus.register("custom.event", custom_handler)

# Or use chained calls
event_bus.register("event.a", handler_a).register("event.b", handler_b)
```

### 3.4 Handler Registration Order

Event handlers execute in registration order. If you need to control the execution order, you can use the **priority** parameter:

```python
from app.core.bus import on, EventPriority

@on("user.login", priority=EventPriority.HIGH)
def high_priority_handler(**kwargs):
    """High priority handler, executes first"""
    print("1. High priority handler")

@on("user.login", priority=EventPriority.NORMAL)
def normal_priority_handler(**kwargs):
    """Normal priority handler"""
    print("2. Normal priority handler")

@on("user.login", priority=EventPriority.LOW)
def low_priority_handler(**kwargs):
    """Low priority handler, executes last"""
    print("3. Low priority handler")
```

**Execution Result**:
```
1. High priority handler
2. Normal priority handler
3. Low priority handler
```

## 4. One-Time Event Subscription

Sometimes you only need to listen to an event once, and the handler should not be called after the event triggers. The `@once()` or `@event_once()` decorator can achieve this.

### 4.1 Using the @once Decorator

```python
from app.core.bus import once

@once("app.startup")
def handle_app_startup(**kwargs):
    """App startup event, executes only once"""
    print("App startup initialization")
    # Perform one-time initialization operations

@once("config.loaded")
def handle_config_loaded(**kwargs):
    """Config loaded event, executes only once"""
    print(f"Config loaded: {kwargs.get('config_data')}")
```

### 4.2 Using the @event_once Decorator

`@event_once()` is an alias for `@once()`, with identical functionality:

```python
from app.core.bus import event_once

@event_once("message.received")
def handle_first_message(**kwargs):
    """Process only the first message"""
    print(f"Received first message: {kwargs.get('message')}")
```

### 4.3 One-Time Event Use Cases

One-time events are suitable for the following scenarios:

```python
from app.core.bus import once, emit

@once("database.connected")
def initialize_database(**kwargs):
    """Initialize database tables after connection"""
    print("Initializing database tables...")

@once("user.first_login")
def show_welcome(**kwargs):
    """Show welcome screen on user's first login"""
    print(f"Welcome {kwargs.get('username')} on your first login!")

# Trigger events
emit("database.connected", driver="mysql", host="localhost")
emit("user.first_login", username="new_user")
```

**Execution Result**:
```
Initializing database tables...
Welcome new_user on your first login!
```

If these events are triggered again, the handlers will not be called.

## 5. Pattern Matching Subscription

Pattern matching allows you to use wildcards to subscribe to a category of events, rather than a single specific event. This is very useful when you need to listen to multiple related events.

### 5.1 Using the @pattern Decorator

The `@pattern()` decorator supports various wildcard patterns:

| Wildcard | Meaning | Example |
|----------|---------|---------|
| `*` | Matches a single word | `user.*` matches `user.login`, `user.logout` |
| `#` | Matches multiple words (zero or more) | `order.#.created` matches `order.created`, `order.item.created` |
| `?` | Matches a single character | `user.?` matches `user.a`, `user.1` |

```python
from app.core.bus import pattern

@pattern("user.*")
def handle_user_events(**kwargs):
    """Handle all user-related events"""
    event_name = kwargs.get("_event_name")
    print(f"Received user event: {event_name}")
    print(f"Event data: {kwargs}")

@pattern("order.#.created")
def handle_order_created_events(**kwargs):
    """Handle all order creation events"""
    event_name = kwargs.get("_event_name")
    print(f"Received order creation event: {event_name}")
```

### 5.2 Pattern Matching Examples

```python
from app.core.bus import pattern, emit

@pattern("notification.*")
def handle_notifications(**kwargs):
    """Handle all notification events"""
    event_name = kwargs.get("_event_name")
    notification_type = event_name.split(".")[1]
    print(f"Notification type: {notification_type}")
    print(f"Message: {kwargs.get('message')}")

# Trigger various notification events
emit("notification.email", message="You have a new email")
emit("notification.sms", message="Your verification code is 123456")
emit("notification.push", message="Someone liked your post")
```

**Execution Result**:
```
Notification type: email
Message: You have a new email
Notification type: sms
Message: Your verification code is 123456
Notification type: push
Message: Someone liked your post
```

### 5.3 Complex Pattern Matching

```python
from app.core.bus import pattern, emit

@pattern("system.#.error")
def handle_system_errors(**kwargs):
    """Handle all system error events"""
    event_name = kwargs.get("_event_name")
    error_code = kwargs.get("error_code")
    error_msg = kwargs.get("error_message")
    print(f"System error [{event_name}]: Code={error_code}, Message={error_msg}")

# Trigger system error events at different levels
emit("system.disk.error", error_code=1001, error_message="Disk space insufficient")
emit("system.network.error", error_code=2001, error_message="Network connection failed")
emit("system.error", error_code=0001, error_message="Unknown error")
```

**Execution Result**:
```
System error [system.disk.error]: Code=1001, Message=Disk space insufficient
System error [system.network.error]: Code=2001, Message=Network connection failed
System error [system.error]: Code=0001, Message=Unknown error
```

## 6. Wildcard Subscription

Wildcard subscription can listen to all events, which is very useful for implementing logging, debugging, or global event handling.

### 6.1 Using the @wildcard Decorator

The `@wildcard()` decorator subscribes to all events, regardless of the event name:

```python
from app.core.bus import wildcard

@wildcard()
def log_all_events(**kwargs):
    """Log all events"""
    event_name = kwargs.get("_event_name")
    event_data = {k: v for k, v in kwargs.items() if k != "_event_name"}
    print(f"[Event Log] {event_name}: {event_data}")
```

### 6.2 Wildcard and Priority

Wildcard handlers can also set priority:

```python
from app.core.bus import wildcard, on, EventPriority

@wildcard(priority=EventPriority.LOW)
def event_logger(**kwargs):
    """Event logging (low priority, executes last)"""
    event_name = kwargs.get("_event_name")
    print(f"[Log] Event {event_name} processed")

@on("user.login", priority=EventPriority.HIGH)
def user_login_high_priority(**kwargs):
    """User login handler (high priority)"""
    print(f"[High Priority] User login: {kwargs.get('username')}")
```

### 6.3 Wildcard Practical Applications

```python
from app.core.bus import wildcard, on, emit, EventPriority

@wildcard(priority=EventPriority.LOW)
def debug_all_events(**kwargs):
    """Log all events in debug mode"""
    event_name = kwargs.get("_event_name")
    print(f"[Debug] Event: {event_name}")

@on("data.updated")
def handle_data_updated(**kwargs):
    """Data update event"""
    print(f"[Business] Data updated: {kwargs.get('data_id')}")

@on("view.opened")
def handle_view_opened(**kwargs):
    """View opened event"""
    print(f"[Business] View opened: {kwargs.get('view_name')}")

# Trigger events
emit("data.updated", data_id="12345")
emit("view.opened", view_name="settings")
```

**Execution Result**:
```
[Business] Data updated: 12345
[Debug] Event: data.updated
[Business] View opened: settings
[Debug] Event: view.opened
```

## 7. Publishing Events

Publishing events uses the `emit()` function or the `@emitter()` decorator.

### 7.1 Using the emit Function

```python
from app.core.bus import emit

# Trigger simple events
emit("user.login", username="admin", role="administrator")

# Trigger events with complex data
emit("order.created",
     order_id="ORD-2024-001",
     items=[
         {"product_id": "P001", "quantity": 2, "price": 99.00},
         {"product_id": "P002", "quantity": 1, "price": 199.00}
     ],
     total_amount=397.00,
     customer_id="C001")
```

### 7.2 Using the @emitter Decorator

The `@emitter()` decorator can convert class methods into event publishers. When the method is called, it automatically triggers the corresponding event:

```python
from app.core.bus import emitter

class UserManager:
    """User Manager"""
    
    def __init__(self):
        self.users = {}
    
    @emitter("user.login")
    def login(self, username: str, password: str) -> bool:
        """User login, triggers event on success"""
        if self.authenticate(username, password):
            self.users[username] = {"login_time": "2024-01-01"}
            return True
        return False
    
    @emitter("user.logout")
    def logout(self, username: str):
        """User logout, triggers event"""
        if username in self.users:
            del self.users[username]
    
    def authenticate(self, username: str, password: str) -> bool:
        """Simple authentication logic"""
        return password == "123456"

# Usage
user_manager = UserManager()

@on("user.login")
def handle_login(**kwargs):
    print(f"User {kwargs.get('username')} logged in successfully")

user_manager.login("admin", "123456")  # Automatically triggers "user.login" event
```

### 7.3 Publishing Namespaced Events

```python
from app.core.bus import emit

# Use namespaces to avoid conflicts
emit("shop.order.created", order_id="ORD-001", amount=100.0)
emit("shop.order.cancelled", order_id="ORD-001", reason="User cancelled")

emit("admin.order.approved", order_id="ORD-001", approver="admin")
```

### 7.4 Conditional Event Publishing

You can make conditional checks before publishing events:

```python
from app.core.bus import emit, on

@on("order.status_changed")
def handle_status_change(**kwargs):
    print(f"Order status changed: {kwargs.get('order_id')} -> {kwargs.get('new_status')}")

class OrderService:
    def update_status(self, order_id: str, new_status: str, old_status: str):
        """Update order status, publish event when conditions are met"""
        # Only publish event when status actually changes
        if new_status != old_status:
            emit("order.status_changed",
                 order_id=order_id,
                 old_status=old_status,
                 new_status=new_status,
                 timestamp="2024-01-01 12:00:00")
```

## 8. Namespace Support

Namespaces are an important mechanism for preventing event name conflicts. Using prefixes (namespaces) can categorize and manage events.

### 8.1 Namespace Naming Conventions

It is recommended to use the following naming conventions:
- Lowercase letters
- Use dots to separate levels
- Include module or feature names

```python
# User-related events
"user.login"
"user.logout"
"user.register"
"user.profile.updated"

# Order-related events
"order.created"
"order.paid"
"order.shipped"
"order.delivered"

# System-related events
"system.startup"
"system.shutdown"
"system.error"
"system.config_changed"
```

### 8.2 Using Namespaces in Components

```python
from app.core.bus import on, emit, event

class NotificationService:
    """Notification Service Component"""
    
    @event("notification.email")
    def send_email(self, to: str, subject: str, body: str):
        """Send email notification"""
        print(f"Sending email to {to}: {subject}")
        return True
    
    @event("notification.sms")
    def send_sms(self, phone: str, message: str):
        """Send SMS notification"""
        print(f"Sending SMS to {phone}: {message}")
        return True

# Subscribe to events in a specific namespace
@on("notification.*")
def handle_notification(**kwargs):
    notification_type = kwargs.get("_event_name").split(".")[1]
    print(f"Received {notification_type} notification request")
```

### 8.3 Avoiding Name Conflicts

When multiple components handle the same type of event, namespaces can effectively avoid conflicts:

```python
from app.core.bus import on, emit

# Plugin A handles user login
@on("pluginA.user.login")
def plugin_a_handle_login(**kwargs):
    print("[PluginA] User login handling")

# Plugin B handles user login
@on("pluginB.user.login")
def plugin_b_handle_login(**kwargs):
    print("[PluginB] User login handling")

# Trigger events for both plugins
emit("pluginA.user.login", username="user1")
emit("pluginB.user.login", username="user2")
```

**Execution Result**:
```
[PluginA] User login handling
[PluginB] User login handling
```

## 9. Priority Control

Event handlers can be set with different priorities to ensure important event handlers execute first.

### 9.1 Priority Levels

Cellium predefines three priority levels:

| Level | Constant | Description |
|-------|----------|-------------|
| High | `EventPriority.HIGH` | Highest priority, executes first |
| Normal | `EventPriority.NORMAL` | Default priority |
| Low | `EventPriority.LOW` | Lowest priority, executes last |

```python
from app.core.bus import on, EventPriority

@on("app.startup", priority=EventPriority.HIGH)
def early_initialization(**kwargs):
    """Early initialization, high priority"""
    print("1. Early initialization")

@on("app.startup", priority=EventPriority.NORMAL)
def normal_initialization(**kwargs):
    """Normal initialization"""
    print("2. Normal initialization")

@on("app.startup", priority=EventPriority.LOW)
def late_initialization(**kwargs):
    """Late initialization, low priority"""
    print("3. Late initialization")
```

### 9.2 Custom Priority Values

If the predefined priority levels are not enough, you can use numeric values for customization:

```python
from app.core.bus import on, EventPriority

@on("data.process", priority=100)
def first_processor(**kwargs):
    """First handler"""
    print("Processing step 1")

@on("data.process", priority=50)
def second_processor(**kwargs):
    """Second handler"""
    print("Processing step 2")

@on("data.process", priority=0)
def third_processor(**kwargs):
    """Third handler"""
    print("Processing step 3")
```

Higher values mean higher priority.

### 9.3 Priority Use Cases

```python
from app.core.bus import on, emit, EventPriority

@on("request.received", priority=EventPriority.HIGH)
def request_validator(**kwargs):
    """Request validation, high priority"""
    print("[Validation] Checking request parameters")
    # Can prevent subsequent processing if validation fails

@on("request.received", priority=EventPriority.NORMAL)
def request_handler(**kwargs):
    """Request handling"""
    print("[Handling] Processing request")

@on("request.received", priority=EventPriority.LOW)
def request_logger(**kwargs):
    """Request logging, low priority"""
    print("[Logging] Recording request")

emit("request.received", path="/api/users", method="GET")
```

**Execution Result**:
```
[Validation] Checking request parameters
[Handling] Processing request
[Logging] Recording request
```

## 10. Complete Example

The following is a comprehensive example that uses various Event Mode features:

```python
from app.core.bus import (
    on, once, pattern, wildcard, emitter,
    emit, event_bus, EventPriority
)

# ==================== Event Subscriptions ====================

# Normal event subscription
@on("order.created", priority=EventPriority.HIGH)
def handle_order_created(**kwargs):
    """Order creation handling"""
    order_id = kwargs.get("order_id")
    amount = kwargs.get("amount")
    print(f"[Order] New order created: #{order_id}, Amount: ${amount:.2f}")


@on("order.created", priority=EventPriority.NORMAL)
def handle_order_notify(**kwargs):
    """Send notification after order creation"""
    order_id = kwargs.get("order_id")
    print(f"[Notification] Order #{order_id} created, sending confirmation email")


# One-time event subscription
@once("app.first_start")
def first_start_handler(**kwargs):
    """App first start handling"""
    print(f"[Startup] First start, executing initial configuration...")


# Pattern matching subscription
@pattern("order.#.status")
def handle_order_status_change(**kwargs):
    """Handle order status change events"""
    event_name = kwargs.get("_event_name")
    order_id = kwargs.get("order_id")
    status = event_name.split(".")[-1]
    print(f"[Order] Order #{order_id} status changed to: {status}")


# Wildcard subscription
@wildcard(priority=EventPriority.LOW)
def event_logger(**kwargs):
    """Log all events"""
    event_name = kwargs.get("_event_name")
    print(f"[Log] Event {event_name}")


# ==================== Event Publishing Class ====================

class OrderService:
    """Order Service"""
    
    def __init__(self):
        self.orders = {}
        self.order_counter = 0
    
    @emitter("order.created")
    def create_order(self, amount: float, customer: str):
        """Create order"""
        self.order_counter += 1
        order_id = f"ORD-{self.order_counter:04d}"
        self.orders[order_id] = {
            "customer": customer,
            "amount": amount,
            "status": "created"
        }
        print(f"[Service] Created order {order_id}")
        return order_id
    
    @emitter("order.paid")
    def pay_order(self, order_id: str):
        """Pay order"""
        if order_id in self.orders:
            self.orders[order_id]["status"] = "paid"
            print(f"[Service] Order {order_id} paid")
            return True
        return False
    
    @emitter("order.shipped")
    def ship_order(self, order_id: str):
        """Ship order"""
        if order_id in self.orders:
            self.orders[order_id]["status"] = "shipped"
            print(f"[Service] Order {order_id} shipped")
            return True
        return False


# ==================== Execution Example ====================

if __name__ == "__main__":
    # Trigger one-time event
    emit("app.first_start")
    
    # Create order service
    order_service = OrderService()
    
    # Create order (will trigger order.created event)
    order_id = order_service.create_order(299.00, "John Doe")
    
    # Pay order (will trigger order.paid event)
    order_service.pay_order(order_id)
    
    # Ship order (will trigger order.shipped event)
    order_service.ship_order(order_id)
```

**Execution Result**:
```
[Startup] First start, executing initial configuration...
[Order] New order created: #ORD-0001, Amount: $299.00
[Notification] Order #ORD-0001 created, sending confirmation email
[Service] Created order ORD-0001
[Log] Event app.first_start
[Log] Event order.created
[Service] Order ORD-0001 paid
[Order] Order #ORD-0001 status changed to: paid
[Log] Event order.paid
[Service] Order ORD-0001 shipped
[Order] Order #ORD-0001 status changed to: shipped
[Log] Event order.shipped
```

## 11. Comparison with Command Mode

Event Mode and Command Mode are the two main communication methods in Cellium, each with its own characteristics and applicable scenarios.

### 11.1 Mode Comparison Table

| Feature | Command Mode | Event Mode |
|---------|--------------|------------|
| **Communication** | Frontend ↔ Backend Component | Backend Internal Only |
| **Coupling** | Caller and handler coupled | Publisher and subscriber decoupled |
| **Execution Timing** | Synchronous call, executes immediately | Asynchronous trigger, delayed execution |
| **Return Value** | Has return value | Usually no return value |
| **Use Case** | RPC calls, method execution | Decoupled communication (Backend), broadcast notifications |
| **Flexibility** | Static call relationships | Dynamic subscription relationships |
| **Error Handling** | Throws exceptions directly | Propagates errors through error events |

> ⚠️ **Important**: The event system is for **internal backend use only**. Frontend cannot directly publish events to the event bus. For frontend ↔ backend communication:
> - Frontend → Backend: use `mbQuery('cell:command:args')`
> - Backend → Frontend: use `run_js('JS code')`

### 11.2 When to Use Command Mode

Command Mode is suitable for the following scenarios:

```python
# Need to get results immediately
class Calculator(ICell):
    @property
    def cell_name(self) -> str:
        return "calculator"
    
    def execute(self, command: str, *args, **kwargs):
        if command == "add":
            a = kwargs.get("a", 0)
            b = kwargs.get("b", 0)
            return a + b  # Return result immediately
```

### 11.3 When to Use Event Mode

Event Mode is suitable for the following scenarios:

```python
# Need to trigger multiple responses
from app.core.bus import on, emit

@on("user.registered")
def send_welcome_email(**kwargs):
    print(f"Sending welcome email to {kwargs.get('email')}")

@on("user.registered")
def initialize_user_data(**kwargs):
    print(f"Initializing user data: {kwargs.get('user_id')}")

@on("user.registered")
def log_registration(**kwargs):
    print(f"Logging registration: {kwargs.get('user_id')}")

# One event triggers multiple handlers
emit("user.registered", user_id="U001", email="user@example.com")
```

### 11.4 Mixed Usage

In practice, both modes can be used together:

```python
from app.core.bus import on, emitter, emit
from app.core.interface import ICell

class UserService(ICell):
    """User Service, supporting both Command Mode and Event Mode"""
    
    @property
    def cell_name(self) -> str:
        return "user_service"
    
    def execute(self, command: str, *args, **kwargs):
        """Command Mode: direct method calls"""
        method_name = f"_cmd_{command}"
        if hasattr(self, method_name):
            method = getattr(self, method_name)
            return method(*args, **kwargs)
        return f"Unknown command: {command}"
    
    def _cmd_get_user(self, user_id: str):
        """Get user info"""
        return {"user_id": user_id, "name": "John Doe"}
    
    @emitter("user.created")
    def create_user(self, username: str, email: str):
        """Create user, trigger event"""
        user_id = f"U{len(username)}"
        print(f"Creating user: {username}")
        return user_id
    
    @emitter("user.deleted")
    def delete_user(self, user_id: str):
        """Delete user, trigger event"""
        print(f"Deleting user: {user_id}")
        return True


# Command Mode call
service = UserService()
user_info = service.execute("get_user", user_id="U001")

# Event Mode subscription
@on("user.created")
def handle_user_created(**kwargs):
    print(f"New user created: {kwargs}")


# Mixed calls
user_id = service.create_user("Jane", "jane@example.com")
emit("user.created", user_id=user_id, username="Jane", email="jane@example.com")
```

## 12. Best Practices

### 12.1 Event Naming Conventions

Use clear, meaningful names:
```python
# ✅ Good naming
"user.login"
"order.created"
"notification.email.sent"

# ❌ Avoid
"event1"
"something_happened"
"u.l"
```

### 12.2 Handler Naming

Use descriptive function names for event handlers:
```python
# ✅ Good naming
@on("user.login")
def handle_user_login(**kwargs):
    pass

@on("order.created")
def process_new_order(**kwargs):
    pass

# ❌ Avoid
@on("user.login")
def handler(**kwargs):
    pass

@on("order.created")
def func1(**kwargs):
    pass
```

### 12.3 Error Handling

Add appropriate error handling in event handlers:
```python
from app.core.bus import on

@on("data.process")
def process_data(**kwargs):
    try:
        data_id = kwargs.get("data_id")
        # Data processing logic
        result = heavy_processing(data_id)
        return result
    except Exception as e:
        print(f"Data processing failed: {e}")
        # Can choose to trigger error event
        emit("data.process.error", data_id=data_id, error=str(e))
```

### 12.4 Performance Considerations

For high-frequency events, pay attention to performance:
```python
from app.core.bus import on

# Use lightweight handlers for high-frequency events
@on("heartbeat")
def heartbeat_handler(**kwargs):
    # Only perform minimal processing
    pass

# Avoid time-consuming operations in handlers
@on("user.action")
def user_action_handler(**kwargs):
    # ❌ Avoid: time-consuming operations
    # time.sleep(1)
    # heavy_computation()
    
    # ✅ Recommended: move time-consuming operations to background tasks
    # asyncio.create_task(heavy_task())
    pass
```

### 12.5 Memory Management

Properly manage event subscriptions to avoid memory leaks:
```python
from app.core.bus import event_bus, on

# Short-term subscriptions use once
@once("session.started")
def session_handler(**kwargs):
    pass

# Manually manage long-term subscriptions
subscription = event_bus.on("cache.invalidated", cache_handler)

# Unsubscribe when no longer needed
subscription.unsubscribe()

# Or use context manager
with event_bus.on("temp.event", temp_handler) as subscription:
    # Use subscription
    pass
```

## 13. Summary

Event Mode is a powerful communication mechanism in Cellium that provides:

- **Flexible Publish-Subscribe Pattern**: Supports one-to-many communication
- **Multiple Subscription Methods**: Static, one-time, pattern matching, wildcard
- **Namespace Support**: Effectively organize and categorize events
- **Priority Control**: Precisely control handler execution order
- **Decoupled Design**: Publishers and subscribers are independent

Through this tutorial, you should have mastered the core concepts and practical application techniques of Event Mode. It is recommended to compare with the Command Mode in the [Component Tutorial](component-tutorial.en.md) to learn the characteristics and applicable scenarios of both communication methods, so you can make the right choices in actual development.
