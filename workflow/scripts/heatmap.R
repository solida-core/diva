library(pheatmap)

abs_path=getwd()
bedtools_path<-snakemake@params[[1]]
print(getwd())
setwd(abs_path)

files <- dir(bedtools_path,pattern=".coverage.tsv")
print("___________________________________________")
print(paste("Found",length(files),"files with",length(count.fields(paste(bedtools_path,files[1],sep="/"))),"lines", sep=" "))
print("Files:")
print(files)
print("___________________________________________")

#length(count.fields(paste(bedtools_path,files[1],sep="/")))
print("Reading files:")

mat <- matrix(data = 0 ,nrow=length(count.fields(paste(bedtools_path,files[1],sep="/"))), ncol=length(files))
for (i  in 1:length(files)){
  a <- read.table(paste(bedtools_path,files[i],sep="/"), sep="\t", header=F)
  mat[,i] <- as.numeric(a[,10])
  cat(paste(i,"/",length(files),sep=""),"\n")
}
colnames(mat) <- gsub(".coverage.tsv","",files)
tmp <- cbind(a[,c(-10,-8,-7,-6,-5)],mat)
tmp$V4=gsub("\\).*","",tmp$V4)
tmp$V4=gsub(".*\\(","",tmp$V4)
names(tmp)[1:5] = c("chr","start","end","gene","region_lenght")
tmp$chr=gsub("chr","", tmp$chr)
sorted.out <- tmp[order(as.numeric(tmp$chr)), ]
sorted.out$chr=paste("chr",sorted.out$chr,sep = "")
tmp=sorted.out
#rownames(tmp)=tmp$gene
print("Table preview:")
head(tmp[1:10], n = 3)

print("___________________________________________")
print("Writing OUTPUT:")
out_table=snakemake@output[[1]]
print("Output table:")
print(out_table)
write.table(tmp,file=out_table, sep="\t", row.names=F, quote = F)

### HEATMAP
annotation <- NA
if (snakemake@params[[2]] != "NA"){
  annotation <- read.table(snakemake@params[[2]], header=T, sep="\t", as.is=T, row.names=1, fill=TRUE)
}

# aggiungere in pheatmap
col_annotations = annotation

heat_data <- tmp[,-c(1:5)]


reheader=read.table(snakemake@params[[3]],sep = "\t", header = T,as.is=T,row.names=1)
id_labels=reheader[colnames(heat_data),]
line1 <- colnames(heat_data)
line2 <- id_labels
vector_names.arg <- paste(line2, line1, sep = " | ")




rownames(col_annotations) <- colnames(heat_data)
heat_out=snakemake@output[[2]]
print("Heatmap output:")
print(heat_out)
pheatmap(heat_data,
         #color = greenred(75),
         #color = brewer.pal(9,“Oranges”),
         cluster_rows = FALSE,
         clustering_distance_rows = "correlation",
         cluster_cols = FALSE,
         clustering_distance_cols = "correlation",
         fontsize_row = 3,
         fontsize_col = 3,
#         fontisize = 7,
         #cellwidth=20,
         #cellheight=1,
         width=5,
         height=3,
         scale = "none",
         show_rownames=FALSE,
         show_colnames=TRUE,
         legend=TRUE,
         labels_row=tmp$gene,
         labels_col=gsub("-R0001","", vector_names.arg),
         annotation_col = col_annotations,
         filename=heat_out
)


###for filter low coverage
id_rows <- rowSums(heat_data < 1) > 0
heat_data_low <- heat_data[id_rows,]
id_labels_low=reheader[colnames(heat_data_low),]
line1l <- colnames(heat_data_low)
line2l <- id_labels_low
vector_names_low.arg <- paste(line2l, line1l, sep = " | ")



heat_out_low=snakemake@output[[3]]
print("Heatmap low coverage output:")
print(heat_out_low)
pheatmap(heat_data_low,
         #color = greenred(75),
         #color = brewer.pal(9,“Oranges”),
         cluster_rows = FALSE,
         clustering_distance_rows = "correlation",
         cluster_cols = FALSE,
         clustering_distance_cols = "correlation",
         fontsize_row = 3,
         fontsize_col = 3,
#         fontsize = 7,
         #cellwidth=20,
         #cellheight=1,
         width=5,
         height=3,
         scale = "none",
         show_rownames=FALSE,
         show_colnames=TRUE,
         legend=TRUE,
         labels_row=tmp$gene,
         labels_col=gsub("-R0001","", vector_names_low.arg),
         annotation_col = col_annotations,
#         display_numbers = T,
#         fontsize_number = 5,
         filename=heat_out_low
)










pdf(NULL)