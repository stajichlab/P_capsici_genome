#for file in *.fa.xml; do b=$(basename $file .fa.xml); mv $file $b.xml; done
#for file in *.fa.gff3; do b=$(basename $file .fa.gff3); mv $file $b.gff3; done
#for file in *.fa.tsv; do b=$(basename $file .fa.tsv); mv $file $b.tsv; done
for nm in $(find . -name '*.fa'); do m=$(basename $nm .fa);  if [ ! -f $m.xml ]; then basename $nm; fi done > ../iprscan_to_run.lst
