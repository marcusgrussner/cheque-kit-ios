# Verified and unverified readings

Understand what the check digits of a CMC-7 line prove, and what to do when they do not match.

## Overview

A CMC-7 line has 30 digits in three groups, and each group is guarded by a check digit computed from the digits it covers. ``CMC7Reading`` recomputes the three check digits and compares them with the ones printed on the line.

### Verified readings

A reading is verified when all three check digits match: ``CMC7Reading/isVerified`` is `true` and ``CMC7Reading/mismatchedGroups`` is empty. ``ChequeReader`` also accepts a verified reading only when a neighbouring rotation of the photo reads the same line, so that a misread that happens to pass the check digits is unlikely to get through.

A verified reading is very likely to be the line printed on the cheque. It is not proof that the cheque is authentic: the check digits guard against misreading the line, not against a forged or altered cheque.

### Unverified readings

A reading is unverified when at least one check digit does not match. ``CMC7Reading/mismatchedGroups`` names the groups whose check digit does not match, using ``CMC7Line/Group``.

ChequeKit never corrects an unverified reading: it returns the digits as read, because guessing which digit is wrong could turn a detectable misread into an undetectable one. Your app decides what to do with it, for example:

- Ask for another photo, which is usually the best choice when the photo is blurred, dark or taken at an angle.
- Show the reading for the user to confirm or correct, pointing to the groups in ``CMC7Reading/mismatchedGroups``.

Do not use an unverified reading as if it were verified.

### The account field is not the account number

``CMC7Line/accountField`` holds the 10 digits that encode the drawer's account in a layout each bank defines for itself. Deriving the account number from it depends on the bank, and ChequeKit does not decode it.

### Cheque types

``CMC7Line/chequeType`` decodes the cheque type digit. A digit that no known type uses becomes ``ChequeType/unrecognized(_:)`` and keeps the digit as read, so a new or unexpected code is reported instead of making the line unreadable.
