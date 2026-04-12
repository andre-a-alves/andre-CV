# andre-CV

A polyglot monorepo containing:

- A LaTeX document-class package for building German-style CVs and US-style resumes with optional cover letters
- Rust libraries and CLI tooling for generating LaTeX from structured YAML data

## Repository Layout

```
andre-cv/
├── latex/          LaTeX classes and themes (self-contained, copy-and-use)
│   ├── andre-cv.cls
│   ├── andre-cv-base.cls
│   └── themes/
│       ├── german-cv.sty
│       └── us-resume.sty
├── libs/
│   └── andre-cv-core/  Core Rust library (schema, parsing, validation, rendering)
├── tools/
│   └── cli/            Command-line interface
├── samples/        Reference .tex files and supporting assets
└── schema/         YAML resume schema
```

## Current Status

This project is still marked beta. The document API may change, and backward
compatibility is not guaranteed between revisions.

## LaTeX Quick Start

Copy the `latex/` directory somewhere on your `TEXINPUTS` path and use the
class directly:

```tex
\documentclass[theme=german-cv,10pt]{andre-cv}
```

or

```tex
\documentclass[theme=us-resume,10pt]{andre-cv}
```

### Requirements

- `fontspec`, `luacode`, `biblatex` / `biber` (for bibliography support in samples)
- Compile with `lualatex`, not `pdflatex`

### Example — German-style CV

```tex
\documentclass[theme=german-cv,10pt]{andre-cv}

\setmainfont{Source Sans 3}
\setsansfont{Source Sans 3}
\setmonofont{Source Sans 3}

\SetName{Dr. Henry Jones, Jr.}
\SetTown{Bedford, Connecticut, USA}
\SetPhone{+1 203 555 0198}
\SetEmail{indyjones@marshall.edu}
\SetCitizenship{USA}

\begin{document}
\DisplayHeader{Archaeologist}{./img/photo.png}

\section{Experience}
\cventry[
  dates    = {1936 - Present},
  title    = {Professor of Archaeology},
  org      = {Marshall College},
  location = {Bedford, Connecticut, USA},
]{\cvitemize{
  \item Example bullet
}}
\end{document}
```

### Example — US-style resume

```tex
\documentclass[theme=us-resume,10pt]{andre-cv}

\setmainfont{Source Sans 3}
\setsansfont{Source Sans 3}
\setmonofont{Source Sans 3}

\SetName{Dr. Henry Jones, Jr.}
\SetTown{Bedford, Connecticut}
\SetPhone{203 555 0198}
\SetEmail{indyjones@marshall.edu}

\MakeHeader
  {\DisplayName}
  {\DisplayTown}
  {\DisplayEmail~$\cdot$~\DisplayPhone}

\begin{document}
\section{Experience}
\cventry[
  dates    = {1936 - Present},
  title    = {Professor of Archaeology},
  org      = {Marshall College},
  location = {Bedford, Connecticut},
]{\cvitemize{
  \item Example bullet
}}
\end{document}
```

### Building the Samples

The classes live in `latex/`, so set `TEXINPUTS` when calling lualatex.
Compile from `samples/` so that relative image paths resolve correctly:

```bash
cd samples
TEXINPUTS=../latex//: lualatex german-cv.tex
biber german-cv
TEXINPUTS=../latex//: lualatex german-cv.tex
TEXINPUTS=../latex//: lualatex german-cv.tex
```

```bash
cd samples
TEXINPUTS=../latex//: lualatex us-resume.tex
biber us-resume
TEXINPUTS=../latex//: lualatex us-resume.tex
TEXINPUTS=../latex//: lualatex us-resume.tex
```

If you are not using `biblatex`, skip the `biber` step.

### Class Options

The unified class accepts:

- `theme=us-resume` or `theme=german-cv`
- `10pt`, `11pt`, `12pt`
- `a4paper`, `letterpaper`
- `english`, `german`

Theme defaults:

- `theme=german-cv` defaults to `a4paper`
- `theme=us-resume` defaults to `letterpaper`

Paper and language can still be overridden explicitly:

```tex
\documentclass[theme=german-cv,10pt,letterpaper,german]{andre-cv}
```

### Document API

#### Shared personal-detail commands

- `\SetName{...}`
- `\SetAddressOne{...}`, `\SetAddressTwo{...}`, `\SetAddressThree{...}`
- `\SetTown{...}`
- `\SetPhone{...}`
- `\SetEmail{...}`
- `\SetCitizenship{...}`
- `\SetGithub{...}`
- `\SetLinkedIn{...}`
- `\SetXing{...}`
- `\SetHomepage{...}`

`SetTown`, `SetPhone`, `SetEmail`, `SetCitizenship`, `SetGithub`,
`SetLinkedIn`, `SetXing`, and `SetHomepage` are rendered in a deterministic
category order in the German CV header.

For `\SetHomepage`, pass a bare host/path such as `www.example.com`; the
class prepends `https://`.

#### Theming

- `\SetAccentColor{ColorName}` overrides the accent color.

Built-in color names: `UltramarineBlue`, `YellowGreen`, `Fuchsia`,
`Tangerine`, `ElectricViolet`, `Coquelicot`, `Rose`.

#### Shared section and content commands

- `\section{Title}`
- `\cvitemize{ ... }`
- `\cvitem{label}{value}`
- `\cventry[dates=..., title=..., org=..., location=..., url=...]{...}`
- `coverletter` environment

If `url` is provided, the entry title is rendered as a hyperlink.

#### Theme-specific commands

`theme=german-cv`:

- `\DisplayHeader{subtitle}{image-path}`
- `\DisplaySignature{signature-image-path}{location}`
- `\ResizeTabular{width}`
- `\HeaderImageSizeCm{number}`

`theme=us-resume`:

- `\MakeHeader{line1}{line2}{line3}`
- `\SetBadge{scale}{image-path}`

#### Deprecated commands

- `\cventrylegacy`, `\cvlistitem`
- `\cvpadlessentry` (german-cv only)

## Licenses

This repository uses two licenses depending on the component:

| Component | License | File |
|-----------|---------|------|
| `latex/` — LaTeX classes and themes | LaTeX Project Public License 1.3c | `latex/LICENSE.txt` |
| `libs/`, `tools/` — Rust source code | Apache License 2.0 | `LICENSE.txt` |

The LaTeX classes (`latex/`) are distributed under the LPPL 1.3c because that
is the standard license for LaTeX packages and is expected by CTAN. The LPPL
requires that the files constituting the Work are listed; see
`latex/manifest.txt`.

The Rust libraries and CLI (`libs/`, `tools/`) are distributed under the
Apache License 2.0, which is the conventional open-source license for Rust
crates and provides an explicit patent grant.

The sample files in `samples/` are part of the LaTeX Work and are covered by
the LPPL 1.3c.
