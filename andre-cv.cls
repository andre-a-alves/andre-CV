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
\ProvidesClass{andre-cv}[2024-03-19]

\RequirePackage{etoolbox}

% Font Size
\DeclareOption{10pt}{\def\ChosenFontSize{10pt}}
\DeclareOption{11pt}{\def\ChosenFontSize{11pt}}
\DeclareOption{12pt}{\def\ChosenFontSize{12pt}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ExecuteOptions{11pt}
\ProcessOptions
\PassOptionsToClass{\ChosenFontSize}{andre-cv-base}
\relax
\LoadClass{andre-cv-base}

\RequirePackage[a4paper, vmargin=16.9mm, hmargin=24.1mm]{geometry}

\setlength{\parindent}{0pt}
\RequirePackage{wrapfig}

\DTMsetdatestyle{iso}

\begin{luacode}
	function printTwoColumnTableFromArray(arr)
		function printLineWithTwoItems(index, middleIndex)
			tex.sprint(arr[index]["icon"] .. "&" .. arr[index]["value"] .. "& \\hspace{2.5em}" .. arr[middleIndex + index]["icon"] .. "&" .. arr[middleIndex + index]["value"] .. "\\\\" )
		end

		local length = #arr
		local middle = math.ceil(length / 2)
		local i = 1

		tex.sprint("\\begin{tabular}{c l c l}")

		while i < middle do
			printLineWithTwoItems(i, middle)
			i = i + 1
		end
		if length % 2 == 1 then
			tex.sprint(arr[i]["icon"] .. "&" .. arr[i]["value"] .. "\\\\" )
		else
			printLineWithTwoItems(i, middle)
		end

		tex.sprint("\\end{tabular}")
	end
\end{luacode}

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
\rhead{\large \textbf{\textsc{\DisplayName}}}
\geometry{vmargin=16.9mm, hmargin=24.1mm, footskip=0.6cm}
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
	\newgeometry{top=2cm, right=2cm, left=2.5cm, bottom=2cm}
	\begin{flushright}
	{\Large \textsc{#1}}\\
	#2\\
	\end{flushright}

	\vspace{2\baselineskip} % skip three lines

	\textsc{#3}\\
	#4\\[\baselineskip] % skip three lines

	\begin{flushright}
		\today
	\end{flushright}

	\vspace{\baselineskip} % skip two lines

	\textbf{#5}\\[\baselineskip] % skip two lines

	#6\\ % greeting

	#7\\ % body

	#8,\\ % salutation

	% Signature if included
	\ifthenelse{\equal{#9}{}}
		{\\[3\baselineskip]}
		{\includegraphics[height=3\baselineskip]{#9}\\}
	#1 % name
	\newpage
	\setcounter{page}{1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CV Production Commands
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
			\vspace{-1.5em}
			\raggedleft
			\includegraphics[height=\picturewidth, width=\picturewidth]{#2}
			\end{wrapfigure}
		}
	\begin{minipage}[t]{\textwidth-\picturewidth}
	{\HUGE \textsc{\DisplayName}}\\
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
	\directlua{
			printTwoColumnTableFromArray(personalDetails)
	}
}

\newcommand*{\cvsection}[2]{
	\vspace{2mm}
	{\large \color{accentColor} \textbf{#1}}
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
	\begin{tabularx}{\textwidth}{ l X }
	\multirow[t]{2}{\tabularColumnWidth}{{#1}~\hspace{3mm}} & {\textbf{#2}} \hfill {\small #4}\\
	& \textsc{#3} \\
	& #5
	\end{tabularx}
	\vspace{-4mm}
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
	\begin{tabularx}{\textwidth}{p{\tabularColumnWidth} X}
		\raggedright \ifthenelse{\equal{#3}{}}
			{\textbf{#1}}
			{\href{#3}{\textbf{#1}}}
			& #2 \\
	\end{tabularx}\\
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