# See your Cost - Expense Visualization Tool

#### 🌐 Switch to | [🇺🇸 English](./README.md) | [🇨🇳 简体中文](./README.CN.md) | [🇯🇵 日本語](./README.JA.md) |

[![User Guide](https://img.shields.io/badge/Instructions-Demo)](./instructions) [![Project Structure Design](https://img.shields.io/badge/UML%20Diagrams-orange)](./modeling) [![Testing](https://img.shields.io/badge/Testing%20Report-blue)](./testing)

## 1. Overview

This application is a cross-platform expense visualization tool built with the Qt6 framework (QML / Qt Quick Application). It helps users calculate the time-distributed cost of their expenses (e.g., daily cost) and presents the results through dynamic visual charts.

Compared to traditional expense tracking methods that only record the total cost, this application improves users' perception of large expenses through time-based allocation and data visualization, helping them make more rational financial decisions.

## 2. Tech Stack

- Qt 6 (cross-platform framework)
- QML (UI design)
- C++ (core logic)
- JSON (configuration and data storage)

## 3. User Guide Demo

[▶ Play on Google Drive](https://drive.google.com/file/d/1bbQ_jALd3Z6sv7HKFcPu8w4gb86D6IBE/view?usp=sharing)

## 4. Features (Functional Requirements)

- Support adding and managing up to 5000 expense entries
- Support sorting data (by date / amount)
- Convert daily cost into weekly, monthly, and yearly cost
- Interactive draggable charts for precise data inspection
- Real-time language switching
- Currency switching system
- Light / Dark theme switching
- Compatibility with customized Android systems
- Custom-built DateTimePicker (designed for cross-platform support)

## 5. Non-functional Requirements

### 🚀 Performance

- List rendering based on QListView + QJsonDocument, capable of handling large-scale data
- Currency conversion with precision up to 6 decimal places
- Custom animation system to reduce dependency on native Android animations

### 👤 Usability

- Clear separation of top and bottom navigation bars with card-based layout
- Animations optimized for mobile touch interaction
- Automatic navigation to newly added items with red border feedback
- Input validation with bottom popup notifications
- Support for theme switching
- Automatically calculate font color based on the contrast threshold value
- Dynamic DPI-based responsive layout

### 🧩 Maintainability

This project is designed with low coupling and high cohesion:

- Separation of UI and logic: QML handles UI, C++ handles backend logic, connected via signal-slot mechanism
- Isolated navigation mechanism (edit mode / setting mode)
- Highly modular UI structure (Main → Page → Components)
- Functional separation (calculation, currency, graph, items, language, sorting)
- Independent JSON configuration files

### 🔒 Reliability

- Multi-layer input validation for add/edit dialogs
- Boundary testing for edge cases
- Android 12+ sandbox ensures data isolation and security
- Custom-built components (e.g., DateTimePicker) for better decoupling and future extensibility

## 6. Project Structure Design (Modeling)

Recommended to open with [draw.io](https://www.drawio.com/)

- [Class Diagram](./modeling/class_diagram.xml) [[Preview]](./modeling/preview/class_diagram.drawio.png)
- [Use Case Diagram](./modeling/use_case_diagram.xml) [[Preview]](./modeling/preview/use_case_diagram.drawio.png)
- [Sequence Diagram](./modeling/sequence_diagram.xml) [[Preview]](./modeling/preview/sequence_diagram.drawio.png)
- [State Chart](./modeling/state_chart.xml) [[Preview]](./modeling/preview/state_chart.drawio.png)

## 7. Testing

This project has been tested through:

- ✅ Input validation testing (amount / date / text)
- ✅ Boundary testing (edge cases)
- ✅ Black-box testing (distributed to users)
- ✅ Multi-device testing (different resolutions / DPI)

## 8. Deployment & Development

### Minimum Build Environment

- Qt 6.10.1
- Android arm64-v8a
- Android SDK 19.0
- CMake 3.30
- Clang NDK 27.2

### Development Platform

- Recommended: Qt Creator
- Alternative: VSCode with Qt extension
- Deployment target: Android real device (recommended)

📘 [View Installation Guide](./instructions/installation.md)

## 9. Future Plans

- Integrate real-time exchange rate API (replace static rates)
- Support more currencies and languages
- Release desktop versions (Windows / macOS)
