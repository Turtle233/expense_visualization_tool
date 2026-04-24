# Part 1 Test Validation Points

## Validation Point 1: Item Name Input Validation

- Item name cannot be empty after trimming whitespace.
- MaxLength: 30 characters (reasonable limit for item descriptions).
- Item name must contain only valid characters (no null or invalid Unicode characters).

## Validation Point 2: Expense Amount Validation

- Expense amount must be a positive number greater than 0.
- System must accept currency symbols (e.g., "$" prefix) and remove them during parsing.
- Decimal precision must be supported up to 6 decimal places (per currency requirements).

## Validation Point 3: Purchase Date Validation

- Purchase date must be in valid ISO format (YYYY-MM-DD).
- Date must be valid (not an invalid date like 2025-02-30).
- Purchase date cannot be in the future (totalDays must be > 0 for calculations to work).

# Part 2 Equivalence Classes and Boundary Values

## Constraint 1: Item Name

### Valid EC:

- 1–30 characters, no special control characters

### Invalid EC:

- 0 characters (empty string after trimming)
- 30+ characters (exceeds maximum)
- Contains null or invalid Unicode characters

### Boundary Values:

- space character (invalid - empty)
- 1 character (valid minimum)
- 30 characters (valid maximum)
- 31 characters (invalid - exceeds max)

## Constraint 2: Expense Amount

### Valid EC:

- Positive decimal numbers (> 0.0)
- String format with optional "$" prefix
- Precision: up to 6 decimal places

### Invalid EC:

- Negative numbers or zero (≤ 0.0)
- Non-numeric characters (except "$")
- Non-parseable strings

### Boundary Values:

- -0.01 (invalid - negative)
- 0.00 (invalid - zero or empty)
- 0.01 (valid minimum)
- 999999.999999 (valid maximum)
- 1000000.000000 (should fail if exceeds system limits)

## Constraint 3: Purchase Date

### Valid EC:

- Valid ISO date format (YYYY-MM-DD)
- Date not in the future (currentDate >= purchaseDate)
- Standard calendar date

### Invalid EC:

- Invalid date format (not YYYY-MM-DD)
- Non-existent dates (e.g., 2025-02-30)
- Future dates (currentDate < purchaseDate)
- Empty or malformed date string

### Boundary Values:

- Today's date (valid, totalDays = 0, should be rejected by calculation logic)
- Yesterday's date (valid minimum)
- 50+ years ago (valid extreme case)
- Tomorrow's date (invalid - future date)
- 1900-01-01 (valid extreme past)
- 2099-12-31 (valid but extreme future - should be invalid)

# EC/BVA Testing Table Sets

## Set 1: Item Name

| Test ID | Test Inputs                   | EC/BVA             | Expected QDebug                                                   | Pass Condition                       |
| ------- | ----------------------------- | ------------------ | ----------------------------------------------------------------- | ------------------------------------ |
| TC1     | itemName = ""                 | Invalid EC         | "Item name cannot be empty." Error shown. Item not added to list. | If error shown and item not saved.   |
| TC2     | itemName = " " (spaces only)  | Invalid EC         | "Item name cannot be empty." Item not added.                      | If trimmed and rejected.             |
| TC3     | itemName = "Laptop" (valid)   | Valid EC           | Item successfully added to list.                                  | If item appears in list and saved.   |
| TC4     | itemName.length() = 30        | Boundary (valid)   | Item successfully added with full-length name.                    | If stored and displayed correctly.   |
| TC5     | itemName.length() = 31        | Boundary (invalid) | "Item name exceeds maximum length (100 characters)."              | If item is rejected; fail if stored. |
| TC6     | itemName = "Laptop\x00Device" | Invalid EC         | "Item name contains invalid characters."                          | If error shown; item not saved.      |

## Set 2: Expense Amount

| Test ID | Test Inputs                   | EC/BVA                   | Expected QDebug                                                      | Pass Condition                                |
| ------- | ----------------------------- | ------------------------ | -------------------------------------------------------------------- | --------------------------------------------- |
| TC7     | expenseText = ""              | Invalid EC               | "Expense amount cannot be empty." Error shown. Item not added.       | If error shown and item not saved.            |
| TC8     | expenseText = "0"             | Invalid EC               | "Expense amount must be greater than 0."                             | If zero is rejected.                          |
| TC9     | expenseText = "-50.00"        | Invalid EC               | "Expense amount must be positive."                                   | If negative is rejected.                      |
| TC10    | expenseText = "$99.99"        | Valid EC                 | "$" prefix removed. Amount parsed as 99.99. Item saved successfully. | If currency symbol handled and amount stored. |
| TC11    | expenseText = "0.01"          | Boundary (valid minimum) | System accepts the amount. Item saved successfully.                  | If valid minimum amount accepted.             |
| TC12    | expenseText = "999999.999999" | Boundary (valid maximum) | System accepts the amount with 6 decimal precision.                  | If high precision maintained.                 |
| TC13    | expenseText = "1000000.00"    | Boundary (invalid max)   | "Expense amount exceeds system limit."                               | If exceeds limit and rejected.                |
| TC14    | expenseText = "abc"           | Invalid EC               | "Expense amount must be a valid number."                             | If non-numeric rejected.                      |

## Set 3: Purchase Date

| Test ID | Test Inputs                                  | EC/BVA                              | Expected QDebug Output                                                                              | Pass Condition                                |
| ------- | -------------------------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| TC15    | purchaseDateText = ""                        | Invalid EC                          | "Purchase date cannot be empty." Error shown. Item not added.                                       | If error shown and item not saved.            |
| TC16    | purchaseDateText = "2025-02-30"              | Invalid EC                          | "Invalid date: February does not have 30 days."                                                     | If invalid date rejected.                     |
| TC17    | purchaseDateText = "25-02-15" (wrong format) | Invalid EC                          | "Date format must be YYYY-MM-DD. This format is not accepted by DateTimePicker.qml. "               | If format validation fails.                   |
| TC18    | purchaseDateText = currentDate (today)       | Boundary (edge case)                | System accepts but calculation shows totalDays = 0. Item saved but limited calculation scope.       | If date accepted but warned to user.          |
| TC19    | purchaseDateText = yesterday's date          | Boundary (valid minimum)            | Date accepted. totalDays = 1. Calculations proceed normally.                                        | If calculations proceed.                      |
| TC20    | purchaseDateText = "1900-01-01"              | Boundary (valid extreme past)       | System accepts date. Calculations use 125+ year range.                                              | If extreme past accepted.                     |
| TC21    | purchaseDateText = tomorrow's date           | Boundary (invalid - future)         | "Purchase date cannot be in the future."                                                            | If future date rejected.                      |
| TC22    | purchaseDateText = "2099-12-31"              | Boundary (invalid - future extreme) | "Purchase date cannot be in the future."                                                            | If future date rejected.                      |
| TC23    | purchaseDateText = "2023-12-25" (valid past) | Valid EC                            | Date parsed correctly (ISO format). Item saved with purchase date recorded. Calculations performed. | If valid date accepted and calculations work. |
