# make_demo.praat — Synthesize "Praat" and generate specTeX demo output.
# Run headlessly: praat --run make_demo.praat

# Output paths
outdir$ = "./"
outfile$ = outdir$ + "demo.tex"
wffile$ = outdir$ + "demo_wf.pdf"
specfile$ = outdir$ + "demo_spec.pdf"

# Synthesize the word "Praat" using Praat's built-in speech synthesizer
Create SpeechSynthesizer: "English (Great Britain)", "Male1"
To Sound: "praat", "yes"

# The synthesizer produces a Sound and a 4-tier TextGrid
# (sentence, clause, word, phoneme). We want tiers: phoneme and word.
synthTg = selected: "TextGrid"
sound = selected: "Sound"

selectObject: sound
duration = Get total duration
start = 0
end = duration

# Build a 2-tier TextGrid from the synthesizer's word and phoneme tiers
selectObject: synthTg
Extract one tier: 4
phoneTier = selected: "TextGrid"

selectObject: synthTg
Extract one tier: 3
wordTier = selected: "TextGrid"

selectObject: phoneTier
plusObject: wordTier
Merge
tg = selected: "TextGrid"

# Clean up intermediate objects
selectObject: synthTg
plusObject: phoneTier
plusObject: wordTier
Remove

# Figure dimensions
imgwidth = 6
imgheight = 1.5

# Get waveform min/max
selectObject: sound
wfMin = Get minimum: start, end, "Sinc70"
wfMax = Get maximum: start, end, "Sinc70"

# Extract the selection and draw waveform
selectObject: sound
Extract part: start, end, "rectangular", 1.0, "yes"
soundForDrawing = selected: "Sound"
Erase all
Select inner viewport: 0, imgwidth, 0, imgheight
Draw: start, end, wfMin, wfMax, "no", "Curve"
Save as PDF file: wffile$

# Draw spectrogram
Erase all
Select outer viewport: 0, imgwidth, 0, imgheight
To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
spec = selected: "Spectrogram"
Paint: 0.0, 0.0, 0.0, 0.0, 100.0, "yes", 50.0, 6.0, 0.0, "no"
Save as PDF file: specfile$
Erase all

# Clean up drawing objects
selectObject: spec
plusObject: soundForDrawing
Remove

# Spectrogram frequency range
specFreqMin = 0
specFreqMax = 5000

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# Generate the TeX file — same logic as specTeX.praat
xdenom = end - start

# Delete output file if it exists, so we start fresh
deleteFile: outfile$

# Let \imagewidth use the default from specTeX.sty (\textwidth - 2\labheight)
# so the figure fits within the text block.
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

# Tier rendering — phoneme (tier 1) and word (tier 2)
selectObject: tg
numtiers = Get number of tiers
numthesetiers = numtiers
for z to numthesetiers
	t = z
	dashfactor = 1 / z
	intlevel = numthesetiers - z
	selectObject: tg
	iit = Is interval tier: t
	if iit
		appendFile: outfile$, "% Interval labels for tier ", string$: t, " (tier ", string$: z, " in image)", newline$
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
	endif
endfor

# Clean up
selectObject: sound
plusObject: tg
Remove

writeInfoLine: "Demo files written to ", outdir$
