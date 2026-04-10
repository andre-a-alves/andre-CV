  %% andre-resume.cls
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
\ProvidesClass{andre-resume}[2024-02-18]

\RequirePackage{etoolbox}

% Declare booleans
\newbool{FontChosen}
\newbool{BadgeToggled}
\newcommand{\InsertHeader}{}

% Font Size
\DeclareOption{10pt}{\def\ChosenFontSize{10pt}}
\DeclareOption{11pt}{\def\ChosenFontSize{11pt}}
\DeclareOption{12pt}{\def\ChosenFontSize{12pt}}

% Forward unknown options (paper size, language, etc.) to the base class.
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{andre-cv-base}}
\ExecuteOptions{10pt}
\ProcessOptions\relax
\PassOptionsToClass{\ChosenFontSize}{andre-cv-base}
% Default paper/language for andre-resume (overridden by user options
% processed inside the base class).
\def\cv@papersize{letterpaper}
\def\cv@language{english}
\def\cv@babellang{english}
\LoadClass{andre-cv-base}

\RequirePackage[\cv@papersize, margin=0.75in]{geometry}
\RequirePackage[en-US, useregional]{datetime2}

\setlength{\parindent}{0pt}
\DTMsetstyle{en-US}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Parameter Declaration Commands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand*{\MakeHeader}[3]
	{\def\InsertHeader
		{\HUGE \textsc{#1}\\
		\small #2 \\
		#3}
	}

\newcommand*{\SetBadge}[2]
  	{\booltrue{BadgeToggled}
	\def\InsertBadge{\includegraphics[scale=#1]{#2}}
	}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Headers and Footers
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage{tikz}			% for placing an icon in the corner of the page
\pagestyle{fancy}
\fancypagestyle{letter}{\fancyhf{}}
\chead{\InsertHeader}
\rhead{\ifbool{BadgeToggled}{\InsertBadge}{}}
\lfoot{\FooterGrayColor{\today}}
\geometry{includehead, headsep=0.2in, footskip=0.25in}
\fancypagestyle{noheader}{\fancyhead{}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Letter Production Commands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand{\cv@renderletter@begin}{%
	\thispagestyle{letter}%
	\newgeometry{margin=0.75in}%
	{\Large {\fontseries{m}\selectfont \textsc{\DisplayName}}}\\
	\@ifundefined{DisplayAddressOne}{}{\DisplayAddressOne\\}%
	\@ifundefined{DisplayAddressTwo}{}{\DisplayAddressTwo\\}%
	\@ifundefined{DisplayAddressThree}{}{\DisplayAddressThree\\}%
	\@ifundefined{DisplayPhone}{}{\DisplayPhone\\}%
	\@ifundefined{DisplayEmail}{}{\DisplayEmail\\}%

	\today\\

	\textsc{\cv@letter@toname}\\
	\cv@letter@toaddress\\

	\textbf{\cv@letter@subject}\\

	\cv@letter@opening\\

}

\newcommand{\cv@renderletter@end}{%
	\par
	\cv@letter@closing,\\
	\ifthenelse{\equal{\cv@letter@signature}{}}%
		{\\[3\baselineskip]}%
		{\includegraphics[height=3\baselineskip]{\cv@letter@signature}\\}%
	\DisplayName
	\restoregeometry
	\setcounter{page}{1}%
}

% Deprecated: use the coverletter environment instead.
\newcommand{\MakeCoverLetter}[9]{%
	\ClassWarning{andre-resume}{\noexpand\MakeCoverLetter is deprecated; use the coverletter environment instead}%
	\begin{coverletter}[%
		to-name    = {#3},%
		to-address = {#4},%
		subject    = {#5},%
		opening    = {#6},%
		closing    = {#8},%
		signature  = {#9}%
	]%
	#7%
	\end{coverletter}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CV/Resume Production Commands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Key-value interface: \cventry[dates=, title=, org=, location=, url=]{body}
\newcommand*{\cventry}[2][]{%
	\def\cv@entry@dates{}\def\cv@entry@title{}\def\cv@entry@org{}%
	\def\cv@entry@location{}\def\cv@entry@url{}%
	\setkeys{cventry}{#1}%
	\begin{minipage}{\textwidth}
	\vspace{4mm}%
	\setlength\tabcolsep{0pt}%
	\setlength{\extrarowheight}{0pt}%
	\begin{tabularx}{\textwidth}{X r}
		\large{\textbf{%
			\ifthenelse{\equal{\cv@entry@url}{}}%
				{\cv@entry@title}%
				{\href{\cv@entry@url}{\cv@entry@title}}%
		}} & \color{accentColor}\cv@entry@dates \\
		\textsc{\cv@entry@org} & {\small \cv@entry@location}
	\end{tabularx}
	#2
	\end{minipage}
}

% Deprecated: old five-argument positional interface
\newcommand*{\cventrylegacy}[5]{%
	\begin{minipage}{\textwidth}
	\vspace{4mm}%
	\setlength\tabcolsep{0pt}%
	\setlength{\extrarowheight}{0pt}%
	\begin{tabularx}{\textwidth}{X r}
		\large{\textbf{#2}} & \color{accentColor}#1 \\
		\textsc{#3} & {\small #4}
	\end{tabularx}
	#5
	\end{minipage}
}

% Deprecated: use \cvitem instead
\newcommand*{\cvlistitem}[3]{
	\vspace{1.5mm}
	\setlength\tabcolsep{0pt}
	\setlength{\extrarowheight}{0pt}
	\begin{tabularx}{\textwidth}{l l X}
		\ifthenelse{\equal{#3}{}}
			{\textbf{#1}}
			{\href{#3}{\textbf{#1}}}
			& \hspace{0.3cm} & #2 \\
	\end{tabularx}\\
}

% Lightweight label-value pair; replaces \cvlistitem
\newcommand*{\cvitem}[2]{%
	\vspace{1.5mm}%
	\setlength\tabcolsep{0pt}%
	\setlength{\extrarowheight}{0pt}%
	\begin{tabularx}{\textwidth}{l l X}%
		\textbf{#1} & \hspace{0.3cm} & #2 \\
	\end{tabularx}%
}
