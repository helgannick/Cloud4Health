#!/bin/bash
# ============================================================================
# Cloud4Health - Script de Inicialização
# ============================================================================

set -e

echo "=========================================="
echo "Cloud4Health - Inicialização Terraform"
echo "=========================================="
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se está no diretório correto
if [ ! -f "main.tf" ]; then
    echo -e "${RED}❌ Erro: Execute este script no diretório raiz do projeto${NC}"
    exit 1
fi

# Verificar AWS CLI
echo -e "${YELLOW}🔍 Verificando AWS CLI...${NC}"
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI não encontrado. Instale: https://aws.amazon.com/cli/${NC}"
    exit 1
fi

# Verificar credenciais AWS
echo -e "${YELLOW}🔍 Verificando credenciais AWS...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ Credenciais AWS não configuradas. Execute: aws configure${NC}"
    exit 1
fi

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
echo -e "${GREEN}✅ Conta AWS: ${AWS_ACCOUNT}${NC}"
echo -e "${GREEN}✅ Região: ${AWS_REGION}${NC}"
echo ""

# Verificar Terraform
echo -e "${YELLOW}🔍 Verificando Terraform...${NC}"
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform não encontrado. Instale: https://www.terraform.io/downloads${NC}"
    exit 1
fi

TERRAFORM_VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
echo -e "${GREEN}✅ Terraform versão: ${TERRAFORM_VERSION}${NC}"
echo ""

# Inicializar Terraform
echo -e "${YELLOW}📦 Inicializando Terraform...${NC}"
terraform init

echo ""
echo -e "${YELLOW}🔍 Validando configuração...${NC}"
terraform validate

echo ""
echo -e "${YELLOW}📝 Formatando código...${NC}"
terraform fmt -recursive

echo ""
echo -e "${GREEN}=========================================="
echo "✅ Inicialização concluída com sucesso!"
echo "==========================================${NC}"
echo ""
echo "Próximos passos:"
echo "  1. Revisar variáveis: vim terraform.tfvars"
echo "  2. Planejar deployment: terraform plan"
echo "  3. Aplicar infraestrutura: terraform apply"
echo "  4. Ver outputs: terraform output"
echo ""
echo "⚠️  IMPORTANTE: Custos estimados da Fase 1: ~$33/mês"
echo "    Use 'terraform destroy' quando não estiver usando!"
echo ""
