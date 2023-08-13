#!/bin/bash

# Establecer la frecuencia máxima permitida en GHz (3.0 GHz en este caso)
MAX_FREQUENCY=3000000  # Representa 3.0 GHz en unidades de Hz

# Número de CPUs disponibles (ajústalo según la cantidad de núcleos y hilos de tu CPU)
NUM_CPUS=8

# Función para obtener la frecuencia actual de la CPU en Hz
function get_cpu_frequency() {
    # Inserta aquí los comandos para obtener la frecuencia actual de la CPU con cpupower
    freq=$(cpupower frequency-info -p | awk '{print $2}')
    # Extraer solo el valor numérico sin caracteres adicionales
    freq="${freq//[!0-9]/}"
    echo "$freq"
}

# Función para limitar el uso de CPU de la aplicación Pamac Manager
function limit_pamac_cpu() {
    # Inserta aquí los comandos para ejecutar Pamac Manager con cpulimit para limitar su uso de CPU
    cpulimit -e pamac-manager -l 50 -c "$NUM_CPUS"  # Limitar Pamac Manager al 50% de uso de CPU en las CPUs disponibles
}

# Obtener la frecuencia actual de la CPU en Hz
cpu_freq=$(get_cpu_frequency)

if ((cpu_freq > MAX_FREQUENCY)); then
    # Si la frecuencia es mayor que 3.0 GHz, limitar el uso de CPU de Pamac Manager
    limit_pamac_cpu
fi

# Ejecutar Pamac Manager (reemplaza 'pamac-manager' por el comando real para ejecutar Pamac Manager si es necesario)
pamac-manager
