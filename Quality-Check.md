# Generated RunIDs list based on SraRunTable, criteria for selection is sample_type = experiment
```bash
csvcut -c Run,sample_type SraRunTable.csv | csvgrep -c sample_type -m experiment | tail -n +2 | cut -d',' -f1 > Sra_RunIDs.list
```

# Download data
```bash
cat Sra_RunIDs.list | while read SRR; do
    echo "Downloading $SRR ..."
    fasterq-dump $SRR -O fastq --split-files --threads 8
done
```

# Check and re-download the fail downloaded data
```bash
while read SRR; do     file1="fastq/${SRR}_1.fastq";     file2="fastq/${SRR}_2.fastq";     if [[ -f "$file1" && -f "$file2" ]]; then         ((count++));     fi; done < Sra_RunIDs.list
```

# Count the number of successfull download data
```bash
cd /media/hp/DATA1/lung_MC

count=0
while read SRR; do
    file1="fastq/${SRR}_1.fastq"
    file2="fastq/${SRR}_2.fastq"
    if [[ -f "$file1" && -f "$file2" ]]; then
        ((count++))
    fi
done < Sra_RunIDs.list

echo "Number of samples downloaded: $count"
```
