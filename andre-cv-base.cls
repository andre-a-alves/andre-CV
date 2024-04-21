%! Class = CLASS_NAME
%! Author = andre
%! Date = 2/18/24

\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{andre-cv-base}[andre's Document Class]

% Font Size
\DeclareOption{10pt}{\def\ChosenFontSize{10pt}}
\DeclareOption{11pt}{\def\ChosenFontSize{11pt}}
\DeclareOption{12pt}{\def\ChosenFontSize{12pt}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ExecuteOptions{11pt}
\ProcessOptions
\PassOptionsToClass{\ChosenFontSize}{article}
\relax
\LoadClass{article}

%\RequirePackage[utf8]{inputenc} % for direct use of special characters.
\RequirePackage[T1]{fontenc}    % better font encoding
\RequirePackage[english]{babel} % standard language: British English
\RequirePackage{fontspec}
\RequirePackage{ifthen}
\RequirePackage{datetime2}
\RequirePackage{hyperref}
\hypersetup{
    colorlinks=true,  % activate colours
    linkcolor=black,  % for internal links use black
    citecolor=black,  % for citations to reference list use black
    urlcolor=black    % for external links use black
}
\RequirePackage{tabularx}
\RequirePackage{graphicx}
\RequirePackage{enumitem}
\RequirePackage{lipsum}
\RequirePackage[totpages,lastpage,user]{zref}
\RequirePackage{fontawesome}
\RequirePackage{calc}
\RequirePackage{multirow}
\RequirePackage{luacode} % for use of Lua code

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
\end{luacode}

\newcommand{\FooterGrayColor}[1]{\color{gray} #1}
\newcommand*{\SetName}[1]{\def\DisplayName{#1}}
\newcommand*{\SetAddressOne}[1]{\def\DisplayAddressOne{#1}}
\newcommand*{\SetAddressTwo}[1]{\def\DisplayAddressTwo{#1}}
\newcommand*{\SetAddressThree}[1]{\def\DisplayAddressThree{#1}}
\newcommand*{\SetTown}[1]{
    \def\DisplayTown{#1}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayTown",
            icon = "\\faMapMarker",
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
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetCitizenship}[1]{
    \def\DisplayCitizenship{#1}
    \directlua{
            personalDetails[personalDetailsIndex] = {
                value = "\\DisplayCitizenship",
                icon = "\\faHome",
            }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetGithub}[1]{
    \def\DisplayGithubIcon{\faGithub\href{https://github.com/#1}{~#1}}
    \def\DisplayGithub{\href{https://github.com/#1}{~#1}}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayGithub",
            icon = "\\faGithub",
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetLinkedIn}[1]{
    \def\DisplayLinkedInIcon{\faLinkedin\href{https://linkedin.com/in/#1}{~#1}}
    \def\DisplayLinkedIn{\href{https://linkedin.com/in/#1}{~#1}}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayLinkedIn",
            icon = "\\faLinkedin",
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetXing}[1]{
    \def\DisplayXingIcon{\faXing\href{https://www.xing.com/profile/#1}{~#1}}
    \def\DisplayXing{\href{https://www.xing.com/profile/#1}{~#1}}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayXing",
            icon = "\\faXing",
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}
\newcommand*{\SetHomepage}[1]{
    \def\DisplayHomepageIcon{\faLaptop\href{https://#1}{~#1}}
    \def\DisplayHomepage{\href{https://#1}{~#1}}
    \directlua{
        personalDetails[personalDetailsIndex] = {
            value = "\\DisplayHomepage",
            icon = "\\\faLaptop",
        }
        personalDetailsIndex = personalDetailsIndex + 1
    }
}