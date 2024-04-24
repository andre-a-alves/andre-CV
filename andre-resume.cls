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

% Font Size
\DeclareOption{10pt}{\def\ChosenFontSize{10pt}}
\DeclareOption{11pt}{\def\ChosenFontSize{11pt}}
\DeclareOption{12pt}{\def\ChosenFontSize{12pt}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ExecuteOptions{10pt}
\ProcessOptions
\PassOptionsToClass{\ChosenFontSize}{andre-cv-base}
\relax
\LoadClass{andre-cv-base}

\RequirePackage[letterpaper, margin=0.75in]{geometry}
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
\rhead{\ifbool{BadgeToggled}{\InsertBadge}}
\lfoot{\FooterGrayColor\today}
\geometry{includehead, headsep=0.2in, footskip=0.25in}
\fancypagestyle{noheader}{\fancyhead{}}

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Letter Production Commands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand{\MakeCoverLetter}[9]{
	\thispagestyle{letter}
	\newgeometry{margin=0.75in}
	{\Large {\fontseries{m}\selectfont \textsc{#1}}}\\
	#2\\

	\today\\
	
	\textsc{#3}\\
	#4\\

	\textbf{#5}\\

	#6\\

	#7\\

	#8,\\
	\ifthenelse{\equal{#9}{}}
		{\\[3\baselineskip]}
		{\includegraphics[height=3\baselineskip]{#9}\\}
	#1
	\restoregeometry
	\setcounter{page}{1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CV/Resume Production Commands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand*{\cventry}[5]{
	\begin{minipage}{\textwidth}
	\vspace{4mm}
	\setlength\tabcolsep{0pt}
	\setlength{\extrarowheight}{0pt}
	\begin{tabularx}{\textwidth}{X r}
		\large{\textbf{#2}} & \color{accentColor}#1 \\
		\textsc{#3} & {\small #4}
	\end{tabularx}
	#5
	\end{minipage}
}

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
