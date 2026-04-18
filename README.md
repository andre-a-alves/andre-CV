# andre-CV

A polyglot monorepo containing:

- A LaTeX document-class package for building tabular CVs and classic resumes with optional cover letters
- Rust libraries and CLI tooling for generating LaTeX from structured YAML data

## Repository Layout

```
andre-cv/
├── latex/          LaTeX classes and themes (self-contained, copy-and-use)
│   ├── andre-cv.cls
│   ├── themes/
│   │   ├── tabular-cv.sty
│   │   ├── classic-resume.sty
│   │   └── modern-resume.sty
│   └── letters/
│       ├── german-din.sty   German DIN 5008 cover letter
│       └── us-business.sty  US Business cover letter
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

## Themes

<table>
<tr>
<td align="center"><b>tabular-cv</b><br><img src="samples/previews/tabular-cv.png" width="340"></td>
<td align="center"><b>classic-resume</b><br><img src="samples/previews/classic-resume.png" width="340"></td>
<td align="center"><b>modern-resume</b><br><img src="samples/previews/modern-resume.png" width="340"></td>
</tr>
</table>

## Cover Letter Styles

<table>
<tr>
<td align="center"><b>german-din</b><br><img src="samples/previews/german-din-letter.png" width="340"></td>
<td align="center"><b>us-business</b><br><img src="samples/previews/us-business-letter.png" width="340"></td>
</tr>
</table>

## LaTeX Quick Start

Copy the `latex/` directory somewhere on your `TEXINPUTS` path and use the
class directly:

```tex
\documentclass[theme=tabular-cv,10pt]{andre-cv}
```

or

```tex
\documentclass[theme=classic-resume,10pt]{andre-cv}
```

or

```tex
\documentclass[theme=modern-resume,10pt]{andre-cv}
```

### Requirements

- `fontspec`, `luacode`, `biblatex` / `biber` (for bibliography support in samples)
- Compile with `lualatex`, not `pdflatex`

### Example — Tabular CV

```tex
\documentclass[theme=tabular-cv,10pt]{andre-cv}

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

### Example — Classic resume

```tex
\documentclass[theme=classic-resume,10pt]{andre-cv}

\setmainfont{Source Sans 3}
\setsansfont{Source Sans 3}
\setmonofont{Source Sans 3}

\SetName{Dr. Henry Jones, Jr.}
\SetTown{Bedford, Connecticut}
\SetPhone{203 555 0198}
\SetEmail{indyjones@marshall.edu}

\begin{document}
\DisplayHeader{Archaeologist}{./img/photo.png}

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
TEXINPUTS=../latex//: lualatex tabular-cv.tex
biber tabular-cv
TEXINPUTS=../latex//: lualatex tabular-cv.tex
TEXINPUTS=../latex//: lualatex tabular-cv.tex
```

```bash
cd samples
TEXINPUTS=../latex//: lualatex classic-resume.tex
biber classic-resume
TEXINPUTS=../latex//: lualatex classic-resume.tex
TEXINPUTS=../latex//: lualatex classic-resume.tex
```

```bash
cd samples
TEXINPUTS=../latex//: lualatex modern-resume.tex
biber modern-resume
TEXINPUTS=../latex//: lualatex modern-resume.tex
TEXINPUTS=../latex//: lualatex modern-resume.tex
```

If you are not using `biblatex`, skip the `biber` step.

### Class Options

The unified class accepts:

- `theme=tabular-cv`, `theme=classic-resume`, or `theme=modern-resume`
- `letter=german-din`, `letter=us-business`, or `letter=none`
- `10pt`, `11pt`, `12pt`
- `a4paper`, `letterpaper`
- `english`, `german`

Theme defaults:

- `theme=tabular-cv` and `theme=modern-resume` default to `a4paper`
- `theme=classic-resume` defaults to `letterpaper`

Letter style defaults (applied automatically when `letter=` is not specified):

- `theme=tabular-cv` defaults to `letter=german-din`
- `theme=classic-resume` and `theme=modern-resume` default to `letter=us-business`

Use `letter=none` to suppress the cover letter entirely:

```tex
\documentclass[theme=modern-resume,letter=none,10pt]{andre-cv}
```

Paper, language, and letter style can all be overridden explicitly:

```tex
\documentclass[theme=tabular-cv,10pt,letterpaper,german,letter=us-business]{andre-cv}
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
category order in every theme header.

The resume headers render a single contact line from those personal details.
Location, phone, and email are plain text; platform links such as GitHub,
LinkedIn, Xing, and homepage keep their icons.

For `\SetHomepage`, pass a bare host/path such as `www.example.com`; the
class prepends `https://`.

#### Theming

- `\SetAccentColor{ColorName}` overrides the accent color.
- `\DisplayHeader{subtitle}` or `\DisplayHeader{subtitle}{image-path}` renders the CV/resume header for every theme.
- `\DisplaySignature{signature-image-path}{location}` renders a signature block.

Built-in color names: `UltramarineBlue`, `YellowGreen`, `Fuchsia`,
`Tangerine`, `ElectricViolet`, `Coquelicot`, `Rose`.

#### Shared section and content commands

- `\section{Title}`
- `\cvitemize{ ... }`
- `\cvitem{label}{value}`
- `\cventry[dates=..., title=..., org=..., location=..., url=...]{...}`
- `coverletter` environment — renders a cover letter before the CV using the active letter style

If `url` is provided, the entry title is rendered as a hyperlink.

#### Cover letter

The `coverletter` environment accepts key-value options:

```tex
\begin{coverletter}[
  to-name    = {Dr. Marcus Brody},
  to-address = {National Museum, Washington D.C.},
  subject    = {Re: Ark of the Covenant},
  opening    = {Dear Marcus},
  closing    = {Sincerely},
  signature  = {./img/signature.png},
]
Letter body goes here.
\end{coverletter}
```

The letter is placed before `\begin{document}` content and the CV starts
on a new page numbered from 1. The visual style (layout, fonts, header
placement) is controlled by the active `letter=` option.

#### Compatibility and layout commands

- `\MakeHeader{subtitle}` is kept as a compatibility alias for older resume documents.
- `\MakeHeader{name}{subtitle}` and `\MakeHeader{name}{subtitle}{contact-line}` are also accepted for older samples.
- `\ResizeTabular{width}` affects `theme=tabular-cv` and is ignored by the resume themes.
- `\HeaderImageSizeCm{number}` affects `theme=tabular-cv` and is ignored by the resume themes.

The recommended portable header command is `\DisplayHeader`; documents that
use it can switch between `tabular-cv`, `classic-resume`, and `modern-resume`
by changing only the `theme=` class option.

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
