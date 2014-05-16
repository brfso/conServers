#!/bin/bash 
CHAVE=".ssh/id_rsa"
ARQ_CONECTA="conecta.txt"
#seleciona apenas as linhas q se iniciam com um nome maiusculo + ;
#egrep "^[A-Z0-9]+;"
#filtra somente as linhas q possuem o padrão. Somente as linhas q possuem 5 campos (4 delimitadores) e com o 4 campo numerico
#egrep  '^(.*;){3}[0-9]+;[^;]+$' conecta.txt
 
digita_erro(){
if [ $? -ne 0 ] ; then
        echo "$MSGM"
        exit 1
fi
}
 
MSGM="Arquivo de configuracao nao encontrado"
test -f "$ARQ_CONECTA" ; digita_erro
MSGM="BURRO PRA CARAIU!"
ARQUIVO_TMP="/tmp/conectaSH-empresas.txt"
EMPRESAS=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "$ARQ_CONECTA" | grep -v ^# | awk -F";" '{print $1}' | uniq| nl | awk {'print $1"-"$2'}| tee "$ARQUIVO_TMP")
for i in $EMPRESAS ; do
    echo -ne "\033[31;1m[\033[0m\033[33;1m"$i"\033[0m\033[31;1m]\033[0m\t" ; done
echo ""
read -p "Escolha a empresa: " EMPRESA
grep ^"$EMPRESA" "$ARQUIVO_TMP" &> /dev/null|| read -p  "Opcao inexistente Digite novamente:" EMPRESA
grep ^"$EMPRESA" "$ARQUIVO_TMP" &> /dev/null
digita_erro
 
#transforma a variavel EMRPESA de numero para o nome
EMPRESA=$(awk -F- '$1 == '$EMPRESA' {print $2}' "$ARQUIVO_TMP")
J_HOST=$(egrep  '^(.*;){3}[0-9]+;[^;]+$' "$ARQ_CONECTA" | grep ^"$EMPRESA" | nl | awk {'print $1";"$2'} |tee "$ARQUIVO_TMP" )
for i in $(awk -F";" {'print $1"-"$6'} "$ARQUIVO_TMP")  ; do
    echo -ne "\033[31;1m[\033[0m\033[33;1m"$i"\033[0m\033[31;1m]\033[0m\t" ; done
echo ""
read -p "Escolha o servidor: " SERVIDOR
grep ^"$SERVIDOR" "$ARQUIVO_TMP" &> /dev/null|| read -p  "Opcao inexistente Digite novamente:" SERVIDOR
grep ^"$SERVIDOR" "$ARQUIVO_TMP" &> /dev/null
digita_erro
 
J_SERVIDOR=$(grep -w ^"$SERVIDOR" /tmp/conectaSH-empresas.txt)
J_SERVER=$(echo "$J_SERVIDOR" | awk -F";" '{print $3}')
J_USUARIO=$(echo "$J_SERVIDOR" | awk -F";" '{print $4}')
J_PORTA=$(echo "$J_SERVIDOR" | awk -F";" '{print $5}')
ssh -i "$CHAVE" -p"$J_PORTA" "$J_USUARIO"@"$J_SERVER"
