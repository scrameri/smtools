#!/bin/bash

## Usage: get.LSC.IR.SSC.from.chloroplast.genome.sh <*.chloroplast.genome.fasta>

## Purpose: extract the large single-copy (LSC), small single-copy (SSC) and inverted repeat (IR) regions from complete chloroplast genomes and save these 3 regions to a *.LSC.IR.SSC.fasta file

## Requirements: makeblastdb, blastn, awk, sed, samtools faidx

## Output: blast results (*.on.*.blast), saved regions (*.LSC.IR.SSC.fasta)

## Author: simon.crameri@env.ethz.ch, 27.7.2018


#################################################################################

## Define function
doExcise() 
{
	fasta=$1
	check=$(grep -c '^>' ${fasta})
	if [ $check -ne 1 ] ; then echo ; echo "Something is wrong with the input .fasta file. Does it have more than 1 region?" ; echo ; exit 0 ; fi
	sed -i 's/ /_/g' ${fasta} # important for downstream samtools usage
	sed -i 's/,//g' ${fasta} # important for downstream samtools usage

	fname1=$(basename ${fasta} .fasta)
	fname2=$(basename ${fname1} .fas)
	fname=$(basename ${fname2} .fa)
	
	## Create .blast database of reference genome
	makeblastdb -in ${fname}.fasta -parse_seqids -dbtype nucl >/dev/null

	## Blast against itself
	blastn -db ${fname}.fasta -query ${fname}.fasta -num_threads 1 -out ${fname}.tmp -outfmt "7 qseqid qlen sseqid slen length pident qstart qend sstart send evalue bitscore score stitle"

	# Sort BLAST output by query.id, subject.id and alignment.length
	grep -v '^#' ${fname}.tmp | sort -k1,1 -k3,3 -k5,5nr > ${fname}.tmp2

	# Create header and output
	echo "$(head -n1 ${fname}.tmp) $(grep '# Fields:' ${fname}.tmp | head -n1 | sed -e 's/% identity/perc.identity/g' | sed -e 's/# //g')" > ${fname}.on.${fname}.blast
	cat ${fname}.tmp2 >> ${fname}.on.${fname}.blast

	## Get IR boundaries
	# IRminlen =< IRsize =< IRmaxlen, where IRsize is typically around 25000 bp
	IRminlen=10000 # must be greater than multi-copy gene regions (which will have hits vs. themselves)
	IRmaxlen=50000 # must be smaller than the chloroplast genome (which will have a hit vs. itself)
	cat ${fname}.on.${fname}.blast | awk -v a="$IRminlen" -v b="$IRmaxlen" '{ if($5 >= a && $5 <= b) { print }}' | awk 'seen[$5]++ >= 1' | cut -f7,8,9,10 | sed -e 's/\t/\n/g' | sort -n > ${fname}.IRboundaries
	
	# check that IR boundaries have been successfully identified
	nlines=$(wc -l < ${fname}.IRboundaries)
	if [ $nlines -eq 0 ]
		then
			## Message, clean up and exit
			echo
			echo "No IR boundaries found! Does your chloroplast genome belong to the IRLC clade of legumes (Fabaceae, a.k.a. Leguminosae)?"
			echo
			/bin/rm -f ${fname}.tmp* ${fasta}.n* ${fname}.IRboundaries
			exit 0
		else
			## Excise LSC, IR and SSC
			header=$(grep '^>' ${fname}.fasta | cut -d '>' -f2)
			
			# LSC
			LSCIR=$(head -n1 ${fname}.IRboundaries)
			samtools faidx ${fname}.fasta ${header}:1-$(expr ${LSCIR} - 1 ) > ${fname}.LSC.fasta
			sed -i 's/:/_/g' ${fname}.LSC.fasta # important for downstream samtools usage
			
			# IR
			IRSSC=$(head -n2 ${fname}.IRboundaries | tail -n1)
			samtools faidx ${fname}.fasta ${header}:${LSCIR}-${IRSSC} > ${fname}.IR.fasta
			sed -i 's/:/_/g' ${fname}.IR.fasta # important for downstream samtools usage
			
			# SSC
			SSCIR=$(head -n3 ${fname}.IRboundaries | tail -n1)
			samtools faidx ${fname}.fasta ${header}:$(expr ${IRSSC} + 1 )-$(expr ${SSCIR} - 1 ) > ${fname}.SSC.fasta
			sed -i 's/:/_/g' ${fname}.SSC.fasta # important for downstream	samtools usage
			
			## Combine LSC, IR and SSC into one .fasta file
			cat ${fname}.LSC.fasta ${fname}.IR.fasta ${fname}.SSC.fasta > ${fname}.LSC.IR.SSC.fasta
			
			## Final check
			awk '/^>/ {if (seqlen){print seqlen}; print ;seqlen=0;next; } { seqlen += length($0)}END{print seqlen}' ${fname}.LSC.IR.SSC.fasta | grep -v '^>' > ${fname}.lengths
			LSClen=$(head -n1 ${fname}.lengths)
			IRlen=$(head -n2 ${fname}.lengths | tail -n1)
			SSClen=$(head -n3 ${fname}.lengths | tail -n1)
			totlen=$(awk '/^>/ {if (seqlen){print seqlen}; print ;seqlen=0;next; } { seqlen += length($0)}END{print seqlen}' ${fasta} | tail -n1)
			# totlen=$(head -n4 ${fname}.lengths | tail -n1)
			comb=$(expr $LSClen + $IRlen + $SSClen + $IRlen)
			if [ $comb -ne $totlen ]
				then 
					echo
					echo "WARNING: combined length of excised LSC, 2xIR and SSC does not match the total chloroplast genome length!"
					echo 
					echo "It seems that the chloroplast genome does not start with the first base of the LSC region / does not end with the last base of the IR region."
					echo
					echo " --> length of LSC: $LSClen"
					echo " --> length of IR: $IRlen"
					echo " --> length of SSC: $SSClen"
					echo " --> length of LSC + 2xIR + SSC: $comb"
					echo " --> length of chloroplast genome: $totlen"
					echo
				fi

			## Clean up
		    	/bin/rm -f ${fname}.tmp* ${fasta}.n* ${fname}.LSC.fasta ${fname}.IR.fasta ${fname}.SSC.fasta ${fname}.IRboundaries ${fasta}.fai ${fname}.lengths
		fi

}


## Excise
doExcise $1
