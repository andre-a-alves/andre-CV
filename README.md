# andre-CV

A LaTeX document-class package for building:

- German-style CVs with optional cover letters
- US-style resumes with optional cover letters

The package now uses a single class entrypoint, `andre-cv.cls`, plus theme
packages in `themes/`.

## Current Status

This project is still marked beta. The document API may change, and backward
compatibility is not guaranteed between revisions.

## What Is In This Repository

- `andre-cv.cls`: unified class entrypoint
- `andre-cv-base.cls`: shared commands, parsing, and rendering hooks
- `themes/german-cv.sty`: German CV theme
- `themes/us-resume.sty`: US resume theme
- `sample-german-cv.tex`: CV example using `theme=german-cv`
- `sample-us-resume.tex`: resume example using `theme=us-resume`
- `sample-papers.bib`: bibliography sample used by both example documents

## Requirements

This project uses:

- `fontspec`
- `luacode`
- `biblatex` with `biber` in the samples

Compile with `lualatex`, not `pdflatex`.

## Quick Start

For a German-style CV:

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
\DisplayHeader{Archaeologist}{./img/DALLE_adventurer.png}

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

For a US-style resume:

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

## Building

If your document uses bibliography support, build with:

```bash
lualatex sample-german-cv.tex
biber sample-german-cv
lualatex sample-german-cv.tex
lualatex sample-german-cv.tex
```

Or for the resume:

```bash
lualatex sample-us-resume.tex
biber sample-us-resume
lualatex sample-us-resume.tex
lualatex sample-us-resume.tex
```

If you are not using `biblatex`, you can skip the `biber` step.

## Class Options

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

## Current Document API

### Shared personal-detail commands

- `\SetName{...}`
- `\SetAddressOne{...}`
- `\SetAddressTwo{...}`
- `\SetAddressThree{...}`
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

### Theming

- `\SetAccentColor{ColorName}` overrides the accent color.

Built-in color names include `UltramarineBlue`, `YellowGreen`, `Fuchsia`,
`Tangerine`, `ElectricViolet`, `Coquelicot`, and `Rose`.

### Shared section and content commands

- `\section{Title}`
- `\cvitemize{ ... }`
- `\cvitem{label}{value}`
- `\cventry[dates=..., title=..., org=..., location=..., url=...]{...}`
- `coverletter`

If `url` is provided, the entry title is rendered as a hyperlink.

### Deprecated commands

The following compatibility commands still exist:

- `\cventrylegacy`
- `\cvlistitem`

`theme=german-cv` additionally provides:

- `\cvpadlessentry`

### Theme-specific helper commands

`theme=german-cv` provides:

- `\DisplayHeader{subtitle}{image-path}`
- `\DisplaySignature{signature-image-path}{location}`
- `\ResizeTabular{width}`
- `\HeaderImageSizeCm{number}`

`theme=us-resume` provides:

- `\MakeHeader{line1}{line2}{line3}`
- `\SetBadge{scale}{image-path}`

## Cover Letters

Both themes provide the `coverletter` environment and the deprecated
`\MakeCoverLetter` helper. Cover letters are formatted according to the active
theme.

## Samples

The most reliable usage examples are:

- `sample-german-cv.tex`
- `sample-us-resume.tex`

## License

This project is distributed under the LaTeX Project Public License 1.3c or
later. See `LICENSE.txt`.
