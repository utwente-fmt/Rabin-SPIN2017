

# generates the plots and creates a PDF containing all plots

Rscript csv2plot.r > /dev/null

echo "\\\documentclass{article}" > results.tex
echo "\\\usepackage{fullpage}" >> results.tex
echo "\\\usepackage{tikz}" >> results.tex
echo "\\\begin{document}" >> results.tex
echo "" >> results.tex

for V in `ls img | grep "TGBA_LTL3DRA"`
do
	VAR="${V#compare_}"
	VAR="${VAR%_TGBA_LTL3DRA.pdf}"

	echo "\\\begin{figure*}[htb!]" >> results.tex
	echo "\\\centering" >> results.tex
	echo "\\\begin{tikzpicture}" >> results.tex
	echo "" >> results.tex
	echo "\\\node (a) at (0,0)   {\\\includegraphics[width=.48\\\textwidth]{img/compare_${VAR}_TGBA_Rabinizer3}};" >> results.tex
	echo "\\\node (b) at (8.1,0) {\\\includegraphics[width=.48\\\textwidth]{img/compare_${VAR}_TGBA_TGBA-TGRA}};" >> results.tex
	echo "\\\node (c) at (0,6)   {\\\includegraphics[width=.48\\\textwidth]{img/compare_${VAR}_TGBA_LTL3HOA}};" >> results.tex
	echo "\\\node (d) at (8.1,6) {\\\includegraphics[width=.48\\\textwidth]{img/compare_${VAR}_TGBA_LTL3DRA}};" >> results.tex
	echo "" >> results.tex
	echo "\\\end{tikzpicture}" >> results.tex
	echo "\\\caption{}" >> results.tex
	echo "\\\end{figure*}" >> results.tex
	echo "" >> results.tex
done


for V in `ls img | grep "LTL3DRA-seq_LTL3DRA-par"`
do
	VAR="${V#compare_}"
	VAR="${VAR%_LTL3DRA-seq_LTL3DRA-par.pdf}"

	echo "\\\begin{figure*}[htb!]" >> results.tex
	echo "\\\centering" >> results.tex
	echo "\\\begin{tikzpicture}" >> results.tex
	echo "" >> results.tex
	echo "\\\node (a) at (0,0)   {\\\includegraphics[width=.48\\\textwidth]{img/compare_${VAR}_LTL3DRA-seq_LTL3DRA-par.pdf}};" >> results.tex
	echo "\\\node (b) at (8.1,0) {\\\includegraphics[width=.48\\\textwidth]{img/compare_${VAR}_LTL3HOA-seq_LTL3HOA-par.pdf}};" >> results.tex
	echo "\\\node (c) at (0,6)   {\\\includegraphics[width=.48\\\textwidth]{img/compare_${VAR}_Rabinizer3-seq_Rabinizer3-par.pdf}};" >> results.tex
	echo "" >> results.tex
	echo "\\\end{tikzpicture}" >> results.tex
	echo "\\\caption{}" >> results.tex
	echo "\\\end{figure*}" >> results.tex
	echo "" >> results.tex
done

echo "\\\end{document}" >> results.tex
echo "" >> results.tex


pdflatex results.tex > /dev/null

