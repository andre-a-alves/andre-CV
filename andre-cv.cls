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
\ExecuteOptions{10pt}
\ProcessOptions
\PassOptionsToClass{\ChosenFontSize}{andre-cv-base}
\relax
\LoadClass{andre-cv-base}

\RequirePackage{datetime2}
\RequirePackage[a4paper, vmargin=16.9mm, hmargin=24.1mm]{geometry}

\setlength{\parindent}{0pt}

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

	function getPictureWidthFromArray(arr)
		if setPictureWidth == 0 then
			return 3 + math.ceil(#arr / 2) * 0.3
		else
			return setPictureWidth
		end
	end

	function setSetPictureWidth(value)
		setPictureWidth = value
	end
\end{luacode}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Headers and Footers
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\pagestyle{fancy}
\fancypagestyle{letter}{\fancyhf{}}
\rhead{\large \textbf{\textsc{\DisplayName}}}
\geometry{vmargin=16.9mm, hmargin=24.1mm, footskip=0.6cm}
\fancypagestyle{noheader}{\fancyhead{}}

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
\newcommand{\picturewidth}{}
\newcommand{\ZeroPictureWidth}{\renewcommand{\picturewidth}{0mm}}
\newcommand{\HeaderImageSizeCm}[1]{\directlua{setSetPictureWidth(#1)}}

\newcommand*{\DisplayHeader}[2]{
	\directlua{
		local pictureWidth = getPictureWidthFromArray(personalDetails)
		tex.sprint("\\renewcommand{\\picturewidth}{" .. pictureWidth .. "cm}")
	}
	\thispagestyle{noheader}
	\ifthenelse{\equal{}{#2}}
		{
			\ZeroPictureWidth
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
\newcommand{\IncludeCVHeaderTable}{
	\directlua{
			printTwoColumnTableFromArray(personalDetails)
	}
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

\newcommand*{\cvpadlessentry}[5]{
  \begin{minipage}{\textwidth}
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
