%% andre-cv.cls
%% Copyright 2024 Andre A Alves
%
% This work may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3
% of this license or (at your option) any later version.
% The latest version of this license is in
%   http://www.latex-project.org/lppl.txt
% and version 1.3 or later is part of all distributions of LaTeX
% version 2005/12/01 or later.
%
% This work has the LPPL maintenance status `maintained'.
%
% The Current Maintainer of this work is Andre A Alves.
%
% This work consists of all files listed in manifest.txt.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{andre-cv}[2026-04-10]

\RequirePackage{etoolbox}

% Font Size
\DeclareOption{10pt}{\def\ChosenFontSize{10pt}}
\DeclareOption{11pt}{\def\ChosenFontSize{11pt}}
\DeclareOption{12pt}{\def\ChosenFontSize{12pt}}

% Theme selection
\def\cv@theme{us-resume}
\def\cv@handleoption#1=#2=#3\@nil{%
  \def\cv@optionname{#1}%
  \def\cv@optionvalue{#2}%
  \ifdefstring{\cv@optionname}{theme}{%
    \ifdefstring{\cv@optionvalue}{german-cv}{%
      \def\cv@theme{german-cv}%
    }{%
      \ifdefstring{\cv@optionvalue}{us-resume}{%
        \def\cv@theme{us-resume}%
      }{%
        \ifdefstring{\cv@optionvalue}{awesome-resume}{%
          \def\cv@theme{awesome-resume}%
        }{%
          \ifdefstring{\cv@optionvalue}{classic-resume}{%
            \def\cv@theme{classic-resume}%
          }{%
            \ClassError{andre-cv}{Unknown theme '\cv@optionvalue'}%
              {Supported themes are 'german-cv', 'us-resume', 'awesome-resume', and 'classic-resume'.}%
          }%
        }%
      }%
    }%
  }{%
    \PassOptionsToClass{\CurrentOption}{andre-cv-base}%
  }%
}

% Forward unknown options (paper size, language, etc.) to the base class.
\DeclareOption*{%
  \edef\cv@currentoption{\CurrentOption}%
  \expandafter\cv@handleoption\cv@currentoption=\@nil
}
\ExecuteOptions{10pt}
\ProcessOptions\relax
\PassOptionsToClass{\ChosenFontSize}{andre-cv-base}

% Theme defaults for paper/language; user options processed in the base class
% can still override these values.
\ifdefstring{\cv@theme}{german-cv}{%
  \def\cv@papersize{a4paper}%
}{%
  \ifdefstring{\cv@theme}{us-resume}{%
    \def\cv@papersize{letterpaper}%
  }{%
    \ifdefstring{\cv@theme}{awesome-resume}{%
      \def\cv@papersize{letterpaper}%
    }{%
      \ifdefstring{\cv@theme}{classic-resume}{%
        \def\cv@papersize{a4paper}%
      }{%
        \ClassError{andre-cv}{Unknown theme '\cv@theme'}%
          {Supported themes are 'german-cv', 'us-resume', 'awesome-resume', and 'classic-resume'.}%
      }%
    }%
  }%
}
\def\cv@language{english}
\def\cv@babellang{english}
\LoadClass{andre-cv-base}

\RequirePackage{themes/\cv@theme}
