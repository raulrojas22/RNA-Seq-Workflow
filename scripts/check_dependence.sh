#!/bin/bash

#######################################################
# Función script: Comprobar instalación de dependencias a utilizar
# Autor: RaulRojasE
# Version: 0.1
#######################################################

#######################################################
#Verificar dependencias instaladas 

verificar_dependencias(){
    dependence=$1

    if ! command -v "$dependence" &> /dev/null
    then 
        echo "$dependence no esta instalado. Por favor, instalar antes de ejecutar este script"
        exit 1
    fi
}
#######################################################

