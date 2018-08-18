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
#       - Versão inicial com 
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 4.4.19
# ------------------------------------------------------------------------ #

# -------------------------------VARIÁVEIS BÁSICAS----------------------------------------- #
# CORES PARA O PRINTF
VERDE='\033[1;32m'
SEM_COR='\033[0m'
AMARELO='\033[1;33m'
VERMELHO='\033[1;31m'
# ------------------------------------------------------------------------ #

# -------------------------------TESTES----------------------------------------- #
[ ! $UID -eq 0 ] && printf "${VERMELHO}Usuário não é root.${SEM_COR}\n" && exit 1
[ ! -x "$(which lynx)" ] && printf "${AMARELO}Instalando o Lynx${SEM_COR}\n" && apt install lynx 1> /dev/null 2>&1 -y
# ------------------------------------------------------------------------ #

# -------------------------------VARIÁVEIS AVANÇADAS----------------------------------------- #
API_MERCADO_BITCOIN="https://www.mercadobitcoin.net/api/BTC/ticker/" 
JSON_MERCADO_BITCOIN=$(lynx -source $API_MERCADO_BITCOIN | # Código JSON da API
                            sed 's/[{|}]//g ; 
                                s/"ticker": // ; 
                                s/"//g ; 
                                s/,//g' | # Remove os caracteres {},ticker:" e deixa somente as palavras e números
                            cut -d ' ' -f 2,4,6,8,10,12,14) # Extrai somente os números

# Cria um ARRAY com os números coletados
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
# ------------------------------------------------------------------------ #

# -------------------------------FUNÇÕES----------------------------------------- #
FormataData () {
    date -d "@${1}" +%d/%m/%Y
}

Mensagens () {
    printf "${AMARELO}${DESCRICAO_DAS_INFORMACOES[$numero]}${NO_COLOR}"
    
    if [ "$1" = "data" ]; then
        printf "${VERDE}%s" "$(FormataData ${ARRAY_JSON_MERCADO_BITCOIN[$numero]})" "${NO_COLOR}"
    else        
        printf "${VERDE}${ARRAY_JSON_MERCADO_BITCOIN[$numero]}${NO_COLOR}"
    fi

    printf "\n"
}

Main () {
    for numero in $(seq 0 6); do
        if [ $numero -eq 6 ]; then
            Mensagens data
        else
            Mensagens
        fi
    done
}
# ------------------------------------------------------------------------ #

# -------------------------------EXECUÇÃO----------------------------------------- #
Main
# ------------------------------------------------------------------------ #