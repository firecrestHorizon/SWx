# SWx

SWx is a small macOS command-line tool that downloads the current planetary Kp
index forecast from the NOAA Space Weather Prediction Center and displays it as
either an ASCII chart or a text report.

## Current capabilities

- Downloads the live [NOAA planetary K-index forecast](https://services.swpc.noaa.gov/products/noaa-planetary-k-index-forecast.json).
- Displays observed, estimated, and predicted Kp values in a terminal chart.
- Provides an alternative line-by-line text report.
- Displays NOAA geomagnetic storm scales (`G1` through `G5`) when supplied.
- Marks the highest observed and forecast values in the text report.
- Treats NOAA timestamps and chart date boundaries as UTC.
- Reports invalid data, configuration, and HTTP responses as command-line errors.

The chart uses a different character for each type of Kp value:

| Character | Meaning |
| --- | --- |
| `█` | Observed |
| `~` | Estimated |
| `+` | Predicted |

## RequirementsB

- macOS 10.15 or later
- Swift 5.10 or later
- An internet connection to retrieve the NOAA dataset

Swift Package Manager downloads the
[swift-argument-parser](https://github.com/apple/swift-argument-parser)
dependency automatically.

## Build and run

Clone the repository and change into its directory:

```sh
git clone https://github.com/firecrestHorizon/SWx.git
cd SWx
```

Run the ASCII chart:

```sh
swift run SWx
```

Run the line-by-line text report:

```sh
swift run SWx --text-output
```

The explicit subcommand form is also supported:

```sh
swift run SWx kp-forecast --text-output
```

For a release build:

```sh
swift build -c release
.build/release/SWx
```

Use `--help` to see the available commands and options:

```sh
swift run SWx --help
```

## Text report

Text mode prints the UTC timestamp, Kp value, observation type, and NOAA scale
when one is present. An asterisk marks the maximum observed value and the
maximum value across the estimated and predicted forecast data.

```text
2026-07-27 18:00:00 +0000 Kp:  1.67 [observed]
2026-07-27 21:00:00 +0000 Kp:  3.67 [estimated] *
2026-07-28 00:00:00 +0000 Kp:  5.33 [predicted] scale: "G1" *
```

## Tests

Run the decoder and renderer regression tests with:

```sh
swift test
```

The tests include a representative NOAA response and checks for invalid data,
unknown observation types, chart rounding, and report maximum markers.

## Data source

Data is retrieved on each run from NOAA's
`noaa-planetary-k-index-forecast.json` product. SWx does not cache the response
or provide an offline dataset.
