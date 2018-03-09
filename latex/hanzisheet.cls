\NeedsTeXFormat{LaTeX2e}[1994/06/01]
\ProvidesClass{hanzisheet}[2017/03/08 Hanzisheet]

%% Article options
\DeclareOption{10pt}{
	\PassOptionsToClass{\CurrentOption}{article}
}

%% Custom package options
\DeclareOption{sans}{
	\PassOptionsToPackage{\CurrentOption}{custom}
}
\DeclareOption{neverindent}{
	\PassOptionsToPackage{\CurrentOption}{custom}
}

%% Fallback
\DeclareOption*{
	\ClassWarning{hanzisheet}{Unknown option '\CurrentOption'}
}

%% Process given options
\ProcessOptions\relax

%% Load base
\LoadClass[a4paper,oneside,11pt]{article}

\RequirePackage[top=2.5cm,bottom=1.5cm,left=2.5cm,right=2cm,headsep=1cm,footskip=0pt]{geometry}
\RequirePackage{tikz}
\usetikzlibrary{decorations}
\usetikzlibrary{shapes.geometric}
\usetikzlibrary{positioning}
\RequirePackage{xstring,xifthen,stringstrings}

\RequirePackage[UTF8]{ctex}

\RequirePackage{lastpage}
\RequirePackage{fancyhdr}

\RequirePackage[utf8]{inputenc} %for pinyin

\RequirePackage{keyval,xparse} % for key value arguments
\pagestyle{fancy} %todo: do we need this?

%used as tmp color%
\definecolor{character_color}{RGB}{170,170,170}

% \noindent for all paragraphs
\setlength{\parindent}{0pt}

