# ChequeKit

ChequeKit captures Brazilian bank cheques on-device and reads their CMC-7 line. This glossary fixes the words the code, the docs and the conversations use for that domain.

## Language

### The cheque

**Cheque**:
A Brazilian bank cheque: a paper order, signed by its drawer, for a bank to pay a set amount.
_Avoid_: Check (collides with the verb "to check")

**Side**:
Either face of a cheque: its front or its back.
_Avoid_: Face, page

**Front**:
The side that carries the bank data, the amount, the payee, the signature and the CMC-7 line.
_Avoid_: Recto, obverse, anverso

**Back**:
The side opposite the front, where endorsements and bank stamps go.
_Avoid_: Verso, reverse

### The CMC-7 line

**CMC-7 line**:
The machine-readable line of 30 digits and separator symbols printed in the CMC-7 font along the bottom of the front.
_Avoid_: MICR line (MICR also covers the E-13B font), magnetic line

**Group**:
One of the three digit blocks of a CMC-7 line, of 8, 10 and 12 digits.
_Avoid_: Field, block, segment

**Bank code**:
The 3-digit COMPE code of the bank the cheque is drawn on.
_Avoid_: Bank number, ISPB (a different, 8-digit identifier)

**Branch**:
The 4-digit code of the bank branch (agência) that holds the drawer's account.
_Avoid_: Agency

**Clearing code**:
The 3-digit code of the clearing location (comp, praça de compensação) the cheque is cleared through.
_Avoid_: Compensation code, comp, praça

**Cheque number**:
The 6-digit number that identifies one cheque within the drawer's account.
_Avoid_: Check number, serial number

**Cheque type**:
The 1-digit code (tipificação) that classifies the cheque, such as ordinary or administrative.
_Avoid_: Typification

**Account field**:
The 10 digits of group 3 that encode the drawer's account in a layout each bank defines for itself.
_Avoid_: Account number

**Account number**:
The drawer's account as its bank formats it, derived from the account field through that bank's layout.
_Avoid_: Account field

**Check digit**:
A digit of the CMC-7 line computed from other digits of the line to detect misreadings; each group is guarded by one. Distinct from the C1–C3 digits printed on the cheque's top line.
_Avoid_: DV, verification digit

### Capturing a cheque

**Capture**:
An image of one side of a cheque that passed every quality check, cropped and perspective-corrected.
_Avoid_: Photo, snapshot, scan

**Quality issue**:
A reason an image is not yet acceptable as a capture, such as blur, glare or a missing corner.
_Avoid_: Error, warning

**CMC-7 reading**:
The decoded content of a CMC-7 line together with the outcome of each of its check digits.
_Avoid_: OCR result, parse result

**Unverified reading**:
A CMC-7 reading in which at least one check digit does not match.
_Avoid_: Invalid reading, failed reading

**Scan**:
The complete flow that captures both sides of one cheque and reads its CMC-7 line.
_Avoid_: Session

**Scan result**:
The outcome of a scan: a front capture, a back capture and a CMC-7 reading.
_Avoid_: Output, response

### Integration

**Host app**:
The app that embeds ChequeKit, such as a bank's or a fintech's mobile app.
_Avoid_: Client app, integrator

**Institution**:
The organisation that ships a host app and brands ChequeKit's UI with its visual identity; not necessarily the bank the cheque is drawn on.
_Avoid_: Bank, client, customer

### Not ChequeKit terms

**Deposit**:
Depositing a cheque is the host app's business; ChequeKit captures and reads, and never deposits.
