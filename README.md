# specTeX

A package for producing publication-quality acoustic figures (waveforms, spectrograms, and TextGrid annotations) in LaTeX, using data exported from [Praat](https://www.fon.hum.uva.nl/praat/).

## Overview

specTeX works in two steps:

1. **Praat** exports a waveform image, a spectrogram image, and a TeX data file containing TikZ drawing commands (axes, labels, TextGrid interval boundaries).
2. **LaTeX** includes the data file inside a `tikzpicture` environment, producing a complete figure with aligned waveform, spectrogram, axis labels, and TextGrid tier annotations.

The result is a vector-quality figure suitable for journal submission, with IPA labels rendered by the Doulos SIL font.

## Requirements

- **Praat** 6.x or later
- **LaTeX engine**: XeLaTeX or LuaLaTeX (required by `fontspec`)
- **IPA font**: [Doulos SIL](https://software.sil.org/doulos/) (recommended; the package falls back to the default font with a warning if Doulos SIL is not installed)
- **LaTeX packages**: `graphicx`, `tikz`, `calc`, `fontspec` (loaded automatically by `specTeX.sty`)

## Repository structure

```
specTeX.praat           Praat script — run from an editor window to export figure data
specTeX.sty             LaTeX style file — provides \specfigure and figure layout
LICENSE                 GPL v3
examples/
  make_demo.praat       Synthesizes "praat" and generates demo figure data (no GUI needed)
  demo_document.tex     LaTeX wrapper for the demo figure
  example_output.tex    Sample specTeX output (from the original 2013 version)
  example_document.tex  LaTeX wrapper for the sample output
  Makefile              Build targets for demo and example PDFs
```

## Installation

1. Place `specTeX.sty` where your LaTeX distribution can find it — either in your project directory or in your local `texmf` tree (e.g., `~/texmf/tex/latex/specTeX/`).
2. Place `specTeX.praat` where you can open it from Praat's script editor, or add it to the Praat menu via **Praat > New Praat script**.

## Usage

### Step 1: Export from Praat

1. Open a Sound and its TextGrid together in a Praat editor window.
2. Select the time range you want to display.
3. Run `specTeX.praat` from the editor's script menu.
4. Choose an output filename (e.g., `myfigure.tex`).
5. In the dialog, configure:
   - **Tiers**: which TextGrid tiers to include (enter tier numbers concatenated, e.g., `12` for tiers 1 and 2; `0` for none)
   - **Image width**: figure width in inches (default: 6)
   - **Image height**: panel height in inches (default: 1.5)

The script generates three files alongside your chosen output path:

| File | Contents |
|---|---|
| `myfigure.tex` | TikZ drawing commands (axes, labels, tier annotations) |
| `myfigure_wf.pdf` | Waveform image |
| `myfigure_spec.pdf` | Spectrogram image |

### Step 2: Include in LaTeX

```latex
\documentclass{article}
\usepackage{specTeX}

\begin{document}

\begin{figure}[ht]
\centering
\begin{tikzpicture}
\specfigure{myfigure.tex}
\end{tikzpicture}
\caption{My acoustic figure.}
\end{figure}

\end{document}
```

Compile with `xelatex` or `lualatex`.

## Configurable lengths

Override these in your document preamble with `\setlength` as needed:

| Length | Default | Description |
|---|---|---|
| `\imagewidth` | `\textwidth - 3em` | Width of waveform/spectrogram images |
| `\imageheight` | `4cm` | Height of each image panel |
| `\labheight` | `1.5em` | Height reserved for axis labels |
| `\intheight` | `1.5em` | Height of each TextGrid tier row |
| `\inttextboxsep` | `1pt` | Padding around interval label text |
| `\dashing` | `2pt` | Line width base for interval boundaries |

### Other options

- **`\dashintoimage`**: Set to `1` (default) to extend interval boundary lines down into the waveform, or `0` to keep them above.
- **`\ipa{text}`**: Renders text in Doulos SIL. Falls back to the default font if Doulos SIL is not installed.

## Demo

The `examples/` directory includes a self-contained demo that synthesizes the word "praat" using Praat's built-in speech synthesizer (no audio files needed):

```sh
cd examples
make demo
```

This runs two steps:

1. `praat --run make_demo.praat` — synthesizes "praat", extracts the phoneme and word TextGrid tiers, exports waveform and spectrogram PDFs, and generates `demo.tex`
2. `xelatex demo_document.tex` — compiles the final PDF with waveform, spectrogram, time/frequency/pressure axes, and two annotation tiers (phones: p, ɹ, ɑː, t; word: praat)

Other Makefile targets:

| Target | Description |
|---|---|
| `make demo` | Build the demo PDF (default) |
| `make example` | Build the example PDF (uses placeholder images) |
| `make clean` | Remove LaTeX auxiliary files |
| `make distclean` | Remove all generated files (PDFs, images, `.tex` data) |

## License

GPL v3. See [LICENSE](LICENSE).
