  %% andre-cv.cls
  %% Copyright 2021 A. A. Alves
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
  % The Current Maintainer of this work is A. A. Alves.
  %
  % This work consists of all files listed in manifest.txt.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{andre-cv}[2021-02-15]

\RequirePackage{etoolbox}
\newbool{EuroFormat}
\newbool{FontChosen}
\booltrue{EuroFormat}
\newcommand{\ChosenFont}{sourcesanspro}
% Fonts
\DeclareOption{roboto}
	{\renewcommand{\ChosenFont}{roboto}
	\booltrue{FontChosen}}
\DeclareOption{firasans}
	{\renewcommand{\ChosenFont}{firasans}
	\booltrue{FontChosen}}
\DeclareOption{sourcesanspro}
	{\booltrue{FontChosen}}
% Format
\DeclareOption{US}{\boolfalse{EuroFormat}}
\DeclareOption{Euro}{\booltrue{EuroFormat}}
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

\RequirePackage[utf8]{inputenc} % for direct use of special characters.
\RequirePackage[T1]{fontenc}    % better font encoding
\RequirePackage[english]{babel} % standard language: British English
\RequirePackage{ifthen}
\ifbool{EuroFormat}
	{\RequirePackage[a4paper, vmargin=16.9mm, hmargin=24.1mm]{geometry}
	\RequirePackage{datetime2}}
	{\RequirePackage[letterpaper, margin=0.75in]{geometry}
	\RequirePackage[en-US, useregional]{datetime2}}
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
\setlength{\parindent}{0pt}

\RequirePackage{calc}
\RequirePackage{multirow}
\RequirePackage{wrapfig}

\newcommand*{\ResetDateFormat}
	{\ifbool{EuroFormat}{\DTMsetdatestyle{iso}}{\DTMsetstyle{en-US}}}

\ResetDateFormat


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Fonts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{moresize}   % more font size definitions
\ifbool{FontChosen}
	{\ifthenelse{\equal{\ChosenFont}{roboto}}
		{\RequirePackage[sfdefault, light]{roboto}}{}
	\ifthenelse{\equal{\ChosenFont}{firasans}}
		{\RequirePackage[sfdefault, light]{FiraSans}}{}
	\ifthenelse{\equal{\ChosenFont}{sourcesanspro}}
		{\RequirePackage[default, light]{sourcesanspro}}{}
	}
	{\RequirePackage[default, light]{sourcesanspro}}
