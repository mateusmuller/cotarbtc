#!/usr/bin/env bash
#
# cotarBtc.sh - Busca informações sobre o valor do BTC via API do Mercado Bitcoin
#
# Site:       https://4fasters.com.br
# Autor:      Mateus Gabriel Müller
# Manutenção: Mateus Gabriel Müller
#
# ------------------------------------------------------------------------ #
#  Este programa recebe como parâmetro o tempo de atualização em segundos,
#  bem como quantas vezes deve ser mostrado os valores.
#
#  Exemplos:
#      $ ./cotarBtc.sh 5 10
#      No exempo acima será atualizado 10 vezes a cada 5 segundos
# ------------------------------------------------------------------------ #
# Histórico:
#
#   v1.0 18/08/2018, Mateus Müller:
#       - Versão inicial apenas com busca na API
#   v1.1 19/08/2018
#       - Versão 1.1 com menu, -h, -v e parâmetros de repetição
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 4.4.19
# ------------------------------------------------------------------------ #

# -------------------------------VARIÁVEIS BÁSICAS----------------------------------------- #
# Cores para o printf
VERDE='\033[1;32m'
SEM_COR='\033[0m'
AMARELO='\033[1;33m'
VERMELHO='\033[1;31m'

# Mensagem -h
MENSAGEM_USO="
Uso: $(basename "$0") TEMPO_DE_ATUALIZAÇÃO NUMERO_DE_REPETIÇÕES [OPÇÕES]

OPÇÕES:
    -v, --version - Mostra a versão do script
    -h, --help - Mostra opções de ajuda
"
VERSAO="v1.1"
# ------------------------------------------------------------------------ #

# -------------------------------TESTES----------------------------------------- #
# Lynx instalado?
[ ! -x "$(which lynx)" ] && printf "${AMARELO}Precisamos instalar o ${VERDE}Lynx${AMARELO}, por favor, digite sua senha:${SEM_COR}\n" && sudo apt install lynx 1> /dev/null 2>&1 -y

# Sem parâmetros obrigatórios?
[ -z $1 ] && printf "${VERMELHO}[ERRO] - Informe os parâmetros obrigatórios. Consulte a opção -h.\n" && exit 1
# ------------------------------------------------------------------------ #

# -------------------------------VARIÁVEIS AVANÇADAS----------------------------------------- #
API_MERCADO_BITCOIN="https://www.mercadobitcoin.net/api/BTC/ticker/" 
JSON_MERCADO_BITCOIN=$(lynx -source $API_MERCADO_BITCOIN | # Código JSON da API
                            sed 's/[{|}]//g ; 
                                s/"ticker": // ; 
                                s/"//g ; 
                                s/,//g' | # Remove os caracteres {},ticker:" e deixa somente as palavras e números
                            cut -d ' ' -f 2,4,6,8,10,12,14) # Extrai somente os números

# Cria um ARRAY com os números coletados da API
read -r -a ARRAY_JSON_MERCADO_BITCOIN <<< $JSON_MERCADO_BITCOIN

DESCRICAO_DAS_INFORMACOES=(
    "Maior preço unitário de negociação das últimas 24 horas: "
    "Menor preço unitário de negociação das últimas 24 horas: "
    "Quantidade negociada nas últimas 24 horas: "
    "Preço unitário da última negociação: "
    "Maior preço de oferta de compra das últimas 24 horas: "
    "Menor preço de oferta de venda das últimas 24 horas: "
    "Data: "
)
PARAMETRO_1=$1
PARAMETRO_2=$2
# ------------------------------------------------------------------------ #

# -------------------------------FUNÇÕES----------------------------------------- #
FormataData () {
    date -d "@${1}" +%d/%m/%Y # Formata de Unix para dd/mm/yyyy 
}

Mensagens () {
    printf "${AMARELO}${DESCRICAO_DAS_INFORMACOES[$numero]}${NO_COLOR}"
    if [ "$1" = "data" ]; then
        printf "${VERDE}%s" "$(FormataData ${ARRAY_JSON_MERCADO_BITCOIN[$numero]})" "${NO_COLOR}"
        echo -e "\n-----------------------------------------------------------------------------"
    else        
        printf "${VERDE}${ARRAY_JSON_MERCADO_BITCOIN[$numero]}${NO_COLOR}"
    fi
    printf "\n"
}

Main () {
for i in $(seq 1 $PARAMETRO_2); do 
    for numero in $(seq 0 6); do # 7 itens que são mostrados
        if [ $numero -eq 6 ]; then # É a data?
            Mensagens data # Passa o parâmetro "data" para formatar para pt-BR
        else
            Mensagens
        fi
    done
    sleep $PARAMETRO_1 # Tempo de espera
done
}
# ------------------------------------------------------------------------ #

# -------------------------------EXECUÇÃO----------------------------------------- #
while test -n "$1"; do
    case $1 in
         -v|--version) printf "Versão $VERSAO\n" && exit 0 ;;
         -h|--help)    printf "$MENSAGEM_USO\n"  && exit 0 ;;
    esac
    shift
done

Main
# ------------------------------------------------------------------------ #