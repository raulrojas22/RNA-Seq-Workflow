#!/bin/bash

#######################################################
# Función script: Trimming de reads
# Autor: RaulRojasE
# Version: 0.1
#######################################################
# Uso:
# ./trimming.sh [opciones]
#######################################################
# Opciones:
#   -h, --help      Mensaje de ayuda
#   -d, --directory Especifica el directorio de entrada
#   -o, --output    Especifica el directorio de salida (De no existir, se crea)
#######################################################
# Ejemplo de uso:
# ./trimming.sh -d /ruta/de/entrada -o /ruta/de/salida
#######################################################

#Importar scripts a utilizar
source check_dependence.sh

#######################################################
#Solicitud de mensaje de ayuda en el script 
mensaje_ayuda(){
    echo -e "\n./trimming.sh [opciones]"
    echo "Opciones:"
    echo "   -h, --help      Mensaje de ayuda"
    echo "   -d, --directory Especifica el directorio de entrada "
    echo "   -o, --output    Especifica el directorio de salida (De no existir, se crea)"
    echo -e "\nAl ejecutar el script se solicitaran diversos parámetros para ejecutar la limpieza de reads."
    echo -e "Una vez ejecutado se solicitaran los parametros propios para trimmomatic:\n"
    echo "Tipo de reads: {SE o PE}"
    echo "MINLEN: n"
    echo "Ruta de adaptador: /ruta/ [OPCIONAL]"
    echo "LEADING: n [OPCIONAL]"
    echo "TRAILING: n [OPCIONAL]"
    echo "SLIDINGWINDOW: n:n [OPCIONAL]"
    echo -e "\nEjemplo de uso:"
    echo -e "./trimming.sh -d /ruta/de/entrada -o /ruta/de/salida\n"
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
verificar_dependencias "trimmomatic"

#######################################################
#Petición de parámetros
read -p "Ingrese tipo de reads (SE o PE): " read_type
read -p "Ingrese MINLEN: " minlen
read -p "Ingrese ruta de adaptador (puede ser omitido): " ILLUMINACLIP
read -p "Ingrese LEADING (puede ser omitido): " LEADING
read -p "Ingrese TRAILING (puede ser omitido): " TRAILING
read -p "Ingrese SLIDINGWINDOW (puede ser omitido): " SLINDINGWINDOW

#######################################################
#Construcción de comando final y análisis por cada archivo FASTQ

parametros_opcionales=("ILLUMINACLIP" "LEADING" "TRAILING" "SLINDINGWINDOW")
comando_trimmomatic="MINLEN:$minlen"
#comando_trimmomatic="java -jar trimmomatic.jar $read MINLEN:$minlen" #v2_linux

for parametro in "${parametros_opcionales[@]}"
do
    if [ -n "${!parametro}" ]; then
        comando_trimmomatic="$comando_trimmomatic $parametro:${!parametro}"
    fi
done
echo "comando: $comando_trimmomatic"

alinear_SE(){
    for archivo in "$directorio_entrada"/*.fastq.gz; do
        nombre_archivo=$(basename "$archivo" .fastq.gz)
        trimmomatic $read_type -phred33 $archivo $directorio_salida/$nombre_archivo-procesado.fastq.gz $comando_trimmomatic
    done
}

alinear_PE(){
    for archivo in "$directorio_entrada"/*_1.fastq.gz; do
        nombre_archivo=$(basename "$archivo" _1.fastq.gz)
        trimmomatic $read_type -phred33 $directorio_entrada/$nombre_archivo"_1.fastq.gz" $directorio_entrada/$nombre_archivo"_2.fastq.gz" $directorio_salida/$nombre_archivo-_1_trimmed_paired.fastq.gz $directorio_salida/$nombre_archivo-_1_trimmed_unpaired.fastq.gz $directorio_salida/$nombre_archivo-_2_trimmed_paired.fastq.gz $directorio_salida/$nombre_archivo-_2_trimmed_unpaired.fastq.gz $comando_trimmomatic
    done
}


if [ "$read_type" == "SE" ]; then
    alinear_SE
elif [ "$read_type" == "PE" ]; then
    alinear_PE
fi
