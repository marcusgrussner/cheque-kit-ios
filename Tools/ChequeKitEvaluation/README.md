# ChequeKitEvaluation

Measures how well ChequeKit reads real cheques. It reads every photo of a folder of samples, as taken and in degraded variants, and reports per variant how many readings are correct, how many wrong readings pass their check digits, and how long a reading takes.

```sh
swift run -c release ChequeKitEvaluation [samples folder] [--original-only]
```

Build in release: debug builds are several times slower and make the timings meaningless.

## The samples folder

Real cheques carry personal data protected by Brazil's LGPD, so **samples never enter this repository**. The folder defaults to `~/ChequeKit-PrivateSamples` and holds:

- `samples.csv`: a header row, then one row per cheque with its id and its CMC-7 line as 30 digits, typed from the cheque itself:

  ```csv
  id,line
  itau-01,<the 30 digits of the line>
  ```

- one photo of the front of each cheque, named `<id>-front` with any extension ImageIO reads, such as `itau-01-front.heic`.

A row whose line does not pass its check digits, or that has no photo, is skipped and reported. Prefix ids with the bank, so the per-read report can be grouped by bank.

## Reading the report

The tool prints one line per reading and a summary table per variant. It never prints the digits of a line: a wrong reading is reported by how many of its 26 data digits differ from the printed line. It also writes every reading to `evaluation.csv` in the samples folder.

| Outcome | Meaning |
|---|---|
| correct | The reading passed its check digits and is the printed line. |
| **false accept** | The reading passed its check digits but is not the printed line. A host app cannot tell, so this is the failure that matters most; the tool exits with status 1 when any reading is one. |
| unverified | The reading failed its check digits, so a host app knows not to trust it. |
| no cheque | The reader found no cheque in the photo. |
| no line | The reader found a cheque but no well-formed line on it, or the photo could not be processed. |

## The variants

| Variant | Stands for |
|---|---|
| scaled 0.75×, 0.5×, 0.35× | A camera with fewer pixels across the cheque. Reading needs about 300 dpi. |
| rotated ±1°, ±3° | The whole photo turned. Perspective correction straightens the cheque, so this measures detection more than the skew search. |
| exposed −1.5 EV, +1 EV | A cheque in dim or bright light. |
| blurred 1.5 px, 3 px | A cheque slightly out of focus. |
