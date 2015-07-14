!/bin/bash
#JesusCamacho

# Cerca al directori de BackUP els fitxers amb més de 5 dies després de la seva creació
find /media/BK/ -mtime +5 | grep tar.gz >> removeFiles

#Per tar.gz
while read file
do
        rm $file -f

done < removeFiles

#Per .sql
find /media/BK/ -mtime +5 | grep .sql >> removeFilesSQL

while read file
do
        rm $file -f
done < removeFilesSQL

