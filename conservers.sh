#!/bin/bash -x
. /etc/conservers.config

set -o errexit
set -o pipefail
set -o nounset

UPDATE="false"
GUI_MODE="false"
USERNAME=""
PASSWORD=""
_HOST=""

USAGE=$(cat <<END
Usage:  $0 [OPTIONS]

conServer

Options:
 -u,   --update        Update Server List
 -gui, --gui-mode      Use GUI Mode 
 -h,   --help          Displays usage info
END
)

while [[ $# -gt 0 ]]
do
  case $1 in
    -gui|--gui-mode)
      GUI_MODE="true"
      shift
    ;;
    -u|--update)
      UPDATE="true"
      shift
    ;;
    -h|--help)
      echo -e "$USAGE"; exit 0;
    ;;
    *)
      (>&2 echo -e "unknown option: ${1} ${2:-}\n"; echo -e "$USAGE"; exit 1;)
    ;;
  esac
done
  
function return_code() {
  if [ $? -eq 1 ]; then  
    echo " "
    echo -e "\033[31;1m[Fail]\n\033[0m \n"
    exit 1
  fi   
}

function hostConnect() {
  local _HOST=${1} 
  SERVER_PORT=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep ${_HOST} | awk -F";" '{print $4}')
  SERVER_USER=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep ${_HOST} | awk -F";" '{print $3}')
  SERVER=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep ${_HOST} | awk -F";" '{print $2}')
  ssh -i $SSH_KEY -p"$SERVER_PORT" "$SERVER_USER"@"$SERVER"
}

if [ ! -f "$SERVERS_LIST" ] || [ "${UPDATE}" == 'true' ];
  then
    if [ ${GUI_MODE} == "false" ];
      then
        while [ -z ${USERNAME} ];
          do
            read -p "Type your Username: " USERNAME
          done
        
        while [ -z ${PASSWORD} ];
          do
            read -s -p "Type your Password: " PASSWORD
          done
          
        ruby /usr/local/bin/getServers.rb ${USERNAME} ${PASSWORD} ${URL}
        return_code
    else 
      ENTRY=$(zenity --title "Authentication" --username --password)

      USERNAME=$(echo $ENTRY | cut -d'|' -f1)
      PASSWORD=$(echo $ENTRY | cut -d'|' -f2)

      ruby /usr/local/bin/getServers.rb ${USERNAME} ${PASSWORD} ${URL}
      return_code

    fi
fi

COMPANIES=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | awk -F";" '{print $1}' | sort -d | uniq)
clear

if [ ${GUI_MODE} == "false" ];
  then
    select selectedCompany in $COMPANIES; 
  do	
    if [ -z ${selectedCompany} ];
      then
        echo "Opção Inválida, Digite a opção correta ou Crtl + C para sair: " 
    else
      clear
      HOST=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep $selectedCompany | awk -F";" '{print $5}' | uniq)
      echo "Selecione o servidor no qual você deseja se conectar: "
      select selectedHost in $HOST; 
        do
          if [ -z ${selectedHost} ];then
            echo "Opção Inválida, Digite a opção correta ou Crtl + C para sair: " 
          else
            hostConnect ${selectedHost} 
          fi
        done
    fi
  done
else
   selectedCompany=$(zenity --list --title="conServers" --width=400 --height=600 --column="Select" $COMPANIES)
    if [ -z ${selectedCompany} ];
      then
        zenity --info --text="Selected Company is null"
    else
      clear
      FILTER=$(echo $selectedCompany | awk -F "|" '{print $1}')
      HOST=$(cat "${SERVERS_LIST}" | grep -v ^# | grep ${FILTER} | awk -F";" '{print $5}' | uniq)
      echo "Selecione o servidor no qual você deseja se conectar: "
      selectedHost=$(zenity --list --title="Servidor" --width=400 --height=600 --column="Seleção" $HOST)
      if [ -z ${selectedHost} ];
        then
          zenity --info --text="Selected Server is null"
      else
        FILTER=$(echo $selectedHost | awk -F "|" '{print $1}')
        SERVER_PORT=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w ${FILTER} | awk -F";" '{print $4}')
        SERVER_USER=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w ${FILTER} | awk -F";" '{print $3}')
        SERVER=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w ${FILTER} | awk -F";" '{print $2}')
        OPTION=$(zenity --list --title="Conservice" --width=400 --height=600 \
          --column="Seleção" "Acesso Remoto" "Download/Upload"| awk -F"|" '{print $1}')
        if [ "$OPTION" == "Acesso Remoto" ];
          then
            ssh -i $SSH_KEY -p"$SERVER_PORT" "$SERVER_USER"@"$SERVER"
        elif [ "$OPTION" == "Download/Upload" ];
          then
            MODE=$(zenity --list --title="OPTIONS" --column="SELECTION" "Upload" "Download")
            if [ "$MODE" == "Upload" ];
              then
                zenity --info --text="Selecione o arquivo para upload."
                FILE=$(zenity --file-selection --title="Selecione um arquivo")
                DEST=$(zenity --entry --text="Caminho do arquivo para upload no servidor:" --entry-text "Caminho")
                scp  $FILE $SERVER_USER@$SERVER:$DEST
                zenity --info --text="Concluído."
            elif [ "$MODE" == "Download" ]
              then
                zenity --info --text="Selecione diretório para receber o arquivo."
                FILE=$(zenity --file-selection --directory --title="Selecione um diretório")
                DEST=$(zenity --entry --text="Caminho do arquivo para download do servidor:" --entry-text "Caminho")
                scp $SERVER_USER@$SERVER:$DEST $FILE
                zenity --info --text="Concluído."
            fi
        fi
      fi
    fi
fi

