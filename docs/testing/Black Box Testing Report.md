# Black Box Testing Report

## Project: See your Cost

## Platform: Android (Multiple Devices and Android Systems)

## Overview

This report summarizes user-reported issues and externally observable behavior discovered during black box testing. Testing includes application functionality, localization behavior, navigation consistency, and cross-device compatibility without referencing internal source code implementation. The test cases listed in this report represent only selected typical examples rather than a complete issue log. Most issues identified in **v0.30 beta** were addressed in later updates. For detailed version history and fixes, please refer to the [release page](https://github.com/Turtle233/expense_visualization_tool/releases).

## Summary Table

| Test Case   | Category             | Status                                             |
| ----------- | -------------------- | -------------------------------------------------- |
| Test Case 1 | Settings Persistence | Failed (Passed on v0.31 beta)                      |
| Test Case 2 | Localization         | Failed (Passed on v0.32 beta)                      |
| Test Case 3 | Navigation Behavior  | Failed - Qt Framework Limitation                   |
| Test Case 4 | Device Compatibility | Partial Pass - Device-Specific Compatibility Issue |

## Test Case 1 – Settings Persistence After Restart

### Objective

Verify whether user-selected language and currency settings remain saved after closing and relaunching the application.

### Test Steps

1. Launch the application.
2. Change language setting from default English to another language.
3. Change currency setting from default USD to another currency.
4. Fully close the application.
5. Reopen the application.

### Expected Result

Previously selected language and currency settings should remain applied after restart.

### Actual Result

Users reported that the application reverted to the default configuration (USD and English) upon the next launch.

### Status

Failed (Passed on v0.31 beta)

## Test Case 2 – Localization of System Dialog Buttons

### Objective

Verify whether system dialog buttons follow the currently selected application language.

### Test Steps

1. Launch the application.
2. Change the language setting to a non-English language.
3. Open the Add Item dialog.
4. Open the Edit Item dialog.
5. Observe button text labels.

### Expected Result

The “Cancel” and “Save” buttons should display translated text according to the selected language.

### Actual Result

Users reported that in the system dialogs for adding and editing items, the “Cancel” and “Save” buttons did not follow the selected language translation.

### Status

Failed (Passed on v0.32 beta)

## Test Case 3 – Android Back Action Navigation Behavior

### Objective

Verify whether the Android back action behaves consistently with expected in-app page navigation.

### Test Steps

1. Launch the application.
2. Navigate from the home screen to a secondary page.
3. Trigger the Android back action using the device back gesture or back button.

### Expected Result

The application should return to the previous in-app page.

### Actual Result

On secondary pages, triggering the Android back action would exit directly to the home screen instead of navigating back within the app; users could only return via the top-left back button.

### Notes

This behavior appears related to a limitation of Qt’s cross-platform behavior, which does not fully follow native Android back handling.

### Status

Failed - Qt Framework Limitation

## Test Case 4 – Cross-Device UI Compatibility Testing

### Objective

Verify consistent user interface behavior across multiple Android devices and customized vendor operating systems.

### Test Steps

1. Install and run the application on multiple Android devices.
2. Test scrolling behavior, font rendering, and general UI consistency.
3. Compare behavior across different manufacturers and operating systems.

### Expected Result

Scrollbar behavior, font weight, and visual appearance should remain consistent across devices.

### Actual Result

Testing across multiple devices and customized Android systems revealed that some vendors modify scrollbar and font APIs.

Examples:

- Certain systems enforce heavier font weights (e.g., HyperOS overriding default fonts).
- Others prevent scrollbars from being hidden (e.g., ColorOS forcing scrollbar visibility despite internal overrides).

### Status

Partial Pass - Device-Specific Compatibility Issue

## Conclusion

This black box testing report focused specifically on **v0.30 beta** and documented representative issues observed from an end-user perspective during functional and compatibility testing. The listed test cases are typical examples only and do not represent every test scenario performed.

Results showed that the primary issues in v0.30 beta involved settings persistence, localization consistency, Android navigation behavior, and vendor-specific UI rendering differences. Most problems identified in this version were resolved through subsequent updates and refinements.

For complete patch notes, release progress, and later fixes, please refer to the [release page](https://github.com/Turtle233/expense_visualization_tool/releases).
