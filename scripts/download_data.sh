#!/bin/bash

#######################################################
# Función script: Descargar archivos fastq a partir de identificadores SRA
# Autor: RaulRojasE
# Version: 0.1
#######################################################
# Uso:
# ./download.sh [opciones]
#######################################################
# Opciones:
#   -h, --help              Mensaje de ayuda
#   -r, --read_type         Tipo de reads {SE|PE}
#   -s, --samples           Identificarores SRA {SRR....,SRR...,SRR....}
#######################################################
# Ejemplo de uso:
# ./download.sh -r PE -s SRR1234,SRR1235,SRR12346
#######################################################

#Solicitud de mensaje de ayuda en el script 
mensaje_ayuda(){
    echo "./download.sh [opciones]"
    echo "Opciones:"
    echo "   -h,  --help             Mensaje de ayuda"
    echo "   -r, --read_type         Tipo de reads {SE|PE}"
    echo "   -s, --samples           Identificarores SRA {SRR....,SRR...,SRR....}"
    echo "Ejemplo de uso:"
    echo "./download.sh -r PE -s SRR1234,SRR1235,SRR12346"
}

#######################################################
#Comprobación de parámetros de entrada

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in 
        -h|--help)
            mensaje_ayuda
            exit 0
            ;;
        -r|--read_type)
            read_type="$2"
            shift 2
            ;;
        -s|--samples)
            samples="$2"
            shift 2
            ;;
        *)
            echo "Opción no válida: $1"
            exit 1
            ;;
    esac
done

#######################################################

if [[ "$read_type" != "SE" && "$read_type" != "PE" ]]; then
    echo "Error: El tipo de reads debe seer SE o PE."
    exit 1
fi

if [ -z "$samples" ]; then
    echo "Error: Se requiere una lista de identificarores SRR."
    exit 1
fi

#######################################################

#Verificar dependencias instaladas 
verificar_dependencias "fasterq-dump"

#######################################################

#descarga por cada ID 

for sample in $(echo $samples | tr ',' ' ' )
do 
    #echo "download..."
    if [ "$read_type" == "PE" ]; then
        fasterq-dump $sample --split-files
    else 
        fasterq-dump $sample  
    fi
done

