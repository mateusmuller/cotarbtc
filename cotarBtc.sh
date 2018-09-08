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
#   v1.2 07/09/2018
#       - Alterado expressão regular e nome da função principal
#   v2.0 07/09/2018
#       - Refeito todo design do código
#       - Removido o teste de parâmetro
#       - Função de dump foi movida para o final do arquivo para não afetar na performance de outros comandos como -h e -v
#       - Adicionado variáveis padrão para sempre ser executado com algum parâmetro (linhas 69 e 70)
#       - Otimizada a função de mensagens de 8 linhas para 2
#       - Alterado o nome das funções para seguir o padrão Português
#       - Função principal foi alterado de for para while, melhorando a leitura do mesmo
#       - Funçã de dump da Internet foi adicionada diretamente no comando read, ao invés de uma variável antes
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
VERSAO="v2.0"
# ------------------------------------------------------------------------ #

# -------------------------------TESTES----------------------------------------- #
# Lynx instalado?
[ ! -x "$(which lynx)" ] && printf "${AMARELO}Precisamos instalar o ${VERDE}Lynx${AMARELO}, por favor, digite sua senha:${SEM_COR}\n" && sudo apt install lynx 1> /dev/null 2>&1 -y
# ------------------------------------------------------------------------ #

# -------------------------------VARIÁVEIS AVANÇADAS----------------------------------------- #
API_MERCADO_BITCOIN="https://www.mercadobitcoin.net/api/BTC/ticker/"
DESCRICAO_DAS_INFORMACOES=(
  "Maior preço unitário de negociação das últimas 24 horas: "
  "Menor preço unitário de negociação das últimas 24 horas: "
  "Quantidade negociada nas últimas 24 horas: "
  "Preço unitário da última negociação: "
  "Maior preço de oferta de compra das últimas 24 horas: "
  "Menor preço de oferta de venda das últimas 24 horas: "
  "Data: "
)
TEMPO_DE_ATUALIZACAO=${1:-1}
VEZES_EXECUTADAS=${2:-10}
# ------------------------------------------------------------------------ #

# -------------------------------FUNÇÕES----------------------------------------- #
FormataData () {
  date -d "@${1}" +%d/%m/%Y # Formata de Unix para dd/mm/yyyy
}

MostraDados () {
  # O parâmetro 6 significa que é a DATA e precisa ser formatada para dd/mm/yyyy
  [ $1 -eq 6 ] && echo -e "${VERDE}${DESCRICAO_DAS_INFORMACOES[$1]}${AMARELO}$(FormataData ${ARRAY_JSON_MERCADO_BITCOIN[$1]})\n--" && return
  echo -e "${VERDE}${DESCRICAO_DAS_INFORMACOES[$1]}${AMARELO}${ARRAY_JSON_MERCADO_BITCOIN[$1]}"
}

ListaDados () {
local contador=0
local contador_2=0

while [[ $contador -lt $VEZES_EXECUTADAS ]]; do
  while [[ $contador_2 -lt ${#ARRAY_JSON_MERCADO_BITCOIN[@]} ]]; do # Enquanto for menor que length
    MostraDados $contador_2
    contador_2=$(($contador_2+1))
  done
  sleep $TEMPO_DE_ATUALIZACAO
  contador=$(($contador+1))
  contador_2=0
done
}
# ------------------------------------------------------------------------ #

# -------------------------------EXECUÇÃO----------------------------------------- #
if test -n "$1"; then
  case "$1" in
    -v|--version) printf "Versão $VERSAO\n" && exit 0 ;;
    -h|--help)    printf "$MENSAGEM_USO\n"  && exit 0 ;;
  esac
fi

# Executa no final para não influenciar na performance
read -r -a ARRAY_JSON_MERCADO_BITCOIN <<< "$(lynx -source $API_MERCADO_BITCOIN | sed 's/[^0-9 .]//g')" # Cria Array com os valores

ListaDados
# ------------------------------------------------------------------------ #
