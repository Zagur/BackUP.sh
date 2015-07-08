#!/bin/bash
# Jesús Camacho
# Versió: 1.0
# Aquest script realitza les còpies de seguretat de tots els sistemes de Can Fugarolas

### VARIABLES ###
#################
source backup.cnf

### FUNCIONS ###
################
function enviarDadesSSH {
        scp $1 $userBK@$IPBK:$2
}

function comprimirDir {
        tar cfz $1 $2 2>/dev/null
}

function eliminaFitxers {
        rm $1 2>/dev/null
}

function registreLog {

        if [ "$?" == 0 ]
        then
                #       DATA - OPCIO -  S'ha copiat correctament NOMFITXER a PATHBK
                echo "$dataLog - $num - S'ha copiat correctament $1 a $2." >> $pathLogFile
        else
                echo "$dataLog - $num - ERROR: Hi ha algun problema" >> $pathLogFile
        fi
}

function exportarBBDD {
        mysqldump -u root -psuper8 --all-databases > $1 2>/dev/null
}

function posarABin {
        # Si és igual a 0, no se executa des de /bin, per tant...
        if [ `echo $0 | grep /bin/ | wc -l` = 0 ]
        then
                # Si hi ha alguna versió anterior, l'esborro
                antics=`ls -l /bin/  | grep BackUP | wc -l`
                if [  $antics != 0 ]
                then
                        rm -f /bin/BackUP.sh
                fi
        # Copio la nova versió a /bin i es podrà executar com una altre comanda
        chmod 700 $0
        chown root:root $0
        head -15 $0 | sed -i 's/source /etc/backup.cnf/source \/etc\/backup.cnf/g' $0 >> $0
        cp $0 /bin/
        # Modifiquem la variable estaEnBin per a que no s'executi sempre aquesta funció
        cat backup.cnf | sed -i 's/estaEnBin=0/estaEnBin=1/g' backup.cnf >> backup.cnf
        echo "$dataLog - NOTICIA: $0 s'ha copiat correctament a /bin" >> $pathLogFile
        # El fitxer de configuració
        chmod 755 backup.cnf
        cp backup.cnf /etc
        fi
}

### PROGRAMA PRINCIPAL ###
##########################

if [ "$estaEnBin" == 0  ]
then
        posarABin
fi

# maxChar és un valor, wc -c mostra el nombre
# de caracters que conté la variable $options
maxChar=`echo $options | wc -c`
# maxBucle és la meitat del valor que mostra maxChar
maxBucle=`expr $maxChar / 3`

count=1
while [ $count -le $maxBucle ]
do
        # Mostra el primer número de la variable $options, després el segon, etc
        num=`echo $options | cut -d":" -f$count`

        case $num in
        01) # Configuració
                echo "HOLA"
        ;;
        02) #
                echo "opció 2"
        ;;
        03) # Registre de proxmox (logs)
                comprimirDir $fileNameProxLog $pathProxLog
                enviarDadesSSH $fileNameProxLog $pathBKProxLog
                eliminarFitxers $fileNameProxLog
                registreLog $fileNameProxLog $pathWeb
        ;;

        # 4, 5, 6, 7...

        10) ## Configuració serveis: DNS
                comprimirDir $fileNameDNS $pathDNS
                enviarDadesSSH $fileNameDNS $pathBKDNS
                eliminaFitxers $fileNameDNS
                registreLog $fileNameDNS $pathBKDNS
        ;;
        11) ## Configuració serveis: WEB
                comprimirDir $fileNameWEB $pathWEB
                enviarDadesSSH $fileNameWEB $pathBKWEB
                eliminaFitxers $fileNameWEB
                registreLog $fileNameWEB $pathBKWEB
        ;;
        12) ## Configuració serveis: PXE
                comprimirDir $fileNamePXE $pathPXE
                enviarDadesSSH $fileNamePXE $pathBKPXE
                eliminaFitxers $fileNamePXE
                registreLog $fileNamePXE $pathBKPXE
        ;;
        13) ## Configuració serveis: MySQL
                comprimirDir $fileNameSQL $pathSQL
                enviarDadesSSH $fileNameSQL $pathBKSQL
                eliminaFitxers $fileNameSQL
                registreLog $fileNameSQL $pathBKSQL
        ;;
        14) ## Configuració serveis: SSH
                comprimirDir $fileNameSSH $pathSSH
                enviarDadesSSH $fileNameSSH $pathBKSSH
                eliminarFitxers $fileNameSSH
                registreLog $fileNameSSH $pathBKSSH
        ;;
        15) ## Configuració serveis: F2B
                comprimirDir $fileNameF2B $pathF2B
                enviarDadesSSH $fileNameF2B $pathBKF2B
                eliminarFitxers $fileNameF2B
                registreLog $fileNameF2B $pathBKF2B
        ;;
        16) ## Dades dels serveis: Apache (webs)
                comprimirDir $fileNameDadesWEB $pathDadesWEB
                enviarDadesSSH $fileNameDadesWEB $pathDadesBKWEB
                eliminarFitxers $fileNameDadesWEB
                registreLog $fileNameDadesWEB $pathDadesBKWEB
        ;;
        17) ## Dades dels serveis: PXE (Menus)
                comprimirDir $fileNameDadesPXE $pathDadesPXE
                enviarDadesSSH $fileNameDadesPXE $pathDadesBKPXE
                eliminarFitxers $fileNameDadesPXE
                registreLog $fileNameDadesPXE $pathDadesBKPXE
        ;;
        18) ## Dades dels serveis: MySQL (BBDD)
                comprimirDir $fileNameDadesSQL $pathDadesSQL
                enviarDadesSSH $fileNameDadesSQL $pathDadesBKSQL
                eliminarFitxers $fileNameDadesSQL
                registreLog $fileNameDadesSQL $pathDadesBKSQL

                exportarBBDD $fileNameSQLFormat
                enviarDadesSSH $fileNamesSQLFormat $pathDadesBKSQL
                eliminarFitxers $fileNameSQLFormat
                registreLog $fileNameSQLFormat $pathDadesBKSQL
        ;;


        *)
                # marcarhoallog
                echo "Cap opció"
        ;;
        esac
        count=$(( $count + 1 ))
done

## FI DEL PROGRAMA

###
###

#######################################################################
# Script creat Jesús Camacho                                          #
# Es permet la còpia i modificació de l'script, sempre que sigui      #
# sense ànim de lucre o amb finalitats comercials, sempre que no es   #
# modifiqui el seu contingut, es respecti a la seva autoria i les     #
# notes del inici i aquesta es mantinguin.                            #
#######################################################################