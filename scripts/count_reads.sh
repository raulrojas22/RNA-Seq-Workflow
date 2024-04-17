#!/bin/bash

#######################################################
# Función script: Conteo de reads mapeados en las características anotadas del genoma
# Autor: RaulRojasE
# Version: 0.1
#######################################################
# Uso:
# ./count_reads.sh [opciones]
#######################################################
# Opciones:
#   -h, --help      Mensaje de ayuda
#   -f, --file      Archivo de anotación del genoma (GTF,GFF,SAF)
#   -r, --read      Tipo de reads a contar (SE o PE)
#   -d, --directory Especifica el directorio de entrada de los archivos .bam
#   -o, --output    Especifica el directorio de salida (De no existir, se crea)
#######################################################
# Ejemplo de uso:
# ./count_reads.sh -f /anotacion.gtf -r SE -d /ruta/de/entrada -o /ruta/de/salida
#######################################################

#Importar scripts a utilizar
source check_dependence.sh

#######################################################
#Solicitud de mensaje de ayuda en el script 
mensaje_ayuda(){
    echo "./count_reads.sh [opciones]"
    echo "Opciones:"
    echo "   -h, --help         Mensaje de ayuda"
    echo "   -f, --file         Archivo de anotación del genoma (GTF,GFF,SAF)"
    echo "   -r, --read         Tipo de reads a contar (SE o PE)"
    echo "   -d, --directory    Especifica el directorio de entrada de los archivos .bam"
    echo "   -o, --output       Especifica el directorio de salida (De no existir, se crea)"
    echo "Ejemplo de uso:"
    echo "./count_reads.sh -f /anotacion.gtf -r SE -d /ruta/de/entrada -o /ruta/de/salida"
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
annotation=""
read_type=""
bams_folder=""
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
            annotation="$2"
            shift 2
            ;;
        -r|--read)
            read_type="$2"
            shift 2
            ;;
        -d|--directory)
            bams_folder="$2"
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

if [ -z "$annotation" ] || [ -z "$read_type" ] || [ -z "$bams_folder" ] || [ -z "$output_folder" ] ; then
    echo "Por favor ingresa los parametros solicitados: -f <genoma_phix> -r <tipo de reads SE o PE> -d <ruta/reads> -o <ruta/salida>"
    exit 1
fi

if [ ! -f "$annotation" ]; then
    echo "El archivo '$annotation' no existe"
    exit 1
fi

if [ "$read_type" != "SE" ] && [ "$read_type" != "PE" ]; then
    echo "El tipo de reads debe ser 'SE' o 'PE'"
    exit 1
fi


#######################################################
#Verificar dependencias instaladas
verificar_dependencias "featureCounts"

#######################################################
#Contar reads en el genoma 

#reads SE
alinear_SE(){
    for archivo in "$bams_folder"/*.bam; do
        nombre="$(basename $archivo .bam)"
        featureCounts -p -g gene_id -a $anotation_file -o $output_folder/$nombre-counts.txt $archivo
    done
}

#reads PE
alinear_PE(){
    for archivo in "$bams_folder"/*.bam; do
        nombre="$(basename $archivo .bam)"
        featureCounts -g gene_id -a $anotation_file -o $output_folder/$nombre-counts.txt $archivo
    done
}


#
if [ "$read_type" == "SE" ]; then
    alinear_SE
elif [ "$read_type" == "PE" ]; then
    alinear_PE
fi
