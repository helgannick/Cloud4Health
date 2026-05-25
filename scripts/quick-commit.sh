#!/bin/bash
# ============================================================================
# Cloud4Health - Quick Commit Script
# Script rápido para fazer commit e push
# ============================================================================

set -e

echo "=========================================="
echo "🚀 Cloud4Health - Quick Commit"
echo "=========================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# 1. Verificações Pré-Commit
# ============================================================================
echo -e "${BLUE}📋 Executando verificações...${NC}"
if [ -f "./scripts/pre-commit-check.sh" ]; then
    ./scripts/pre-commit-check.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo -e "${RED}❌ Verificações falharam! Corrija os erros antes de continuar.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Script de verificação não encontrado, pulando...${NC}"
fi

echo ""

# ============================================================================
# 2. Status do Git
# ============================================================================
echo -e "${BLUE}📊 Status atual do Git:${NC}"
git status --short
echo ""

# ============================================================================
# 3. Adicionar Arquivos
# ============================================================================
echo -e "${YELLOW}Deseja adicionar TODOS os arquivos? (y/n)${NC}"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}➕ Adicionando arquivos...${NC}"
    git add .
    echo -e "${GREEN}✅ Arquivos adicionados${NC}"
else
    echo -e "${YELLOW}ℹ️  Adicione arquivos manualmente com: git add <arquivo>${NC}"
    exit 0
fi

echo ""

# ============================================================================
# 4. Ver Mudanças
# ============================================================================
echo -e "${BLUE}📝 Arquivos que serão commitados:${NC}"
git status --short
echo ""

echo -e "${YELLOW}Continuar com o commit? (y/n)${NC}"
read -r response

if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}ℹ️  Commit cancelado${NC}"
    exit 0
fi

# ============================================================================
# 5. Mensagem de Commit
# ============================================================================
echo ""
echo -e "${BLUE}📝 Digite a mensagem do commit:${NC}"
echo -e "${YELLOW}   Dica: Use formato 'tipo(escopo): descrição'${NC}"
echo -e "${YELLOW}   Exemplo: feat(networking): add VPC module${NC}"
echo ""
read -r commit_message

if [ -z "$commit_message" ]; then
    echo -e "${RED}❌ Mensagem de commit não pode ser vazia!${NC}"
    exit 1
fi

# ============================================================================
# 6. Commit
# ============================================================================
echo ""
echo -e "${BLUE}💾 Fazendo commit...${NC}"
git commit -m "$commit_message"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Commit realizado com sucesso!${NC}"
else
    echo -e "${RED}❌ Erro ao fazer commit${NC}"
    exit 1
fi

echo ""

# ============================================================================
# 7. Push (Opcional)
# ============================================================================
echo -e "${YELLOW}Deseja fazer push para o GitHub agora? (y/n)${NC}"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo -e "${BLUE}🚀 Fazendo push...${NC}"
    
    # Verificar se há remote configurado
    if ! git remote | grep -q 'origin'; then
        echo -e "${RED}❌ Remote 'origin' não configurado!${NC}"
        echo -e "${YELLOW}   Configure com: git remote add origin <url>${NC}"
        exit 1
    fi
    
    # Obter branch atual
    current_branch=$(git branch --show-current)
    
    # Push
    git push origin "$current_branch"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}=========================================="
        echo "✅ Push realizado com sucesso!"
        echo "==========================================${NC}"
        echo ""
        echo -e "Branch: ${BLUE}$current_branch${NC}"
        echo -e "Último commit: ${YELLOW}$commit_message${NC}"
        echo ""
    else
        echo -e "${RED}❌ Erro ao fazer push${NC}"
        echo -e "${YELLOW}   Tente: git push -u origin $current_branch${NC}"
        exit 1
    fi
else
    echo ""
    echo -e "${GREEN}✅ Commit concluído!${NC}"
    echo -e "${YELLOW}   Faça push manualmente quando estiver pronto:${NC}"
    echo -e "   ${BLUE}git push origin $(git branch --show-current)${NC}"
    echo ""
fi
