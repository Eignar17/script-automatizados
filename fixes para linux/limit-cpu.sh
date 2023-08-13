#!/bin/bash

# Establecer la frecuencia máxima de la CPU a 4.40 GHz
cpupower frequency-set --max 4.40GHz

# Comprueba si el cambio se realizó correctamente
if [ $? -eq 0 ]; then
    echo "La frecuencia máxima de la CPU se ha limitado a 4.40 GHz."
else
    echo "Se produjo un error al intentar limitar la frecuencia máxima de la CPU."
fi
