# armbian_mxqpro4k
# instruction provenant de google IA,

# ==============================================================================
# CONFIGURATION DU DEPOT ENFANT (USERPATCHES) POUR ARMBIAN
# ==============================================================================

1.  IMPORTATION DU DEPOT ENFANT
----------------------------------------------------
git clone de ce depot, la structure est deja existante

ou (1B). PREPARATION DU DEPOT ENFANT A PARTIR DE RIEN (VOTRE CONFIGURATION)
----------------------------------------------------

# Créez votre dossier de configuration (ex: mon-armbian-mxq)
creer le depot sur github ex: armbian_mxqpro4k
faire git clone ... pour avec le repertoire en local

ou en local
mkdir armbian_mxqpro4k
cd armbian_mxqpro4k
git init

# Créez l'arborescence requise
mkdir -p kernel/archive/sunxi-6.18
mkdir -p u-boot/u-boot-sunxi/defconfig
mkdir -p u-boot/u-boot-sunxi/dt

# Ajoutez vos fichiers (mxqpro4k.tvb, lib.config, patches...)
# Puis publiez sur votre serveur distant :
git add .
git commit -m "Initialisation config mxqpro4k"
git remote add origin <URL_DE_VOTRE_DEPOT_DISTANT>
git push -u origin main

2. INTEGRATION DANS LE DEPOT ARMBIAN (PARENT)
----------------------------------------------
# clone depot-armbian
git clone https://github.com/armbian/build.git

# Allez à la racine du dépôt Armbian cloné
cd /chemin/vers/armbian/build

# Nettoyage si le dossier userpatches existe déjà (Important)
mv userpatches ../userpatches_backup
git rm -rf --cached userpatches

# Ajout forcé du sous-module (le nom doit être 'userpatches')
git submodule add -f <URL_DE_VOTRE_DEPOT_DISTANT> userpatches
git commit -m "Liaison du depot enfant userpatches"

3. LIEN POUR LE FICHIER BOARD (L'ETAPE CRUCIALE)
------------------------------------------------
# Armbian doit voir le fichier board dans son dossier interne avant le build
cp userpatches/mxqpro4k.tvb config/boards/mxqpro4k.tvb

4. CONTENU DU FICHIER userpatches/lib.config
---------------------------------------------
# Assurez-vous que votre fichier userpatches/lib.config contient cette ligne :
cp "${USERPATCHES_PATH}/mxqpro4k.tvb" "${SRC}/config/boards/mxqpro4k.tvb"

5. LANCEMENT DE LA COMPILATION
------------------------------
(le fichier config-mxqpro4k.tvb existe pour passer les parametres)
./compile.sh mxqpro4k
ou en specifiant les parametres sur la ligne du compile.sh
./compile.sh BOARD=mxqpro4k BRANCH=current RELEASE=noble KERNEL_CONFIGURE=no

