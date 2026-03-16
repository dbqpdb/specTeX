# specTeX.praat — Export waveform, spectrogram, and TextGrid
# data from a Praat editor window for use in LaTeX figures
# via the specTeX.sty package.
#
# Requires Praat 6.x or later.
#
# 2013–2026 Dan Brenner
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

clearinfo

outfile$ = chooseWriteFile$: "Choose figure data file for writing...", "praatfig.tex"
wffile$ = replace_regex$: outfile$, "\.\w+?$", "_wf.pdf", 1
specfile$ = replace_regex$: outfile$, "\.\w+?$", "_spec.pdf", 1
start = Get start of selection
end = Get end of selection
editorInfo$ = Editor info
specFreqMin = extractNumber: editorInfo$, "Spectrogram view from: "
specFreqMax = extractNumber: editorInfo$, "Spectrogram view to: "
endeditor
s$ = selected$: "Sound"
sound = selected: "Sound"
tg = selected: "TextGrid"
selectObject: tg
numtiers = Get number of tiers

defnum = 0
for i to numtiers
	defnum = defnum + i * 10 ^ (numtiers - i)
endfor
beginPause: "Specfigure options"
	comment: "Tiers to print in the figure (0 for none): "
	natural: "Tiers", defnum
	comment: "Image width (inches): "
	real: "Imgwidth", 6
	comment: "Image height (inches)"
	real: "Imgheight", 1.5
endPause: "OK", 1

selectObject: sound
wfMin = Get minimum: start, end, "Sinc70"
wfMax = Get maximum: start, end, "Sinc70"
Extract part: start, end, "rectangular", 1.0, "yes"
soundForDrawing = selected: "Sound"
Erase all
Select inner viewport: 0, imgwidth, 0, imgheight

Draw: start, end, wfMin, wfMax, "no", "Curve"
Save as PDF file: wffile$
Erase all
Select outer viewport: 0, imgwidth, 0, imgheight
To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
Paint: 0.0, 0.0, 0.0, 0.0, 100.0, "yes", 50.0, 6.0, 0.0, "no"
Save as PDF file: specfile$
Erase all
plusObject: soundForDrawing
Remove

selectObject: tg

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# TeX: Set X & Y units for positioning. Begin figure. Insert images, add axes.
xdenom = end - start
ywfdenom = wfMax - wfMin
yspecdenom = specFreqMax - specFreqMin

appendFile: outfile$, tab$, "\setlength\imagewidth{", fixed$: imgwidth, 0, "in}", newline$
appendFile: outfile$, tab$, "\setlength\imageheight{", fixed$: imgheight, 1, "in}", newline$
appendFile: outfile$, tab$, "% Waveform & axes", newline$
appendFile: outfile$, tab$, "\node[anchor=south west,inner sep=0cm] at (0,0) {\includegraphics[clip=true, trim=0.583333in 0.388888in 0.583333in 0.388888in, width=\imagewidth,height=\imageheight]{", wffile$, "}};", newline$
appendFile: outfile$, tab$, "\node[anchor=east,fill=white,inner sep=1pt] at (0,0) {", fixed$: wfMin, 3, "};", newline$
appendFile: outfile$, tab$, "\node[anchor=east,fill=white,inner sep=1pt] at (0,\imageheight) {", fixed$: wfMax, 3, "};", newline$
appendFile: outfile$, tab$, "\node[anchor=base,rotate=90,fill=white,inner sep=1pt] at (-8pt,\imageheight/2) {Pressure (Pa)};", newline$
appendFile: outfile$, newline$
appendFile: outfile$, tab$, "% Spectrogram & axes", newline$
appendFile: outfile$, tab$, "\node[anchor=north west,inner sep=0cm] at (0,0) {\includegraphics[clip=true, trim=0.583333in 0.388888in 0.583333in 0.388888in, width=\imagewidth,height=\imageheight]{", specfile$, "}};", newline$
appendFile: outfile$, tab$, "\node[anchor=west,fill=white,inner sep=1pt] at (\imagewidth,0) {", fixed$: specFreqMax, 0, "};", newline$
appendFile: outfile$, tab$, "\node[anchor=west,fill=white,inner sep=1pt] at (\imagewidth,-\imageheight) {", fixed$: specFreqMin, 0, "};", newline$
appendFile: outfile$, tab$, "\node[anchor=base,rotate=270,fill=white,inner sep=1pt] at (\imagewidth + 8pt,-\imageheight/2) {Frequency (Hz)};", newline$
appendFile: outfile$, newline$
appendFile: outfile$, tab$, "% Time axis", newline$
appendFile: outfile$, tab$, "\node[anchor=base,fill=white,inner sep=1pt] at (0,-\imageheight - \labheight) {", fixed$: start, 3, "};", newline$
appendFile: outfile$, tab$, "\node[anchor=base,fill=white,inner sep=1pt] at (\imagewidth,-\imageheight - \labheight) {", fixed$: end, 3, "};", newline$
appendFile: outfile$, tab$, "\node[anchor=base,fill=white,inner sep=1pt] at (\imagewidth/2,-\imageheight - \labheight) {Time (s)};", newline$