\renewcommand{\bfdefault}{m}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Headers and Footers
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage{fancyhdr}       % necessary for "fancy headers" specificied later
\pagestyle{fancy}
\fancyhf{}
\setlength{\headheight}{50pt}	
\renewcommand{\headrulewidth}{0pt} 
\rfoot{
	\ifnum\ztotpages>1
		{\FooterGrayColor
	{\thepage\ of \zpageref{LastPage}}}
	\else {}
	\fi
}
\fancypagestyle{letter}{\fancyhf{}}
\ifbool{EuroFormat}
	{
		\rhead{\large \textbf{\textsc{\DisplayName}}}
		\geometry{vmargin=16.9mm, hmargin=24.1mm, footskip=0.6cm}
	}
	{
		\chead{\InsertHeader}
		\lfoot{\FooterGrayColor\today}
		\geometry{includehead, headsep=0.2in, footskip=0.25in}
	}
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
\newcommand*{\MakeHeader}[3]
	{\def\InsertHeader
		{\HUGE {\fontseries{m}\selectfont \textsc{#1}}\\
		\small #2 \\
		#3}
	}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Letter Production Commands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand{\MakeCoverLetterEuro}[9]{
	\thispagestyle{letter}
	\begin{flushright}
		{\Large {\fontseries{m}\selectfont \textsc{#1}}}\\
		#2\\		
	\end{flushright}
	\textsc{#3}\\
	#4\\[2\baselineskip]
	\hspace*{\fill}\today\\[2\baselineskip]
	\textbf{#5}\\[2\baselineskip]
	#6\\

	#7\\

	#8,\\
	\ifthenelse{\equal{#9}{}}
		{\\[3\baselineskip]}
		{\includegraphics[height=3\baselineskip]{#9}\\}
	#1
	\newpage
	\setcounter{page}{1}
}

\newcommand{\MakeCoverLetterUS}[9]{
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

\newcommand{\MakeCoverLetter}[9]
	{\ifbool{EuroFormat}
		{\MakeCoverLetterEuro{#1}{#2}{#3}{#4}{#5}{#6}{#7}{#8}{#9}}
		{\MakeCoverLetterUS{#1}{#2}{#3}{#4}{#5}{#6}{#7}{#8}{#9}}
	}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CV/Resume Production Commands
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\tabularColumnWidth}{2.4cm}
\newcommand{\ResizeTabular}[1]{\renewcommand{\tabularColumnWidth}{#1}}
\newcommand{\picturewidth}{6cm}
\newcommand{\ChangePictureWidth}[1]{\renewcommand{\picturewidth}{#1}}
\newcommand{\HeaderImageSize}[1]{\renewcommand{\picturewidth}{#1}}

\newcommand*{\DisplayHeader}[2]{
	\thispagestyle{noheader}
	\ifthenelse{\equal{}{#2}}
		{
			\ChangePictureWidth{0mm}
		}
		{
			\begin{wrapfigure}{r}{\picturewidth}
			\raggedleft
			\includegraphics[height=\picturewidth, width=\picturewidth]{#2}
			\end{wrapfigure}
		}
	\begin{minipage}[t]{\textwidth-\picturewidth}
	{\HUGE {\fontseries{m}\selectfont \textsc{\DisplayName}}}\\
	\vspace{4mm}{\Large \color{gray} \textbf{#1}}

	\cvsection{Personal Details}
	{\cvpara{
		\IncludeCVHeaderTable
	 	\vspace{3mm}}
	}
	\end{minipage}
}
\newcommand{\zerospace}{~\kern -0.2 pc}
\newcommand{\IncludeCVHeaderTable}{
	\begin{tabular}{c l}
		\ifthenelse{\isundefined{\DisplayAddressOne} \and \isundefined{\DisplayAddressTwo} \and \isundefined{\DisplayAddressThree}}
			{\zerospace}
			{\faMapMarker &
				\ifthenelse{\isundefined{\DisplayAddressOne}}
					{\zerospace}
					{\DisplayAddressOne
					\ifthenelse{\isundefined{\DisplayAddressTwo} \and \isundefined{\DisplayAddressThree}}
						{\zerospace}
						{,}
					} 
					\ifthenelse{\isundefined{\DisplayAddressTwo}}
						{\zerospace}
						{\DisplayAddressTwo
							\ifthenelse{\isundefined{\DisplayAddressThree}}
								{\zerospace}
								{,}
							} 
				\ifthenelse{\isundefined{\DisplayAddressThree}}
					{\zerospace}
					{\DisplayAddressThree} 
			\\}
		\ifthenelse{\isundefined{\DisplayPhone}}
			{\zerospace}
			{\faMobile & \DisplayPhone \\}
		\ifthenelse{\isundefined{\DisplayEmail}}
			{\zerospace}
			{\faEnvelope & \DisplayEmail \\}
		\ifthenelse{\isundefined{\DisplayCitizenship}}
			{\zerospace}
			{\faHome & \DisplayCitizenship \\}
		\ifthenelse{\isundefined{\DisplayDPOB}}
			{\zerospace}
			{\faBirthdayCake & \DisplayDPOB \\}
		\ifthenelse{\isundefined{\DisplayMaritalStatus}}
			{\zerospace}
			{\faHeart & \DisplayMaritalStatus \\}
		\ifthenelse{\isundefined{\DisplayFamilySize}}
			{\zerospace}
			{\faChild & \DisplayFamilySize \\}
		\ifthenelse{\isundefined{\DisplayGithub}}
			{\zerospace}
			{\faGithub & \DisplayGithub \\}
		\ifthenelse{\isundefined{\DisplayLinkedIn}}
			{\zerospace}
			{\faLinkedin & \DisplayLinkedIn \\}
		\ifthenelse{\isundefined{\DisplayXing}}
			{\zerospace}
			{\faXing & \DisplayXing \\}
		\ifthenelse{\isundefined{\DisplayHomepage}}
			{\zerospace}
			{\faLaptop & \DisplayHomepage \\}
	\end{tabular}
}

\newcommand*{\cvsection}[2]{
	\vspace{2mm}
	{\Large \color{accentColor} \fontseries{sb}\selectfont{#1}}
	{\textcolor{light_gray}\hrulefill}
	\vspace{-2mm}
	\begin{cventries}
	#2	
	\end{cventries}
}

\newcommand*{\cventry}[5]{
	\begin{minipage}{\textwidth}
	\vspace{4mm}
	\setlength\tabcolsep{0pt}
	\setlength{\extrarowheight}{0pt}
	\ifbool{EuroFormat}
		{
			\begin{tabularx}{\textwidth}{ l X }
			\multirow[t]{2}{\tabularColumnWidth}{{\large \textbf{#1}}~\hspace{3mm}} & \large{\textbf{#2}} \hfill {\small #4}\\
			& \textsc{#3} \\
			& #5	
			\end{tabularx}
			\vspace{-4mm}
		}
		{
			\begin{tabularx}{\textwidth}{X r}
				\large{\textbf{#2}} & \color{accentColor}#1 \\
				\textsc{#3} & {\small #4}
			\end{tabularx}
			#5
		}	
	\end{minipage}
}

\newcommand*{\cvitemize}[1]{
	\vspace{-2.0mm}
	\begin{itemize}[noitemsep,topsep=0pt,parsep=1pt,partopsep=0pt, leftmargin=*]
		#1
	\end{itemize}
}
\newenvironment{cventries}
	{\vspace{-1mm}\begin{flushleft}}
	{\end{flushleft}}

\newcommand*{\cvlistitem}[3]{
	\vspace{1.5mm}
	\setlength\tabcolsep{0pt}
	\setlength{\extrarowheight}{0pt}
	\ifbool{EuroFormat}
		{	\begin{tabularx}{\textwidth}{p{\tabularColumnWidth} X}
			\raggedright \ifthenelse{\equal{#3}{}}
				{\textbf{#1}}
				{\href{#3}{\textbf{#1}}}
				& #2 \\
		\end{tabularx}\\}
		{\begin{tabularx}{\textwidth}{l l X}
			\ifthenelse{\equal{#3}{}}
				{\textbf{#1}}
				{\href{#3}{\textbf{#1}}}
				& \hspace{0.3cm} & #2 \\
		\end{tabularx}\\}
}

\newcommand*{\cvpara}[1]{\vspace{3mm}#1}
\newcommand*{\cvsectionlist}[1]{\vspace{1.5mm}#1}

\newcommand*{\cvtabularlist}[1]{
	\vspace{3mm}
	\setlength\tabcolsep{0pt}
	\setlength{\extrarowheight}{0pt}
	\raggedright
	\begin{tabularx}{\textwidth}{l l X}
		#1
	\end{tabularx}
}

\newcommand*{\tabularitem}[2]{
	\textbf{#1} & \hspace{3mm} & #2 \vspace{2mm}\\
}

\newcommand*{\DisplaySignature}[2]
		{
			\bigskip
			\begin{minipage}{.5\textwidth}
				\hspace{0cm}
			\end{minipage}
			\begin{minipage}{.5\textwidth}
				\includegraphics[width=5cm]{#1} \\
				#2 \\
				\today
			\end{minipage}
		}