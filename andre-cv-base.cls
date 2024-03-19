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
\newcommand{\FooterGrayColor}[1]{\color{gray} #1}
\newcommand*{\SetName}[1]{\def\DisplayName{#1}}
\newcommand*{\SetAddressOne}[1]{\def\DisplayAddressOne{#1}}
\newcommand*{\SetAddressTwo}[1]{\def\DisplayAddressTwo{#1}}
\newcommand*{\SetAddressThree}[1]{\def\DisplayAddressThree{#1}}
\newcommand*{\SetDPOB}[1]{\def\DisplayDPOB{#1}}
\newcommand*{\SetTown}[1]{\def\DisplayTown{#1}}
\newcommand*{\SetEmail}[1]{\def\DisplayEmail{\href{mailto:#1}{#1}}}
\newcommand*{\SetCitizenship}[1]{\def\DisplayCitizenship{#1}}
\newcommand*{\SetMaritalStatus}[1]{\def\DisplayMaritalStatus{#1}}
\newcommand*{\SetFamilySize}[1]{\def\DisplayFamilySize{#1}}
\newcommand*{\SetGithub}[1]
{\def\DisplayGithubIcon{\faGithub\href{https://github.com/#1}{~#1}}
\def\DisplayGithub{\href{https://github.com/#1}{~#1}}}
\newcommand*{\SetLinkedIn}[1]
{\def\DisplayLinkedInIcon{\faLinkedin\href{https://linkedin.com/in/#1}{~#1}}
\def\DisplayLinkedIn{\href{https://linkedin.com/in/#1}{~#1}}}
\newcommand*{\SetXing}[1]
{\def\DisplayXingIcon{\faXing\href{https://www.xing.com/profile/#1}{~#1}}
\def\DisplayXing{\href{https://www.xing.com/profile/#1}{~#1}}}
\newcommand*{\SetHomepage}[1]
{\def\DisplayHomepageIcon{\faLaptop\href{https://#1}{~#1}}
\def\DisplayHomepage{\href{https://#1}{~#1}}}
\newcommand*{\SetPhone}[1]{\def\DisplayPhone{#1}}