if tiers != 0
	tiers$ = string$: tiers
	tiers$ = replace$: tiers$, "[^123456789]", "", 0

	# Number of selected tiers
	numthesetiers = length: tiers$
	for z to numthesetiers
		# z is the position within selected tiers
		t$ = mid$: tiers$, z, 1
		t = number: t$
		dashfactor = 1 / z

		# A multiplier for tier height above the waveform.
		intlevel = numthesetiers - z
		selectObject: tg
		iit = Is interval tier: t
		if iit
			appendFile: outfile$, "% Interval labels for tier ", t$, " (tier ", string$: z, " in image)", newline$
			startint = Get interval at time: t, start
			intstart = Get start time of interval: t, startint
			if start == intstart
				fromint = startint
			else
				fromint = startint + 1
			endif
			endint = Get interval at time: t, end
			toint = endint - 1
			lastx = -1
			for i from fromint to toint
				selectObject: tg
				starttime = Get start time of interval: t, i
				relstart = starttime - start
				endtime = Get end time of interval: t, i
				relend = endtime - start
				text$ = Get label of interval: t, i
				texttime = starttime + (endtime - starttime) / 2
				reltexttime = texttime - start
				if text$ != ""
					if endtime == lastx
						appendFile: outfile$, tab$, "\draw[line width=", fixed$: dashfactor, 1, "\dashing/2] (", string$: relstart, "\imagewidth/", string$: xdenom, ",\imageheight + ", string$: intlevel, "\intheight + 0.7\intheight + 3pt) -- (", string$: relend, "\imagewidth/", string$: xdenom, ",\imageheight + ", string$: intlevel, "\intheight + 0.7\intheight + 3pt) -- (", string$: relend, "\imagewidth/", string$: xdenom, ",\imageheight - \dashintoimage*2\imageheight);", newline$
					else
						appendFile: outfile$, tab$, "\draw[line width=", fixed$: dashfactor, 1, "\dashing/2] (", string$: relstart, "\imagewidth/", string$: xdenom, ",\imageheight - \dashintoimage*2\imageheight) -- (", string$: relstart, "\imagewidth/", string$: xdenom, ",\imageheight + ", string$: intlevel, "\intheight + 0.7\intheight + 3pt) -- (", string$: relend, "\imagewidth/", string$: xdenom, ",\imageheight + ", string$: intlevel, "\intheight + 0.7\intheight + 3pt) -- (", string$: relend, "\imagewidth/", string$: xdenom, ",\imageheight - \dashintoimage*2\imageheight);", newline$
					endif
					lastx = endtime
					appendFile: outfile$, tab$, "\node[anchor=base,inner sep=\inttextboxsep,fill=white] at (", string$: reltexttime, "\imagewidth/", string$: xdenom, ",\imageheight + ", string$: intlevel, "\intheight + 3pt) {\textbf{\ipa{", text$, "}}};", newline$
				endif
			endfor
		else
			# Point tier support: not yet implemented
		endif
	endfor
	selectObject: sound
	plusObject: tg
	editor
endif
writeInfoLine: "Done."
