#!/bin/bash

#######################################################
# Función script: Entregar reportes de calidad de reads formato fastq
# Autor: RaulRojasE
# Version: 0.1
#######################################################
# Uso:
# ./analisis_calidad.sh [opciones]
#######################################################
# Opciones:
#   -h, --help      Mensaje de ayuda
#   -d, --directory Especifica el directorio de entrada
#   -o, --output    Especifica el directorio de salida (De no existir, se crea)
#######################################################
# Ejemplo de uso:
# ./analisis_calidad.sh -d /ruta/de/entrada -o /ruta/de/salida
#######################################################

#Importar scripts a utilizar
source scripts/check_dependence.sh

#######################################################
#Solicitud de mensaje de ayuda en el script 
mensaje_ayuda(){
    echo -e "\n./analisis_calidad.sh [opciones]"
    echo "Opciones:"
    echo "   -h, --help      Mensaje de ayuda"
    echo "   -d, --directory Especifica el directorio de entrada "
    echo "   -o, --output    Especifica el directorio de salida (De no existir, se crea)"
    echo "Ejemplo de uso:"
    echo -e "./analisis_calidad.sh -d /ruta/de/entrada -o /ruta/de/salida\n"
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
#Comprobación de parámetros de entrada (rutas)
while [[ "$#" -gt 0 ]]; do 
    case $1 in
        -h|--help) mensaje_ayuda; exit 0;;
        -d|--directory) 
            if [ ! -d "$2" ]; then
                echo "Error: El directorio de entrada '$2' no existe"
                exit 1
            fi
            directorio_entrada="$2"; 
            shift ;;
        -o|--output) crear_directorio $2; directorio_salida="$2"; shift ;;
        *) echo "Opción no válida: $1. Use -h o --help para ver la ayuda."; exit 1 ;;
    esac
    shift
done 

#######################################################
#Verificar dependencias instaladas 
verificar_dependencias "fastqc"
verificar_dependencias "multiqc"

#######################################################
#Analisis de calidad con fastqc y posteriormente multiqc

fastqc $directorio_entrada/*.fastq -o $directorio_salida 
multiqc $directorio_salida/. -o $directorio_salida 

#######################################################
