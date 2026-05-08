# Adresse de chargement standard pour S905X3
setenv loadaddr "0x01080000"

echo "--- Initialisation Armbian ---"
echo "Pause de 5 secondes pour diagnostic..."
sleep 5

# Tentative sur Carte SD
if fatload mmc 0 ${loadaddr} u-boot.ext; then
    echo "Succès : u-boot.ext trouvé sur SD."
    go ${loadaddr}
fi

# Tentative sur USB
if usb start; then
    if fatload usb 0 ${loadaddr} u-boot.ext; then
        echo "Succès : u-boot.ext trouvé sur USB."
        go ${loadaddr}
    fi
fi

echo "ERREUR : u-boot.ext introuvable."
echo "Le boîtier va basculer sur Android dans 5 secondes..."
sleep 5

