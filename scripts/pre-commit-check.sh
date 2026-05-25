#!/bin/bash
# ============================================================================
# Cloud4Health - Pre-commit Verification Script
# ============================================================================

set -e

echo "=========================================="
echo "🔍 Verificações Pré-Commit"
echo "=========================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ERRORS=0

# ============================================================================
# 1. Verificar Terraform Format
# ============================================================================
echo -e "${YELLOW}📝 Verificando formatação Terraform...${NC}"
if terraform fmt -check -recursive > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Formatação OK${NC}"
else
    echo -e "${RED}❌ Arquivos Terraform não formatados!${NC}"
    echo "   Execute: terraform fmt -recursive"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# ============================================================================
# 2. Verificar Terraform Validation
# ============================================================================
echo -e "${YELLOW}🔍 Validando configuração Terraform...${NC}"
if terraform validate > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Validação OK${NC}"
else
    echo -e "${RED}❌ Erros de validação encontrados!${NC}"
    terraform validate
    ERRORS=$((ERRORS + 1))
fi
echo ""

# ============================================================================
# 3. Verificar Arquivos Sensíveis
# ============================================================================
echo -e "${YELLOW}🔒 Verificando arquivos sensíveis...${NC}"

SENSITIVE_FILES=(
    "*.tfstate"
    "*.tfstate.backup"
    "*.pem"
    "*.key"
    ".env"
    "secrets.tfvars"
)

FOUND_SENSITIVE=0
for pattern in "${SENSITIVE_FILES[@]}"; do
    if git ls-files | grep -q "$pattern"; then
        echo -e "${RED}❌ ATENÇÃO: Arquivo sensível encontrado: $pattern${NC}"
        FOUND_SENSITIVE=1
        ERRORS=$((ERRORS + 1))
    fi
done

if [ $FOUND_SENSITIVE -eq 0 ]; then
    echo -e "${GREEN}✅ Nenhum arquivo sensível detectado${NC}"
fi
echo ""

# ============================================================================
# 4. Verificar .gitignore
# ============================================================================
echo -e "${YELLOW}📄 Verificando .gitignore...${NC}"
if [ -f ".gitignore" ]; then
    REQUIRED_PATTERNS=(
        "*.tfstate"
        "*.tfstate.backup"
        ".terraform/"
        "*.pem"
        "*.key"
    )
    
    MISSING=0
    for pattern in "${REQUIRED_PATTERNS[@]}"; do
        if ! grep -q "$pattern" .gitignore; then
            echo -e "${RED}❌ Padrão faltando no .gitignore: $pattern${NC}"
            MISSING=1
        fi
    done
    
    if [ $MISSING -eq 0 ]; then
        echo -e "${GREEN}✅ .gitignore configurado corretamente${NC}"
    else
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${RED}❌ .gitignore não encontrado!${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# ============================================================================
# 5. Verificar Documentação
# ============================================================================
echo -e "${YELLOW}📚 Verificando documentação...${NC}"
DOC_FILES=("README.md" "CHECKLIST.md")

for doc in "${DOC_FILES[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✅ $doc presente${NC}"
    else
        echo -e "${YELLOW}⚠️  $doc não encontrado${NC}"
    fi
done
echo ""

# ============================================================================
# Resultado Final
# ============================================================================
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Todas as verificações passaram!${NC}"
    echo -e "${GREEN}   Pronto para commit.${NC}"
    exit 0
else
    echo -e "${RED}❌ $ERRORS erro(s) encontrado(s)!${NC}"
    echo -e "${RED}   Corrija os problemas antes de commitar.${NC}"
    exit 1
fi
