# N.A.P. (Nina Alert Application)

A Flutter application that monitors MQTT messages for specific alerts and displays them in a user interface. The app includes background service capabilities and audio notifications.

## Key Features

- 🔔 MQTT message monitoring
- 🔄 Background service support
- ⚡ Real-time alerts display
- 🔊 Audio notifications
- ⚙️ Configurable settings
- 📱 Cross-platform support (iOS and Android)

## Architecture

### Main Components

#### 1. Main App (`lib/main.dart`)
The main application consists of two primary views managed through a TabController:
- Errors Tab: Displays alerts and notifications
- Configuration Tab: Contains MQTT connection settings

Key classes:
- `MyApp`: Root widget
- `MyItem`: Configuration item model
- `Error`: Alert/error model
- `_MyAppState`: Main app state management

#### 2. Background Service (`lib/background.dart`)
Handles MQTT connections and message processing in the background:
- MQTT client initialization
- Message subscription and processing
- Audio alert management
- Communication with main UI

## Configuration Settings

The app allows configuration of:
1. IP Address (default: test.mosquitto.org)
2. Port (default: 1883)
3. Topic (default: test)
4. Tags (comma-separated values for alert filtering)

## Data Flow

```mermaid
graph LR