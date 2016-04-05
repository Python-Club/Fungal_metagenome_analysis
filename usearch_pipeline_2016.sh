### USEARCH Wheat ITS 2016 Analysis ###


### merge read pairs ###
usearch8.0.1623_i86linux32 -fastq_mergepairs *_R1_*.fastq -relabel @ -fastqout merged.fq

usearch -fastq_mergepairs /media/Data/Wheat_ITS/*_R1_*.fastq -relabel @ -tabbedout merged/tabbed.txt -report merged/summary.txt -fastqout merged/merged.fq



### quality filter fastq files, trim and pad fasta files ###
#usearch8.0.1623_i86linux32 -fastq_filter merged.fq -fastq_maxee 1.0 -relabel Filt -fastaout filtered.fa

usearch -fastq_filter wheat.its.merged/merged.fq -fastq_minlen 100 -fastq_maxee 1.0 -fastaout merged.filtered.fasta -fastaout_discarded merged.no_filter.fasta -fastqout merged.filtered.fastq

usearch -fastq_eestats2 merged.filtered.fastq -output eestats2.txt -length_cutoffs 100,400,10

usearch -fastx_truncate wheat.its.merged/merged.filtered.fastq -padlen 380 -trunclen 380 -fastaout wheat.its.reads.fa




### trim sequences using ITSx ###
#ITSx -i reads.fasta -o reads -t all --preserve T --save_regions ITS2 --partial 99 --truncate T --multi_thread T --cpu 8

ITSx -i merged/merged.filtered.fa -o trimmed.fa  -t all --date T --preserve T --save_regions ITS2 --partial 98 --truncate T



### find representivive sequences, create counts for number of each sequence ###
#usearch8.0.1623_i86linux32 -derep_fulllength filtered.fa -relabel Uniq -sizeout -fastaout uniques.fa

usearch -derep_fulllength wheat.its.reads.fa -sizeout -fastaout wheat.its.reads.derep.fa -uc wheat.its.reads.unique.uc -threads 4



### cluster sequences into OTUs, set cutoff ###
#usearch8.0.1623_i86linux32 -cluster_otus uniques.fa -minsize 2 -otus otus.fa -relabel Otu

usearch -cluster_otus wheat.its.reads.derep.fa -minsize 2 -sizein -sizeout -relabel OTU_ -otus wheat.its.reads.derep.otus.fa -uparseout wheat.its.reads.derep.otus.txt



### chimera removal ### do before depreplication? 
#usearch8.0.1623_i86linux32 -uchime_ref reads.fasta -db ITS_ref.udb -uchimeout results.uchime -strand plus

usearch -uchime_ref wheat.its.reads.derep.otus.fa -db /media/Data/UNITE_db/uchime.ITS2.udb -nonchimeras wheat.its.reads.derep.otus.no_chimera.fa -uchimeout wheat.its.reads.derep.otus.no_chimera.uchime -strand plus -sizein -sizeout



### map raw reads back to OTUs ###
#usearch8.0.1623_i86linux32 -usearch_global merged.fq -db otus.fa -strand plus -id 0.97 -otutabout otutab.txt -biomout otutab.json
	
usearch -usearch_global wheat.its.merged/merged.filtered.fastq -db wheat.its.reads.derep.otus.no_chimera.fa -strand plus -id 0.97 -top_hit_only -otutabout wheat.its.otu_tab.txt -biomout wheat.its.otu_tab.json -uc wheat.its.otu_tab.uclust -mothur_shared_out wheat.its.otu_tab.mothur.shared -sizein -sizeout



### taxonomy ###
usearch -makeudb_utax /media/Data/UNITE/utaxref/fasta/refdb.fa -output /media/Data/UNITE/utaxref/ITS_refdb.udb -report /media/Data/UNITE/utaxref/reports/ITS_refdb_report.txt -utax_trainlevels kpcofgs -utax_splitlevels NVcofgs

usearch -utax wheat.its.merged/merged.filtered.fastq -db /media/Data/UNITE_db/utaxref/ITS_refdb.udb -taxconfs /media/Data/UNITE_db/utaxref/taxconfs/its2.tc -tt /media/Data/UNITE_db/utaxref/usearch.tt -utaxout wheat.its.taxonomy.results.txt -strand plus -fastaout wheat.its.taxonomy.results.fa -sizein -sizeout

usearch -cluster_otus_utax wheat.its.merged/merged.filtered.fastq -db /media/Data/UNITE_db/utaxref/ITS_refdb.udb -utax_level g -otus merged.taxonomy.fa -strand plus -utaxotusout merged.taxonomy -utaxout merged.taxonomy.utax  

usearch -cluster_otus_utax wheat.its.reads.derep.otus.fa -db /media/Data/UNITE_db/utaxref/ITS_refdb.udb -utax_level g -otus wheat.its.otu_tab.taxonomy.fa -strand plus -utaxotusout wheat.its.otu_tab.taxonomy -utaxout wheat.its.otu_tab.taxonomy.utax  -tabbedout wheat.its.otu_tab.taxonomy.txt

