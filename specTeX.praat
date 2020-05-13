# stextrogram.praat orchestrates the export of
# images and sound and text-grid data for
# use in LaTeX figures via tex-trogram.sty .
# These two scripts are functional, but under
# continuing development.

# done up 2013 by dan brenner
# dbrenner atmark email dot arizona dot edu
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

clearinfo

outfile$ = chooseWriteFile$ ("Choose figure data file for writing...", "praatfig.tex")
wffile$ = replace_regex$ (outfile$, "\.\w+?$", "_wf.eps",1)
specfile$ = replace_regex$ (outfile$, "\.\w+?$", "_spec.eps",1)
start = Get start of selection
end = Get end of selection
editorInfo$ = Editor info
specFreqMin = extractNumber (editorInfo$, "Spectrogram view from: ")
specFreqMax = extractNumber (editorInfo$, "Spectrogram view to: ")
endeditor
s$ = selected$ ("Sound")
sound = selected ("Sound")
tg = selected ("TextGrid")
select tg
numtiers = Get number of tiers

defnum = 0
for i to numtiers
	defnum = defnum + i*10^(numtiers-i)
endfor
beginPause ("Specfigure options")
	comment ("Tiers to print in the figure (0 for none): ")
	natural ("Tiers", defnum)
	comment ("Image width (inches): ")
	real ("Imgwidth", 6)
	comment ("Image height (inches)")
	real ("Imgheight", 1.5)
endPause ("OK", 1)

select sound
wfMin = Get minimum... start end Sinc70
wfMax = Get maximum... start end Sinc70
Extract part... start end rectangular 1.0 yes
soundForDrawing = selected ("Sound")
Erase all
Select inner viewport... 0 'imgwidth' 0 'imgheight'

Draw... 'start' 'end' 'wfMin' 'wfMax' no Curve
Write to EPS file... 'wffile$'
Erase all
Viewport... 0 imgwidth 0 imgheight
To Spectrogram... 0.005 5000 0.002 20 Gaussian
Paint... 0.0 0.0 0.0 0.0 100.0 yes 50.0 6.0 0.0 no
Write to EPS file... 'specfile$'
Erase all
plus soundForDrawing
Remove

select tg

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# TeX: Set X & Y units for positioning. Begin figure. Insert images, add axes.
xdenom = end - start
ywfdenom = wfMax - wfMin
yspecdenom = specFreqMax - specFreqMin

fileappend 'outfile$' 'tab$'\setlength\imagewidth{'imgwidth'in}'newline$'
fileappend 'outfile$' 'tab$'\setlength\imageheight{'imgheight'in}'newline$'
fileappend 'outfile$' 'tab$'% Waveform & axes'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=south west,inner sep=0cm] at (0,0) {\includegraphics[clip=true, trim=0.583333in 0.388888in 0.583333in 0.388888in, width=\imagewidth,height=\imageheight]{'wffile$'}};'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=east,fill=white,inner sep=1pt] at (0,0) {'wfMin:3'};'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=east,fill=white,inner sep=1pt] at (0,\imageheight) {'wfMax:3'};'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=base,rotate=90,fill=white,inner sep=1pt] at (-8pt,\imageheight/2) {Pressure (Pa)};'newline$'
fileappend 'outfile$' 'newline$'
fileappend 'outfile$' 'tab$'% Spectrogram & axes'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=north west,inner sep=0cm] at (0,0) {\includegraphics[clip=true, trim=0.583333in 0.388888in 0.583333in 0.388888in, width=\imagewidth,height=\imageheight]{'specfile$'}};'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=west,fill=white,inner sep=1pt] at (\imagewidth,0) {'specFreqMax'};'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=west,fill=white,inner sep=1pt] at (\imagewidth,-\imageheight) {'specFreqMin'};'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=base,rotate=270,fill=white,inner sep=1pt] at (\imagewidth + 8pt,-\imageheight/2) {Frequency (Hz)};'newline$'
fileappend 'outfile$' 'newline$'
fileappend 'outfile$' 'tab$'% Time axis'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=base,fill=white,inner sep=1pt] at (0,-\imageheight - \labheight) {'start:3'};'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=base,fill=white,inner sep=1pt] at (\imagewidth,-\imageheight - \labheight) {'end:3'};'newline$'
fileappend 'outfile$' 'tab$'\node[anchor=base,fill=white,inner sep=1pt] at (\imagewidth/2,-\imageheight - \labheight) {Time (s)};'newline$'

if tiers != 0
	tiers$ = "'tiers'"
	tiers$ = replace$ (tiers$, "[^123456789]", "", 0)
	
	# Number of selected tiers
	numthesetiers = length (tiers$)
	for z to numthesetiers
		# z is the position within selected tiers
		t$ = mid$ (tiers$, z, 1)
		t = 't$'
		dashfactor = 1/z
		
		# A multiplier for tier height above the waveform.
		intlevel = numthesetiers - z
		select tg
		iit = Is interval tier... t
		if iit
			fileappend 'outfile$' % Interval labels for tier 't' (tier 'z' in image)'newline$'
			startint = Get interval at time... t start
			intstart = Get start point... t startint
			if start == intstart
				fromint = startint
			else
				fromint = startint + 1
			endif
			endint = Get interval at time... t end
			toint = endint - 1
			lastx = -1
			for i from fromint to toint
				select tg
				starttime = Get start point... t i
				relstart = starttime - start
				endtime = Get end point... t i
				relend = endtime - start
				text$ = Get label of interval... t i
				texttime = starttime + (endtime - starttime)/2
				reltexttime = texttime - start
				if text$ != ""
					if endtime == lastx
						fileappend 'outfile$' 'tab$'\draw[line width='dashfactor'\dashing/2] ('relstart'\imagewidth/'xdenom',\imageheight + 'intlevel'\intheight + 0.7\intheight + 3pt) -- ('relend'\imagewidth/'xdenom',\imageheight + 'intlevel'\intheight + 0.7\intheight + 3pt) -- ('relend'\imagewidth/'xdenom',\imageheight - \dashintoimage*2\imageheight);'newline$'
					else
						fileappend 'outfile$' 'tab$'\draw[line width='dashfactor'\dashing/2] ('relstart'\imagewidth/'xdenom',\imageheight - \dashintoimage*2\imageheight) -- ('relstart'\imagewidth/'xdenom',\imageheight + 'intlevel'\intheight + 0.7\intheight + 3pt) -- ('relend'\imagewidth/'xdenom',\imageheight + 'intlevel'\intheight + 0.7\intheight + 3pt) -- ('relend'\imagewidth/'xdenom',\imageheight - \dashintoimage*2\imageheight);'newline$'
					endif
					lastx = endtime
					fileappend 'outfile$' 'tab$'\node[anchor=base,inner sep=\inttextboxsep,fill=white] at ('reltexttime'\imagewidth/'xdenom',\imageheight + 'intlevel'\intheight + 3pt) {\textbf{\ipa{'text$'}}};'newline$'
				endif
			endfor
		else

		endif
	endfor
	select sound
	plus tg
	editor
endif
printline Done.
