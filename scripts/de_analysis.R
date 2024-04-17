#!/usr/bin/env Rscript

#Librería a utilizar
library("DESeq2")

#Función de ayuda
print_help <- function() {
    cat("Uso: Rscript de_analysis.R file_count file_coldata small_lib treated untreated\n")
    cat("\n")
    cat("Descripción:\n")
    cat("  Este script realiza análisis de expresión diferencial utilizando DESeq2.\n")
    cat("\n")
    cat("Argumentos:\n")
    cat("  file_count:     Archivo de datos de recuento.\n")
    cat("  file_coldata:   Archivo de datos de condiciones experimentales.\n")
    cat("  small_lib:       Tamaño del grupo más pequeño (librería).\n")
    cat("  treated:        Condición tratada.\n")
    cat("  untreated:      Condición no tratada.\n")
}

#Obtención argumentos
args <- commandArgs(trailingOnly = TRUE)

#Verificación de argumentos necesarios
if (length(args) != 5 || "-h" %in% args || "--help" %in% args) {
    print_help()
    quit(status = 0)
}

#Extraer argumentos
file_count <- args[1]
file_coldata <- args[2]
small_lib <- as.numeric(args[3])
treated <- args[4]
untreated <- args[5]

#Cargar los archivos
countdata <- data.frame(read.table(file_count, row.names=1, header=TRUE, sep="\t"))
coldata <- data.frame(read.table(file_coldata, header=TRUE, sep="\t"))

#Creación de objeto dds
dds <- DESeqDataSetFromMatrix(countData = countdata, colData = coldata, design = ~condition)

#Filtrar lecturas de bajo recuento <= 10
sizegroupsmall <- mall_lib
keep <- rowSums(counts(dds) >= 10) >= sizegroupsmall
dds <- dds[keep,]

#Análisis DE
dds <- DESeq(dds)

#Obtención de resultados
resultados <- results(dds, contrast = c("condition", treated, untreated), alpha = 0.05)
res_final <- data.frame(resultados)

#Categorizar
res_final$Category <- "Not-significant"
res_final[which(res_final$log2FoldChange>=2 & res_final$pvalue<=0.05),]$Category <- "Up-regulated"
res_final[which(res_final$log2FoldChange<=-2 & res_final$pvalue<=0.05),]$Category <- "Down-regulated"

#Guardar resultados en archivo
write.table(res_final,file="res_ctl-f2.txt",row.names=T,col.names=T,sep="\t")
