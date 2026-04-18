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
\ProvidesClass{andre-cv}[2026-04-14]

\RequirePackage{etoolbox}

% Font Size
\DeclareOption{10pt}{\def\ChosenFontSize{10pt}}
\DeclareOption{11pt}{\def\ChosenFontSize{11pt}}
\DeclareOption{12pt}{\def\ChosenFontSize{12pt}}

% Paper Size (theme sets a default below; user may override)
\DeclareOption{a4paper}{\def\cv@papersize{a4paper}}
\DeclareOption{letterpaper}{\def\cv@papersize{letterpaper}}

% Language
\DeclareOption{english}{\def\cv@language{english}\def\cv@babellang{english}}
\DeclareOption{german}{\def\cv@language{german}\def\cv@babellang{ngerman}}

% Theme and letter-style selection
\def\cv@theme{classic-resume}
\def\cv@letterstyle{auto}
\def\cv@handleoption#1=#2=#3\@nil{%
  \def\cv@optionname{#1}%
  \def\cv@optionvalue{#2}%
  \ifdefstring{\cv@optionname}{theme}{%
    \ifdefstring{\cv@optionvalue}{tabular-cv}{%
      \def\cv@theme{tabular-cv}%
    }{%
      \ifdefstring{\cv@optionvalue}{classic-resume}{%
        \def\cv@theme{classic-resume}%
      }{%
        \ifdefstring{\cv@optionvalue}{modern-resume}{%
          \def\cv@theme{modern-resume}%
        }{%
          \ClassError{andre-cv}{Unknown theme '\cv@optionvalue'}%
            {Supported themes are 'tabular-cv', 'classic-resume', and 'modern-resume'.}%
        }%
      }%
    }%
  }{%
    \ifdefstring{\cv@optionname}{letter}{%
      \ifdefstring{\cv@optionvalue}{german-din}{%
        \def\cv@letterstyle{german-din}%
      }{%
        \ifdefstring{\cv@optionvalue}{us-business}{%
          \def\cv@letterstyle{us-business}%
        }{%
          \ifdefstring{\cv@optionvalue}{none}{%
            \def\cv@letterstyle{none}%
          }{%
            \ClassError{andre-cv}{Unknown letter style '\cv@optionvalue'}%
              {Supported letter styles are 'german-din', 'us-business', and 'none'.}%
          }%
        }%
      }%
    }{%
      \PassOptionsToClass{\CurrentOption}{article}%
    }%
  }%
}

% Forward unknown options (paper size, language, etc.) to article.
\DeclareOption*{%
  \edef\cv@currentoption{\CurrentOption}%
  \expandafter\cv@handleoption\cv@currentoption=\@nil
}
\ExecuteOptions{10pt}
\ProcessOptions\relax

% Theme paper-size defaults (only applied if the user did not pass an
% explicit paper-size option above).
\@ifundefined{cv@papersize}{%
  \ifdefstring{\cv@theme}{tabular-cv}{%
    \def\cv@papersize{a4paper}%
  }{%
    \ifdefstring{\cv@theme}{classic-resume}{%
      \def\cv@papersize{letterpaper}%
    }{%
      \ifdefstring{\cv@theme}{modern-resume}{%
        \def\cv@papersize{a4paper}%
      }{%
        \ClassError{andre-cv}{Unknown theme '\cv@theme'}%
          {Supported themes are 'tabular-cv', 'classic-resume', and 'modern-resume'.}%
      }%
    }%
  }%
}{}
% Resolve 'auto' letter style: pick the natural default for each theme
\ifdefstring{\cv@letterstyle}{auto}{%
  \ifdefstring{\cv@theme}{tabular-cv}{%
    \def\cv@letterstyle{german-din}%
  }{%
    \def\cv@letterstyle{us-business}%
  }%
}{}
% Fall-back defaults if no user option supplied one
\providecommand{\cv@papersize}{a4paper}
\providecommand{\cv@language}{english}
\providecommand{\cv@babellang}{english}
\PassOptionsToClass{\ChosenFontSize}{article}
\LoadClass{article}

\RequirePackage[\cv@babellang]{babel}
\RequirePackage{fontspec}
\RequirePackage{ifthen}
\RequirePackage{hyperref}
\hypersetup{
    colorlinks=true,  % activate colours
    linkcolor=.,  % inherit current text color
    citecolor=.,  % inherit current text color
    urlcolor=.    % inherit current text color
}
\RequirePackage{tabularx}
\RequirePackage{graphicx}
\RequirePackage{enumitem}
\RequirePackage[totpages,lastpage,user]{zref}
\RequirePackage{fontawesome}
\RequirePackage{calc}
\RequirePackage{multirow}
\RequirePackage{wrapfig}
\RequirePackage{luacode} % for use of Lua code
\RequirePackage{pgfkeys}
\RequirePackage{xparse}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Fonts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{moresize}   % more font size definitions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Parameter Declaration Commands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\begin{luacode}
    personalDetails = {}
    personalDetailsIndex = 1
    setPictureWidth = 0

    function sortedPersonalDetailsCopy(arr)
        local items = {}
        for _, detail in ipairs(arr) do
            items[#items + 1] = detail
        end
        table.sort(items, function(a, b)
            return (a.sortKey or 0) < (b.sortKey or 0)
        end)
        return items
    end

    function printInlinePersonalDetails(arr, includeIcons)
        local texItems = {}
        for _, detail in ipairs(sortedPersonalDetailsCopy(arr)) do
            if includeIcons or (detail.sortKey or 0) >= 50 then
                texItems[#texItems + 1] = "\\mbox{" .. detail.icon .. detail.value .. "}"
            else
                texItems[#texItems + 1] = "\\mbox{" .. detail.value .. "}"
            end
        end
        tex.sprint(table.concat(texItems, "\\hspace{0.45em}{\\textperiodcentered}\\hspace{0.45em}"))
    end
\end{luacode}

\newcommand{\FooterGrayColor}[1]{\color{gray} #1}
\newcommand{\DisplayName}{}
\newcommand*{\SetName}[1]{\def\DisplayName{#1}}
\newcommand*{\SetAddressOne}[1]{\def\DisplayAddressOne{#1}}
\newcommand*{\SetAddressTwo}[1]{\def\DisplayAddressTwo{#1}}
\newcommand*{\SetAddressThree}[1]{\def\DisplayAddressThree{#1}}
% Personal-details sortKeys: lower is rendered first. The categories (in
% order) are location, phone, email, links. The keys are sparse so new
% fields can slot in without renumbering.
\newcommand*{\SetTown}[1]{
    \def\DisplayTown{#1}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayTown",
            icon = "\\faMapMarker",
            sortKey = 10,
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetPhone}[1]{
    \def\DisplayPhone{#1}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayPhone",
            icon = "\\faMobile",
            sortKey = 30,
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetEmail}[1]{
    \def\DisplayEmail{\href{mailto:#1}{#1}}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayEmail",
            icon = "\\faEnvelope",
            sortKey = 40,
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetCitizenship}[1]{
    \def\DisplayCitizenship{#1}
    \directlua{
            personalDetails[personalDetailsIndex] = {
                value = "\\DisplayCitizenship",
                icon = "\\faFlag",
                sortKey = 20,
            }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetGithub}[1]{
    \def\DisplayGithub{\href{https://github.com/#1}{~#1}}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayGithub",
            icon = "\\faGithub",
            sortKey = 50,
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetLinkedIn}[1]{
    \def\DisplayLinkedIn{\href{https://linkedin.com/in/#1}{~#1}}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayLinkedIn",
            icon = "\\faLinkedinSquare",
            sortKey = 60,
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetXing}[1]{
    \def\DisplayXing{\href{https://www.xing.com/profile/#1}{~#1}}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayXing",
            icon = "\\faXing",
            sortKey = 70,
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
% NOTE: #1 must be a bare domain/path with no scheme (e.g. "www.example.com"),
% as https:// is prepended automatically.
\newcommand*{\SetHomepage}[1]{
    \def\DisplayHomepage{\href{https://#1}{~#1}}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayHomepage",
            icon = "\\faLaptop",
            sortKey = 80,
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\RenderPersonalDetails}{%
    \directlua{printInlinePersonalDetails(personalDetails, false)}%
}
\newcommand*{\RenderIconPersonalDetails}{%
    \directlua{printInlinePersonalDetails(personalDetails, true)}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Headers and Footers
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{fancyhdr}       % necessary for "fancy headers" specificied later
\fancyhf{}
\setlength{\headheight}{50pt}
\rfoot{
    \ifnum\ztotpages>1{
        \FooterGrayColor{\thepage\ of \zpageref{LastPage}}
    }
    \else {}
    \fi
}
\renewcommand{\headrulewidth}{0pt}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Color-Related
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{xcolor}		% define colors
% Color names and codes obtained from https://coolors.co/
\definecolor{UltramarineBlue}{HTML}{2E5EFF}
\definecolor{YellowGreen}{HTML}{36AB00}
\definecolor{Fuchsia}{HTML}{F500E4}
\definecolor{Tangerine}{HTML}{F58B00}
\definecolor{ElectricViolet}{HTML}{8B00F5}
\definecolor{Coquelicot}{HTML}{F53900}
\definecolor{Rose}{HTML}{FF0F80}
\definecolor{gray}{HTML}{999999}
\definecolor{light_gray}{RGB}{185,185,185}
\colorlet{accentColor}{UltramarineBlue}

% User-facing convenience: override the accent color (e.g. \SetAccentColor{Tangerine}).
\newcommand*{\SetAccentColor}[1]{\colorlet{accentColor}{#1}}

\setcounter{secnumdepth}{0}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Theme Rendering Hooks
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand*{\cv@entry@linktitle}{%
  \ifthenelse{\equal{\cv@entry@url}{}}%
    {\cv@entry@title}%
    {\href{\cv@entry@url}{\cv@entry@title}}%
}

\newcommand*{\cv@render@sectionheading}[1]{%
  \vspace{4mm}%
  \noindent{\Large\bfseries\color{accentColor}#1} \textcolor{light_gray}{\hrulefill}\par%
}

\newcommand*{\cv@render@entry}[1]{#1}
\newcommand*{\cv@render@item}[2]{#1 #2\par}
\newcommand*{\cv@render@header}{}
\newcommand*{\cv@renderletter@begin}{}
\newcommand*{\cv@renderletter@end}{}

\newbool{cv@document@started}
\newbool{cv@header@configured}
\newbool{cv@header@rendered}
\newbool{cv@header@badge}
\newcommand*{\cv@header@subtitle}{}
\newcommand*{\cv@header@image}{}
\newcommand*{\cv@header@badgescale}{1}
\newcommand*{\cv@header@badgeimage}{}
\newcommand*{\cv@header@contact}{\RenderPersonalDetails}

\AtBeginDocument{\booltrue{cv@document@started}}

\newcommand*{\cv@configure@header}[2]{%
  \def\cv@header@subtitle{#1}%
  \def\cv@header@image{#2}%
  \booltrue{cv@header@configured}%
  \boolfalse{cv@header@rendered}%
}

\newcommand*{\cv@maybe@render@header}{%
  \ifbool{cv@header@configured}{%
    \ifbool{cv@header@rendered}{}{%
      \booltrue{cv@header@rendered}%
      \cv@render@header%
    }%
  }{}%
}

\NewDocumentCommand{\DisplayHeader}{m g}{%
  \IfNoValueTF{#2}%
    {\cv@configure@header{#1}{}}%
    {\cv@configure@header{#1}{#2}}%
  \ifbool{cv@document@started}{\cv@maybe@render@header}{}%
}

% Backward-compatible adapter for older resume samples:
%   \MakeHeader{subtitle}
%   \MakeHeader{name}{subtitle}
%   \MakeHeader{name}{subtitle}{contact-line}
\NewDocumentCommand{\MakeHeader}{m g g}{%
  \IfNoValueTF{#2}{%
    \cv@configure@header{#1}{}%
  }{%
    \IfNoValueTF{#3}{%
      \cv@configure@header{#2}{}%
    }{%
      \def\cv@header@contact{#3}%
      \cv@configure@header{#2}{}%
    }%
  }%
  \ifbool{cv@document@started}{\cv@maybe@render@header}{}%
}

\newcommand*{\SetBadge}[2]{%
  \booltrue{cv@header@badge}%
  \def\cv@header@badgescale{#1}%
  \def\cv@header@badgeimage{#2}%
}

\newcommand*{\ResizeTabular}[1]{}
\newcommand*{\HeaderImageSizeCm}[1]{}

\newcommand*{\DisplaySignature}[2]{%
  \bigskip
  \begin{flushright}
    \includegraphics[width=5cm]{#1}\\
    #2\\
    \today
  \end{flushright}
}

\renewcommand*{\section}[2][]{%
  \cv@maybe@render@header%
  \cv@render@sectionheading{#2}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CV/Resume Production Commands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Key-value family for \cventry (keyval strips whitespace from key names,
% avoiding the pgfkeys path-prepend-before-strip bug with optional arguments).
\define@key{cventry}{dates}   {\def\cv@entry@dates{#1}}
\define@key{cventry}{title}   {\def\cv@entry@title{#1}}
\define@key{cventry}{org}     {\def\cv@entry@org{#1}}
\define@key{cventry}{location}{\def\cv@entry@location{#1}}
\define@key{cventry}{url}     {\def\cv@entry@url{#1}}
% Default values (also reset at the start of every \cventry call)
\def\cv@entry@dates{}\def\cv@entry@title{}\def\cv@entry@org{}
\def\cv@entry@location{}\def\cv@entry@url{}

\newcommand*{\cvitemize}[1]{
\vspace{-2.0mm}
\begin{itemize}[noitemsep,topsep=0pt,parsep=1pt,partopsep=0pt, leftmargin=*]
#1
\end{itemize}
}

\newcommand*{\cventry}[2][]{%
  \cv@maybe@render@header%
  \def\cv@entry@dates{}\def\cv@entry@title{}\def\cv@entry@org{}%
  \def\cv@entry@location{}\def\cv@entry@url{}%
  \setkeys{cventry}{#1}%
  \cv@render@entry{#2}%
}

\newcommand*{\cvitem}[2]{%
  \cv@maybe@render@header%
  \cv@render@item{#1}{#2}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Cover Letter Keys and Environment
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pgfkeys declarations: establishes the /cv/letter namespace and storage macros.
\pgfkeys{
  /cv/letter/.cd,
  to-name/.store in     = \cv@letter@toname,
  to-address/.store in  = \cv@letter@toaddress,
  subject/.store in     = \cv@letter@subject,
  opening/.store in     = \cv@letter@opening,
  closing/.store in     = \cv@letter@closing,
  signature/.store in   = \cv@letter@signature,
  signature/.initial    = {},
}

% keyval keys used by the coverletter environment for argument parsing.
% pgfkeys' space-stripping is unreliable with multiline optional arguments
% in LuaTeX; \setkeys (keyval) handles this correctly (same as cventry).
\define@key{cvcoverletter}{to-name}   {\def\cv@letter@toname{#1}}
\define@key{cvcoverletter}{to-address}{\def\cv@letter@toaddress{#1}}
\define@key{cvcoverletter}{subject}   {\def\cv@letter@subject{#1}}
\define@key{cvcoverletter}{opening}   {\def\cv@letter@opening{#1}}
\define@key{cvcoverletter}{closing}   {\def\cv@letter@closing{#1}}
\define@key{cvcoverletter}{signature} {\def\cv@letter@signature{#1}}

\newenvironment{coverletter}[1][]{%
  \setkeys{cvcoverletter}{#1}%
  \cv@renderletter@begin
}{%
  \cv@renderletter@end
}

\RequirePackage{themes/\cv@theme}
\ifdefstring{\cv@letterstyle}{none}{}{%
  \RequirePackage{letters/\cv@letterstyle}%
}
