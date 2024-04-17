#!/bin/bash

#######################################################
# Función script: Alinear reads a genoma de referencia
# Autor: RaulRojasE
# Version: 0.1
#######################################################
# Uso:
# ./align_reads.sh [opciones]
#######################################################
# Opciones:
#   -h, --help      Mensaje de ayuda
#   -f, --file      Archivo de genoma
#   -r, --read      Tipo de reads a alinear (SE o PE)
#   -d, --directory Especifica el directorio de entrada
#   -o, --output    Especifica el directorio de salida (De no existir, se crea)
#######################################################
# Ejemplo de uso:
# ./align_reads.sh -f /genome.fasta -r SE -d /ruta/de/entrada -o /ruta/de/salida
#######################################################

#Importar scripts a utilizar
source check_dependence.sh

#######################################################
#Solicitud de mensaje de ayuda en el script 
mensaje_ayuda(){
    echo "./align_reads.sh [opciones]"
    echo "Opciones:"
    echo "   -h, --help         Mensaje de ayuda"
    echo "   -f, --file         Archivo de genoma"
    echo "   -r, --read         Tipo de reads a alinear (SE o PE)"
    echo "   -d, --directory    Especifica el directorio de entrada de los reads"
    echo "   -o, --output       Especifica el directorio de salida (De no existir, se crea)"
    echo "Ejemplo de uso:"
    echo "./align_reads.sh -f /genome.fasta -r SE -d /ruta/de/entrada -o /ruta/de/salida"
}

#######################################################
# Creación de directorio de salida en caso de que no exista
crear_directorio(){
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Se crea el directorio $1"
    fi 
}

#######################################################
#Comprobación de parámetros de entrada
genome_fasta=""
read_type=""
reads_folder=""
output_folder=""
#
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in 
        -h|--help)
            mensaje_ayuda
            exit 0
            ;;
        -f|--file)
            genome_fasta="$2"
            shift 2
            ;;
        -r|--read)
            read_type="$2"
            shift 2
            ;;
        -d|--directory)
            reads_folder="$2"
            shift 2
            ;;
        -o|--output)
            crear_directorio $2
            output_folder="$2"
            shift 2
            ;;
        *)
            echo "Opción no válida: $1"
            exit 1
            ;;
    esac
done

if [ -z "$genome_fasta" ] || [ -z "$read_type" ] || [ -z "$reads_folder" ] || [ -z "$output_folder" ] ; then
    echo "Por favor ingresa los parametros solicitados: -f <genoma_phix> -r <tipo de reads SE o PE> -d <ruta/reads> -o <ruta/salida>"
    exit 1
fi

if [ ! -f "$genome_fasta" ]; then
    echo "El archivo '$genome_fasta' no existe"
    exit 1
fi

if [ "$read_type" != "SE" ] && [ "$read_type" != "PE" ]; then
    echo "El tipo de reads debe ser 'SE' o 'PE'"
    exit 1
fi


#######################################################
#Verificar dependencias instaladas
verificar_dependencias "hisat2"
verificar_dependencias "samtools"

#######################################################


#######################################################
#Creación de indice del genoma

genome_index="genome"

hisat2-build "$genome_fasta" "$genome_index" 

#######################################################
#Alinear reads al genoma

#reads SE
alinear_SE(){
    for read in "$reads_folder"/*.fastq.gz; do
        prefix="${read1%.fastq.gz}"
        name_out="$output_folder/$(basename "$prefix")"

        hisat2 -x "$genome_index" -U "$read" -S "$name_out.sam" 2> $name_out.stats
        samtools view -h -b -S "$name_out.sam" | samtools sort -o "$name_out.bam"

    done
}

#reads PE
alinear_PE(){
    for read1 in "$reads_folder"/*_1.fastq.gz; do
        prefix="${read1%_1.fastq.gz}"
        read2="$prefix"_2.fastq.gz
        name_out="$output_folder/$(basename "$prefix")"
        
        hisat2 -x "$genome_index" -1 "$read1" -2 "$read2" -S "$name_out.sam" 2> $name_out.stats
        samtools view -h -b -S "$name_out.sam" | samtools sort -o "$name_out.bam"

    done
}



#
if [ "$read_type" == "SE" ]; then
    alinear_SE
elif [ "$read_type" == "PE" ]; then
    alinear_PE
fi
