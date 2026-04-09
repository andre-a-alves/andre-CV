# andre-CV

A LaTeX document-class set for building:

- German-style CVs with optional cover letters
- US-style resumes with optional cover letters

The repository already includes working examples in `sample-CV.tex` and `sample-resume.tex`.

## Current Status

This project is still marked beta. The document API may change, and backward compatibility is not guaranteed between revisions.

## What Is In This Repository

- `andre-cv.cls`: CV class tuned for A4 output
- `andre-resume.cls`: resume class tuned for US letter output
- `andre-cv-base.cls`: shared commands, colors, and layout primitives
- `sample-CV.tex`: current CV example
- `sample-resume.tex`: current resume example
- `sample-papers.bib`: bibliography sample used by both example documents

## Requirements

This project uses:

- `fontspec`
- `luacode`
- `biblatex` with `biber` in the samples

That means you should compile with `lualatex`, not `pdflatex`.

## Quick Start

Use one of the sample files as your starting point.

For a CV:

```tex
\documentclass[10pt]{andre-cv}

\setmainfont{Source Sans 3}
\setsansfont{Source Sans 3}
\setmonofont{Source Sans 3}

\SetName{Dr. Henry Jones, Jr.}
\SetAddressOne{123 Artifact Lane}
\SetAddressTwo{Marshall College, Bedford, Connecticut}
\SetAddressThree{USA}
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
]{
  \cvitemize{
    \item Example bullet
  }
}
\end{document}
```

For a resume:

```tex
\documentclass[10pt]{andre-resume}

\setmainfont{Source Sans 3}
\setsansfont{Source Sans 3}
\setmonofont{Source Sans 3}

\SetName{Dr. Henry Jones, Jr.}
\SetAddressOne{123 Artifact Lane}
\SetAddressTwo{Marshall College, Bedford, Connecticut}
\SetTown{Bedford, Connecticut}
\SetPhone{203 555 0198}
\SetEmail{indyjones@marshall.edu}
\SetLinkedIn{indy-jones}

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
]{
  \cvitemize{
    \item Example bullet
  }
}
\end{document}
```

## Building

If your document uses bibliography support, build with:

```bash
lualatex sample-CV.tex
biber sample-CV
lualatex sample-CV.tex
lualatex sample-CV.tex
```

Or for the resume:

```bash
lualatex sample-resume.tex
biber sample-resume
lualatex sample-resume.tex
lualatex sample-resume.tex
```

If you are not using `biblatex`, you can skip the `biber` step.

## Current Document API

### Shared personal-detail commands

These commands are defined in `andre-cv-base.cls` and are used by both classes:

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

`SetTown`, `SetPhone`, `SetEmail`, `SetCitizenship`, `SetGithub`, `SetLinkedIn`, `SetXing`, and `SetHomepage` are also added to the CV header details table automatically.

For `\SetHomepage`, pass a bare host/path such as `www.example.com`; the class prepends `https://`.

### Section and content commands

Both classes provide:

- `\section{Title}`
- `\cvitemize{ ... }`
- `\cvitem{label}{value}`

### `\cventry` interface

The current `\cventry` command uses key-value arguments:

```tex
\cventry[
  dates    = {2022 - 2024},
  title    = {Role Title},
  org      = {Organization},
  location = {City, Country},
  url      = {https://example.com}
]{...}
```

Supported keys:

- `dates`
- `title`
- `org`
- `location`
- `url`

If `url` is provided, the title is rendered as a hyperlink.

### Deprecated commands

The following older commands still exist for compatibility, but the newer commands above are the current API:

- `\cventrylegacy`
- `\cvpadlessentry` in `andre-cv.cls`
- `\cvlistitem`

Prefer:

- `\cventry[...]{...}` style key-value entries
- `\cvitem{...}{...}` for label/value rows

## CV-Specific Commands

`andre-cv.cls` additionally provides:

- `\DisplayHeader{subtitle}{image-path}`
- `\DisplaySignature{signature-image-path}{location}`
- `\ResizeTabular{width}`
- `\HeaderImageSizeCm{number}`

Notes:

- Pass an empty second argument to `\DisplayHeader` if you do not want a photo.
- `\HeaderImageSizeCm{...}` overrides the automatically computed square image size in centimeters.

## Resume-Specific Commands

`andre-resume.cls` additionally provides:

- `\MakeHeader{line1}{line2}{line3}`
- `\SetBadge{scale}{image-path}`

`MakeHeader` sets the running header content used by the resume layout.

## Cover Letters

Both classes provide:

```tex
\MakeCoverLetter
  {sender name}
  {sender address block}
  {recipient name}
  {recipient address block}
  {subject line}
  {greeting}
  {body}
  {salutation}
  {signature-image-path}
```

To omit the signature image, pass an empty final argument.

The resume and CV classes format cover letters differently to match their respective layouts.

## Samples

The most reliable documentation for current usage is in:

- `sample-CV.tex`
- `sample-resume.tex`

Those files reflect the current macro names and calling conventions in the repository.

## License

This project is distributed under the LaTeX Project Public License (LPPL) version 1.3c. See `LICENSE.txt` for the full license text.

Files not explicitly listed in `manifest.txt` are not part of the distributable project unless permission is provided elsewhere.

## Inspiration

This project was inspired by:

- [Awesome-CV](https://github.com/posquit0/Awesome-CV)
- [Latex CV and Resume Collection](https://github.com/jankapunkt/latexcv)