% Switch
% https://tex.stackexchange.com/questions/64131/implementing-switch-cases
\newcommand{\ifequals}[3]{\ifthenelse{\equal{#1}{#2}}{#3}{}}
\newcommand{\case}[2]{#1 #2} % Dummy, so \renewcommand has something to overwrite...
\newenvironment{switch}[1]{\renewcommand{\case}{\ifequals{#1}}}{}

% Options for hanzibox command
\define@key{hanzibox}{inner}{\def\mm@in{#1}}
\define@key{hanzibox}{border}{\def\mm@bo{#1}}
\define@key{hanzibox}{borderWidth}{\def\mm@bw{#1}}
\define@key{hanzibox}{borderColor}{\def\mm@bc{#1}}
\define@key{hanzibox}{pinyin}{\def\mm@pin{#1}}
\define@key{hanzibox}{character}{\def\mm@char{#1}}
\define@key{hanzibox}{translation}{\def\mm@tran{#1}}

% Definitions of Pinyin
\makeatletter
	
\def\py@yunpriv#1{%
	\if a#1 10\else
	\if o#1 9\else
	\if e#1 8\else
	\if i#1 7\else
	\if u#1 6\else
	\if v#1 5\else
	\if A#1 4\else
	\if O#1 3\else
	\if E#1 2\fi\fi\fi\fi\fi\fi\fi\fi\fi0
}

\def\py@init{%
	\edef\py@befirst{}%
	\edef\py@char{}\edef\py@tuneletter{}%
	\def\py@last{}%
	\def\py@tune{5}%
}

% Usage:
% \pinyin{Hao3hao3\ xue2xi2} （好好学习）
\def\pinyin#1{%
	\edef\py@postscan{#1}%
	\py@init
	% scan
	\loop
	\edef\py@char{\expandafter\@car\py@postscan\@nil}%
	\edef\py@postscan{\expandafter\@cdr\py@postscan\@nil}%
	\ifnum 0 < 0\py@char
	\edef\py@tune{\py@char}%
	\py@first \py@tuneat\py@tuneletter\py@tune \py@last\kern -4sp\kern 4sp{}\py@init
	\else
	\ifnum\py@yunpriv\py@char > \py@yunpriv\py@tuneletter
	\edef\py@tuneletter{\py@char}\edef\py@first{\py@befirst}\def\py@last{}%
	\else
	\edef\py@last{\py@last\if v\py@char\"u\else\py@char\fi}%
	\fi
	\edef\py@befirst{\py@befirst\if v\py@char\"u\else\py@char\fi}%
	\fi
	\ifx\py@postscan\@empty\else
	\repeat
}

\let\py@macron \=
\let\py@acute \'
\let\py@hacek \v
\let\py@grave \`

%% \py@tuneat{Letter}{tune}
\def\py@tuneat#1#2{%
	\if v#1%
	\py@tune@v #2%
	\else
	\if i#1%
	\py@tune@i #2%
	\else
	\ifcase#2%
	\or\py@macron #1\or\py@acute #1\or\py@hacek #1\or\py@grave #1\else #1%
	\fi
	\fi\fi
}

\def\py@tune@v#1{{%
		\dimen@ii 1ex%
		\fontdimen5\font 1.1ex%
		\rlap{\"u}%
		\fontdimen5\font .6ex%
		\ifcase#1%
		\or\py@macron u\or\py@acute u\or\py@hacek u\or\py@grave u\else u%
		\fi
		\fontdimen5\font\dimen@ii
}}

\def\py@tune@i#1{%
	\ifcase#1
	\or\py@macron \i\or\py@acute \i\or\py@hacek \i\or\py@grave \i\else i%
	\fi
}
\makeatletter
% End of pinyin

\tikzset{%
	stretch dash/.code args={on #1 off #2}{%
		\tikz@addoption{%
			\pgfgetpath\currentpath%
			\pgfprocessround{\currentpath}{\currentpath}%
			\pgf@decorate@parsesoftpath{\currentpath}{\currentpath}%
			\pgfmathparse{max(round((\pgf@decorate@totalpathlength-#1)/(#1+#2)),0)}%
			\let\npattern=\pgfmathresult%
			\pgfmathparse{\pgf@decorate@totalpathlength/(\npattern*(#1+#2)+#1)}%
			\let\spattern=\pgfmathresult%
			\pgfsetdash{{\spattern*#1}{\spattern*#2}}{0pt}%
		}%
	}%
}

\newcommand\hanzidialog[3]{%
	\tikz[scale=0.5, every node/.style={inner sep=0,outer sep=0}]{%
		{\node[] at (1,1){\huge#2};}%
		%\StrLen{#1}[\MyStrLen]
		%\ifthenelse{\MyStrLen > 4}% we compare the length of the string with 6
		%{\node[anchor=south, align=center] {\strut\small\mbox{#1}};}%
		%{\node[above of charr, anchor=south, align=center] at (1,2){\strut#1};}%
		{\node[label={\strut\small\textbf{#1}}, text height=1cm] (charr) at (1,1){};}%
		%{\node[right=0 of charr] {:};}%
		{\node[align=center] at (1,-0.2){\strut\tiny\textit{#3}};}%
	}%
}%

\newcommand\drawhanzibox[5]{%
	\tikz[scale=0.5, every node/.style={inner sep=0,outer sep=0}]{%
		%\draw[cheating dash=on 2pt off 2pt distance 2pt,thin,gray](0,0)grid(2,2);%
		\ifthenelse{\equal{#4}{star}}
		{
			\draw[stretch dash=on 2pt off 2pt,thin,gray](0,0)--(2,2);%
			\draw[stretch dash=on 2pt off 2pt,thin,gray](0,2)--(2,0);%
			
			\draw[stretch dash=on 2pt off 2pt,thin,gray](0,1)--(2,1);%
			\draw[stretch dash=on 2pt off 2pt,thin,gray](1,0)--(1,2);%
		}
		{
			\ifthenelse{\equal{#4}{cross}}
			{	
				\draw[stretch dash=on 2pt off 2pt,thin,gray](0,1)--(2,1);%
				\draw[stretch dash=on 2pt off 2pt,thin,gray](1,0)--(1,2);%
			}
			{}%
		}%
		\ifthenelse{\equal{#5}{yes}}{\draw[thin, black] (0,0) rectangle(2,2.1);}{}%
		{\node[] at (1,1){\huge#2};}%
		{\node[label={\strut\small#1}, text height=1cm] (charr) at (1,1){};}%
		%\StrLen{#1}[\MyStrLen]% we find the length of the string and store it in \MyStrLen
		%\ifthenelse{\MyStrLen > 4}% we compare the length of the string with 6
		%{\node[anchor=south, text width=1cm, align=center] at (1,2){\strut\small\pinyin{#1}};}%
		%{\node[anchor=south, text width=1cm, align=center] at (1,2){\strut\pinyin{#1}};}%
		%{\node[label={\small#1}, text height=1cm] at (1,1){};}%
		%{\node[] (charr) at (1,1){\huge#2};}%
		%{\node[label={\small#1}, text height=1cm] (charr) at (1,1){};}%
		%{\node[character_color, text width=1cm, align=center] at (1,1){\huge#2};}%
		{\node[align=center] at (1,-0.2){\strut\tiny\textit{#3}};}%
	}%
}%

%\define@key{hanzibox}{inner}{\def\mm@in{#1}}
%\define@key{hanzibox}{borderWidth}{\def\mm@bw{#1}}
%\define@key{hanzibox}{borderColor}{\def\mm@bc{#1}}
%\define@key{hanzibox}{pinyin}{\def\mm@pin{#1}}
%\define@key{hanzibox}{char}{\def\mm@char{#1}}
%\define@key{hanzibox}{translation}{\def\mm@tran{#1}}
%\definecolor{character_color}{RGB}{170,170,170}
\newcommand\hanzibox[2]{%
	\begingroup%
		% ========= KEY DEFAULTS + new ones =========
		\setkeys{hanzibox}{pinyin={},character={},translation={},#1}%
		\setkeys{hanzibox}{inner={star},border=yes,borderWidth={0.4pt},borderColor={0,0,0},#2}%
		\definecolor{character_color}{RGB}{\mm@bc}%
		\StrLen{\mm@pin}[\pinlen]%
		\drawhanzibox{\ifthenelse{\pinlen = 0}{\mm@pin}{\pinyin{\mm@pin}}}{\mm@char}{\mm@tran}{\mm@in}{\mm@bo}%
	\endgroup%
}
\endinput