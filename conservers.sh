#!/bin/bash
. /etc/conservers.config
  
function return_code() {
  if [ $? -eq 1 ]; then  
    echo " "
    echo -e "\033[31;1m[Fail]\n\033[0m \n"
    exit 1
  fi   
}
if [ ! -f "$SERVERS_LIST" ] || [ "${1}" == '-a' ];
  then
    #while [ -z ${USERNAME} ];
    #do
    ENTRY=$(zenity --title "Wiki Authentication" --username --password)
    #read -p "Digite o seu usuário da WIKI: " USERNAME
    #done
    USERNAME=$(echo $ENTRY | cut -d'|' -f1)
    PASSWORD=$(echo $ENTRY | cut -d'|' -f2)
    #while [ -z ${PASSWORD} ];
    #do
    #read -s -p "Digite a senha do seu usuário da WIKI: " PASSWORD
    #done
    ruby /usr/local/bin/getServers.rb ${USERNAME} ${PASSWORD} ${URL}
    return_code
  fi
EMPRESAS=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | awk -F";" '{print $1}' | sort -d | uniq)
clear
selectedEmploye=$(zenity --list --title="Ambientes" --width=400 --height=600 --column="Seleção" $EMPRESAS)
#select selectedEmploye in $EMPRESAS; do
  if [ -z ${selectedEmploye} ];then
    echo "Opção Inválida, Digite a opção correta ou Crtl + C para sair: "
  else
    clear
    HOST=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w $selectedEmploye | awk -F";" '{print $5}' | sort -d | uniq)
    echo "Selecione o servidor no qual você deseja se conectar: "
    selectedHost=$(zenity --list --title="Servidor" --width=400 --height=600 --column="Seleção" $HOST)
  #select selectedHost in $HOST; do
    if [ -z ${selectedHost} ];then
      echo "Opção Inválida, Digite a opção correta ou Crtl + C para sair: "
    else
      PORTA=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w $selectedHost | awk -F";" '{print $4}')
      USUARIO=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w $selectedHost | awk -F";" '{print $3}')
      SERVER=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w $selectedHost | awk -F";" '{print $2}')
      OPTION=$(zenity --list --title="Conservice" --width=400 --height=600 \
          --column="Seleção" "Acesso Remoto" "Download/Upload")
      if [ "$OPTION" == "Acesso Remoto" ]
        then
          ssh -i $SSH_KEY -p"$PORTA" "$USUARIO"@"$SERVER"
      elif [ "$OPTION" == "Download/Upload" ]
        then
          MODE=$(zenity --list --title="Opção" --column="Seleção" "Upload" "Download")
          if [ "$MODE" == "Upload" ]
      then
            zenity --info --text="Selecione o arquivo para upload."
            FILE=$(zenity --file-selection --title="Selecione um arquivo")
            DEST=$(zenity --entry --text="Caminho do arquivo para upload no servidor:" --entry-text "Caminho")
            scp  $FILE $USUARIO@$SERVER:$DEST
            zenity --info --text="Concluído."
          elif [ "$MODE" == "Download" ]
      then
            zenity --info --text="Selecione diretório para receber o arquivo."
            FILE=$(zenity --file-selection --directory --title="Selecione um diretório")
            DEST=$(zenity --entry --text="Caminho do arquivo para download do servidor:" --entry-text "Caminho")
      #echo "scp $USUARIO@$SERVER:$DEST $FILE"
            scp $USUARIO@$SERVER:$DEST $FILE
            zenity --info --text="Concluído."
    fi
  fi
    #done
    fi
  #done
fi


