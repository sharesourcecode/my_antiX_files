#!/bin/bash

# 1. Verifica se a placa física é vista pelo ALSA
if ! grep -q "HDA-Intel" /proc/asound/cards; then
    STATUS="FISICO"
# 2. Verifica se existem erros de inicialização nos logs do Kernel
elif dmesg | tail -n 50 | grep -iqE "hda-intel.*(error|timeout|failed|no response)"; then
    STATUS="LOG_ERRO"
else
    STATUS="OK"
fi

if [ "$STATUS" != "OK" ]; then
    echo "[$(date)] Falha detectada ($STATUS). Tentando resetar driver..." >> /home/cabana/log_audio.txt
    
    # Tenta o soft-reset removendo o driver do kernel
    sudo modprobe -r snd_hda_intel
    sleep 2
    sudo modprobe snd_hda_intel
    
    # Segunda verificação após o reset
    sleep 3
    if ! grep -q "HDA-Intel" /proc/asound/cards; then
        echo "[$(date)] Reset falhou. Reiniciando sistema." >> /home/cabana/log_audio.txt
        sudo /sbin/reboot
    fi
else
    echo "Áudio operando normalmente."
fi
