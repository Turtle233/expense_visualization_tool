# See your Cost (支出を洞察) - 支出可視化ツール

#### 🌐切り替えて | [🇺🇸 English](./README.md) | [🇨🇳 简体中文](./README.CN.md) | [🇯🇵 日本語](./README.JA.md) |

[![User Guide](https://img.shields.io/badge/User%20Guide%20Demo-Demo)](./instructions) [![Project Structure Design](https://img.shields.io/badge/UML%20Diagrams-orange)](./modeling) [![Testing](https://img.shields.io/badge/Testing%20Report-blue)](./testing)

## 1. 概要

本アプリは、Qt6（QML / Qt Quick Application）フレームワークを用いて開発されたクロスプラットフォームの支出可視化ツールです。ユーザーの支出を時間単位（1日あたりのコストなど）で計算し、動的なグラフとして可視化します。

従来の「総額のみ」を記録する家計管理とは異なり、本アプリは時間分割とデータ可視化を通じて高額支出の認識を高め、より合理的な意思決定を支援します。

## 2. 技術スタック

- Qt 6（クロスプラットフォームフレームワーク）
- QML（UI設計）
- C++（コアロジック）
- JSON（設定およびデータ保存）

## 3. ユーザーデモ

- <デモ動画を後で追加>

## 4. 機能（機能要件）

- 最大5000件の支出データの追加・管理に対応
- データの並び替え（日時 / 金額）
- 日次コストを週次・月次・年次へ変換
- ドラッグ操作可能なインタラクティブグラフ（精密な閲覧）
- リアルタイム言語切替
- 通貨切替機能
- ライト / ダークテーマ切替
- カスタマイズされたAndroidシステムへの対応
- カスタム実装のDateTimePicker（クロスプラットフォーム対応のため）

## 5. 非機能要件

### 🚀 パフォーマンス

- QListView + QJsonDocument に基づくリスト処理により、大規模データに対応
- 小数点以下6桁の通貨計算精度
- カスタムアニメーションによりAndroidネイティブ依存を低減

### 👤 ユーザビリティ

- 上部・下部ナビゲーションの分離とカード型レイアウト
- モバイルタッチ操作に最適化されたアニメーション
- 新規追加時の自動スクロール + 赤枠フィードバック
- 入力エラー時のポップアップ通知
- テーマカラー切替対応
- DPIに基づくレスポンシブレイアウト

### 🧩 保守性

本プロジェクトは低結合・高凝集を目的として設計されています：

- UIとロジックの分離：QML（UI）とC++（ロジック）をSignal-Slotで接続
- ナビゲーションの分離（編集モード / 設定モード）
- 高度にモジュール化されたUI構造（Main → Page → Components）
- 機能ごとの分離（計算、通貨、グラフ、データ、言語、ソート）
- JSONによる設定ファイルの独立管理

### 🔒 信頼性

- 追加・編集時の多層入力検証
- 境界値テストの実施
- Android 12+ のサンドボックスによるデータ保護
- DateTimePickerなどのコンポーネントを独自実装し、拡張性を確保

## 6. プロジェクト構造設計（モデリング）

- [Class Diagram](./modeling/class_diagram.xml)
- [Use Case Diagram](./modeling/use_case_diagram.xml)
- [Sequence Diagram](./modeling/sequence_diagram.xml)
- [State Chart](./modeling/state_chart.xml)

## 7. テスト

本プロジェクトでは以下のテストを実施しています：

- ✅ 入力検証テスト（金額 / 日付 / 文字列）
- ✅ 境界値テスト（極端なケース）
- ✅ ブラックボックステスト（ユーザー配布）
- ✅ 複数デバイステスト（解像度 / DPI）

##1 8. ビルドおよび開発

### 最低要件

- Qt 6.10.1
- Android arm64-v8a
- Android SDK 19.0
- CMake 3.30
- Clang NDK 27.2

### 開発環境

- Qt Creator（推奨）
- または VSCode + Qt拡張
- Android実機でのテストを推奨

## 9. 今後の計画

- リアルタイム為替APIの導入（固定レートの廃止）
- 対応通貨および言語の拡張
- デスクトップ版（Windows / macOS）のリリース
