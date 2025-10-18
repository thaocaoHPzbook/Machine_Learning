# 0. Exploring metadata
<img width="2304" height="750" alt="1" src="https://github.com/user-attachments/assets/479e3da5-294b-418b-96dd-d060ceb499ee" />
<img width="1166" height="722" alt="5" src="https://github.com/user-attachments/assets/a04d0a00-ca4b-43b0-a46b-c6af42133849" />
<img width="2290" height="764" alt="4" src="https://github.com/user-attachments/assets/97016a10-9d32-4896-a9ca-89ec545ef393" />
<img width="2302" height="856" alt="3" src="https://github.com/user-attachments/assets/d00eac95-f48a-4731-9c45-c7f39023d5aa" />
<img width="2294" height="734" alt="2" src="https://github.com/user-attachments/assets/6cd60629-1a74-4031-aa38-1dccac58cf46" />


# 1. Importing raw data into Qiime2
## Generate manifest.csv
Sequence data are paired end in the format of FASTA with good quality score; therefore, in qiime2 the type will be "SampleData[PairedEndSequencesWithQuality]" and their imput format asigned as PairedEndFastqManifestPhred33.
Before importing, [manifest.csv](https://drive.google.com/drive/folders/1xs2Mpx0Al3FSNE7Jqil6ivPbxe7x88nG) file must be prepared.

 ```bash
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.csv \
  --output-path short_reads_demux.qza \
  --input-format PairedEndFastqManifestPhred33
```
This might take a while before you get the results. The output of this command is a **short_reads_demux.qza** file, which you have already specified in the command. You can then create a visualized file from this artifact, with the following command:

```bash
qiime demux summarize \
  --i-data short_reads_demux.qza \
  --o-visualization short_reads_demux.qzv
```
This [short_reads_demux.qzv] is a visualized format of short_reads_demux.qza. which you can view it on [qiime2 viewer](https://view.qiime2.org/). Once you are there you can either drag-and-drop the artifact into the designated area or simpley copy the link to the artifact from this repository and paste it in the box file from the web. Once there, you must come across the following picture:    
![image]    
**Figure 1. Demultiplexed pairedEnd read**       
On this overview page you can see counts of demultiplexed sequences for the entire samples for both forward and reverse reads, with min, median, mean and max and total counts.
![image]    
**Figure 2. Interacvive plot for demultiplexed pairedEnd reads**    
Understanding this plot is crucial for the denoising step, as it allows you to determine the appropriate truncation length for both forward and reverse reads, ensuring that at least 50% of the reads maintain a quality score (Q) of ≥ 30. You can observe these changes by hovering over the interactive box plots. In this case, the quality of both forward and reverse reads remained consistently high, indicating that minimal (at 251nt) or no truncation may be necessary.

# 2. Filtering, dereplication, sample inference, chimera identification, and merging of paired-end reads by DADA2 package in qiime2.
```bash
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs short_reads_demux.qza \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 251 \
  --p-trunc-len-r 251 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza
```
You can convert the [denoising-stats.qza] file into a [denoising-stats.qzv]file and visualize it on qiime viewer as explained earlier
```bash
qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv
```
![image]

**Figure 3. The denoising status of the reads for each sample.**    
You can see the number of filtered reads and also the percentage of non-chimeric sequences after denoising.
The filtered reads and the percentage of non-chimeric sequences being >50% is quite good. However, you may need to adjust the chimera filtering process in DADA2 or apply an alternative approach if you want to improve the results, such as:    

**Visualize feature table**
```bash
qiime feature-table summarize \
  --i-table table.qza \
  --m-sample-metadata-file metadata_final.tsv \
  --o-visualization table.qzv
```

**Tabulate representative sequences**
```bash
qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv
```

**Filter to remove sample with < 5 reads**
```bash
qiime feature-table filter-samples \
  --i-table table.qza \
  --p-min-frequency 5 \
  --o-filtered-table table_filtered_min5.qza
```

**Visualize feature table after filter**
```bash
qiime feature-table summarize \
  --i-table table.qza \
  --m-sample-metadata-file metadata_final.tsv \
  --o-visualization table.qzv
```
If you drag and drop the [table-no-chimera.qzv] file in qiime2 view, you can see three main menues; Overview, Interactive Sample Detail and Feature Detail. If you click on Feature detail Detail you can see a slider to the left of the picture which could be changed, based which you can arbiterarily decide, to which depth of reading you can do your rarefaction.
![image]

**Figure 5. ASV table indicating number of samples per treatment and number of ASVs per sample**    

# 3. Training a full-length 16S rRNA classifier for taxonomic classification using the Naïve Bayes method in QIIME 2
For taxonomic classifications, you need to have a classifier to which you blast your sequences against to find out which taxonomic groups each sequence belongs to. This is also called reference phylogeny, which is a cruitial step in identifying the marker genes (in this case 16S rRNA) taken from different environmental a in saco samples. In order to do so, there are different 16S rRNA databases, of which Greengens and SILVA are well-known databases for the full length of 16S rRNA genes. You can always download the pre-trained classifiers at the Data Resources of qiime2 website with the follwoing command:
```bash
wget https://data.qiime2.org/2023.7/common/silva-138-99-seqs.qza -O silva_data/silva-138-99-seqs.qza
wget https://data.qiime2.org/2023.7/common/silva-138-99-tax.qza -O silva_data/silva-138-99-tax.qza
```
**Train the downloaded database**
```bash
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads silva-138-99-seqs.qza \
  --i-reference-taxonomy silva-138-99-tax.qza \
  --o-classifier silva-138-99-nb-classifier.qza
```
After you got **silva-classifier.qza** classifier file, you can use it for your taxonomic classifications as follows:

## Taxonomic classification with a confidence score threshold of 80%
```bash
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-classifier.qza \
  --i-reads rep-seqs-no-chimera.qza \
  --p-confidence 0.8 \
  --o-classification taxonomy.qza
```
**Generate taxa bar plot**
```bash
qiime taxa barplot \
--i-table table_filtered_min5.qza \
--i-taxonomy taxonomy.qza \
--m-metadata-file metadata_final.tsv \
--o-visualization taxa-barplot.qzv
```

![image]
**Figure 6. Taxonomy classification bar plot at genus level**

**Visualize taxonomy classification result with confident score**
```bash
qiime metadata tabulate \
 --m-input-file taxonomy.qza \
 --o-visualization taxonomy.qzv
```

To investigate further, we will examine the summary statistics after chimera filtering and perform rarefaction curve analysis in the next steps.  


# 4. Creating a phylogenetic tree using align-to-tree-MAFFT-FastTree
```bash
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
```

# 5. Rarefraction curve analysis
Rarefaction curves assess sequencing depth sufficiency and microbial diversity saturation in samples. This helps (1) Ensure adequate sequencing depth for reliable diversity estimation (2) Compare samples to detect under-sequenced ones; (3) Evaluate data stability—a plateauing curve indicates sufficient sampling.
**Generate rarefraction curve chart**
```bash
qiime diversity alpha-rarefaction \
  --i-table table_filtered_min5.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 87959 \
  --m-metadata-file metadata_final.tsv \
  --o-visualization alpha-rarefaction.qzv
```
You can view the chart [alpha-rarefaction.qzv] by qiime view as method explained previously.
![image]

At a depth of 9000, the rarefaction curve almost reaches saturation, indicating that increasing reads will not detect many new ASVs, 70% of the samples are retained. This suggests that normalization at this depth would keep all of the dataset for analysis.    
**Proceed with normalization at a subsampling depth of 9000**
```bash
qiime diversity core-metrics-phylogenetic \
  --i-table table_filtered_min5.qza \
  --i-phylogeny rooted-tree.qza \
  --m-metadata-file metadata_final.tsv \
  --p-sampling-depth 9000 \
  --output-dir core-metrics-results
```
# 6. Alpha diversity analysis
## Chao1
Chao1 alpha diversity analysis estimates species richness in a sample. It focuses on rare ASVs (appearing only once or twice), helping to assess how many species might be undetected due to limited sequencing depth. This is useful for comparing microbial richness across sample groups.
```bash
qiime diversity alpha \
  --i-table core-metrics-results/rarefied_table.qza \
  --p-metric chao1 \
  --o-alpha-diversity core-metrics-results/chao1_vector.qza
```
```bash
qiime metadata tabulate \
  --m-input-file core-metrics-results/chao1_vector.qza \
  --o-visualization core-metrics-results/chao1_vector.qzv
```
[chao1_vector.qzv] is generated.
![image]
A statistical test is needed to determine whether this difference is statistically significant among groups.

**Analysis Chao1 between groups**
```bash
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/chao1_vector.qza \
  --m-metadata-file metadata_final.tsv \
  --o-visualization core-metrics-results/chao1_group_significance.qzv
```
[chao1-group-significance.qzv]
![image]


## Shannon index
The Shannon index measures alpha diversity, accounting for both species richness (number of species) and evenness (distribution of species abundances).
    Higher Shannon index → More diverse and evenly distributed microbial community.
    Lower Shannon index → A community dominated by a few species, indicating lower diversity.
```bash
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/shannon_vector.qza \
  --m-metadata-file metadata_final.tsv \
  --o-visualization core-metrics-results/shannon_pneumonia_significance.qzv
```

[shannon-group-significance.qzv] file is generated.
![image]


## Pielou's Evenness Index
Pielou's Evenness Index measures the evenness of species distribution in a community. It indicates how evenly the species are distributed, with values ranging from 0 (completely uneven) to 1 (completely even).
```bash
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file metadata_final.tsv \
  --o-visualization core-metrics-results/evenness_pneumonia_significance.qzv
```
[evenness_group_significance.qzv] file is generated
![image]


## Faith's Phylogenetic Diversity (Faith's PD) 
Faith's PD measures the total branch length of a phylogenetic tree that connects all species in a sample. It reflects both species richness and phylogenetic diversity, considering evolutionary relationships.
A higher Faith’s PD indicates a more diverse microbial community with greater evolutionary variety, while a lower Faith’s PD suggests a more phylogenetically constrained community.
```bash
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file metadata_final.tsv \
  --o-visualization core-metrics-results/faith_pd_group_significance.qzv
```
[faith-pd-group-significance.qzv]is generated
![image]

# 7. Beta diversity analysis
## Bray-Curtis Index
This index is used to measure the difference between two microbial communities. The value ranges from 0 to 1:
    0 means the two communities are completely identical.
    1 means the two communities are completely different.
This index helps us understand the level of difference in microbial species between samples.    
**PCoA Plot**
```bash
qiime diversity pcoa \
  --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
  --o-pcoa core-metrics-results/bray_curtis_pcoa_results.qza
```
```bash
qiime emperor plot \
  --i-pcoa core-metrics-results/bray_curtis_pcoa_results.qza \
  --m-metadata-file metadata_final.tsv \
  --o-visualization core-metrics-results/bray_curtis_emperor.qzv
```
![image]


The PCoA plot [bray_curtis_emperor.qzv] does not show clear clustering between the treatments,further PERMANOVA analysis for a more detailed examination and reveals significant differences in microbial communities across the groups.
**PERMANOVA analysis**
```bash
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
  --m-metadata-file metadata_final.tsv \
  --m-metadata-column pneumonia \
  --o-visualization core-metrics-results/bray_curtis_pneumonia_significance.qzv \
  --p-method permanova
```
[bray_curtis_group_significance.qzv] file is generated.
![image]
![image]



## Jaccard index
Jaccard index is a measure of similarity between two sets. In microbiome studies, it is used to compare the presence or absence of species across different samples.
    Range: 0 to 1.
        0 means the samples have no species in common (completely different).
        1 means the samples have identical species (completely the same).
Jaccard index focuses on the presence/absence of species, rather than their abundance, making it useful for studies where the presence of specific species is more important than their relative abundance.
`
## Weighted UniFrac 
Weighted UniFrac is better at detecting differences in community structure by considering the relative abundance of each species, not just whether or not they are present in a sample.

## Unweighted UniFrac
Unweighted UniFrac measures the differences between microbial communities based on the presence or absence of species, without considering their abundance or frequency. It is useful for comparing the community structure and detecting shifts in species diversity between samples, especially when the focus is not on the abundance of each species.
```bash
`for metric in bray_curtis unweighted_unifrac weighted_unifrac jaccard; do
    for col in timepoint timepoint_character tissue_type days_stay_ICU tracheostomy pneumonia \
               timepoint_pneumonia timepoint_pneumonia_sample date_tracheostomy \
               intubation_date extubation_date intubation_days \
               hospital_mortality mortality_28d mortality_90d; do
        qiime diversity beta-group-significance \
            --i-distance-matrix core-metrics-results/${metric}_distance_matrix.qza \
            --m-metadata-file metadata_final.tsv \
            --m-metadata-column "$col" \
            --o-visualization core-metrics-results/${metric}_${col}_pairwise_significance.qzv \
            --p-method permanova \
            --p-pairwise
        echo "Finished PERMANOVA pairwise for $metric - $col"
    done
done
```

# 8. Export file from Qimme2 for R steps
```bash
qiime tools export \
  --input-path filtered-table.qza \
  --output-path exported_feature_table
```

```bash
qiime tools export \
  --i-classification taxonomy.qza \
  --output-dir taxonomy_exported
```
The above command will export the [taxanomy.tsv] file in the taxonomy_exported directory.
