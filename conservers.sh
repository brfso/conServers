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

		while [ -z ${USERNAME} ];
		do
			read -p "Digite o seu usuário da WIKI: " USERNAME
		done

		while [ -z ${PASSWORD} ];
		do
		read -s -p "Digite a senha do seu usuário da WIKI: " PASSWORD
		done
		ruby /usr/bin/getServers.rb ${USERNAME} ${PASSWORD} ${URL}
		return_code
	fi

EMPRESAS=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | awk -F";" '{print $1}' | sort -d | uniq)

clear
select selectedEmploye in $EMPRESAS; do
	
	if [ -z ${selectedEmploye} ];then
		echo "Opção Inválida, Digite a opção correta ou Crtl + C para sair: " 
	else
		clear
		HOST=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w $selectedEmploye | awk -F";" '{print $5}' | sort -d | uniq)
		echo "Selecione o servidor no qual você deseja se conectar: "
	select selectedHost in $HOST; do

		if [ -z ${selectedHost} ];then
			echo "Opção Inválida, Digite a opção correta ou Crtl + C para sair: " 
		else
			PORTA=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w $selectedHost | awk -F";" '{print $4}')
			USUARIO=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w $selectedHost | awk -F";" '{print $3}')
			SERVER=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "${SERVERS_LIST}" | grep -v ^# | grep -w $selectedHost | awk -F";" '{print $2}')
			ssh -i $SSH_KEY -p"$PORTA" "$USUARIO"@"$SERVER"
		fi
	  done
  	fi
  done