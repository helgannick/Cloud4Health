# 🚀 Guia de Execução - WSL Ubuntu

## ⚡ Quick Start

### 1. Copiar projeto para o WSL

```bash
# No Windows, copie a pasta para o WSL
# Ou clone do repositório Git quando estiver pronto

# Navegue até o diretório
cd ~/cloud4health-terraform
```

### 2. Verificar AWS CLI

```bash
# Verificar se AWS CLI está configurado
aws sts get-caller-identity

# Se não estiver configurado:
aws configure
# Informações necessárias:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json
```

### 3. Executar script de inicialização

```bash
# Tornar script executável (se necessário)
chmod +x scripts/init.sh

# Executar inicialização
./scripts/init.sh
```

### 4. Revisar variáveis (opcional)

```bash
# Editar variáveis se necessário
nano terraform.tfvars

# Ou usar vim
vim terraform.tfvars
```

### 5. Planejar deployment

```bash
terraform plan

# Ou salvar o plano para review
terraform plan -out=tfplan
```

### 6. Aplicar infraestrutura

```bash
# Aplicar mudanças (vai pedir confirmação)
terraform apply

# Ou aplicar sem confirmação (cuidado!)
terraform apply -auto-approve

# Ou aplicar o plano salvo
terraform apply tfplan
```

### 7. Ver resultados

```bash
# Ver todos os outputs
terraform output

# Ver output específico
terraform output vpc_id
terraform output nat_gateway_ips
terraform output network_summary

# Ver em formato JSON
terraform output -json > outputs.json
```

## 🎯 Comandos Essenciais

### Visualizar Estado Atual

```bash
# Ver estado completo
terraform show

# Listar todos os recursos
terraform state list

# Ver detalhes de um recurso específico
terraform state show module.networking.aws_vpc.main

# Ver gráfico de dependências
terraform graph | dot -Tpng > graph.png
```

### Modificar Infraestrutura

```bash
# Aplicar apenas um módulo específico
terraform apply -target=module.networking

# Destruir apenas um recurso
terraform destroy -target=module.networking.aws_nat_gateway.main[0]

# Reimportar recurso existente
terraform import module.networking.aws_vpc.main vpc-xxxxxxxx
```

### Manutenção

```bash
# Formatar código
terraform fmt -recursive

# Validar sintaxe
terraform validate

# Verificar upgrade de providers
terraform init -upgrade

# Ver versões
terraform version
```

### Limpeza

```bash
# Destruir TODA a infraestrutura (cuidado!)
terraform destroy

# Destruir sem confirmação (MUITO cuidado!)
terraform destroy -auto-approve

# Ver o que seria destruído sem executar
terraform plan -destroy
```

## 📊 Monitoramento de Custos

### Estimativa antes de aplicar

```bash
# Usar Infracost (se instalado)
infracost breakdown --path .

# Manualmente via AWS Console:
# 1. Acesse AWS Cost Explorer
# 2. Filtre por tags: Project=Cloud4Health
```

### Durante execução

```bash
# Via AWS CLI
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics "BlendedCost" "UnblendedCost" \
  --filter file://cost-filter.json
```

## 🔍 Troubleshooting

### Erro: "No valid credential sources found"

```bash
# Reconfigurar AWS CLI
aws configure

# Ou exportar variáveis de ambiente
export AWS_ACCESS_KEY_ID="sua-access-key"
export AWS_SECRET_ACCESS_KEY="sua-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Erro: "Error locking state"

```bash
# Forçar desbloqueio (use com cuidado)
terraform force-unlock LOCK_ID
```

### Erro: "Resource already exists"

```bash
# Importar recurso existente
terraform import module.networking.aws_vpc.main vpc-xxxxxxxx

# Ou remover do state
terraform state rm module.networking.aws_vpc.main
```

### Ver logs detalhados

```bash
# Debug completo
TF_LOG=DEBUG terraform apply

# Apenas erros
TF_LOG=ERROR terraform apply

# Salvar logs em arquivo
TF_LOG=DEBUG terraform apply 2>&1 | tee terraform.log
```

## 🔒 Boas Práticas de Segurança

### 1. Nunca commitar credenciais

```bash
# Adicionar ao .gitignore
echo "*.tfvars" >> .gitignore
echo "terraform.tfstate*" >> .gitignore
```

### 2. Usar variáveis de ambiente

```bash
# Criar arquivo .env (não commitar!)
cat > .env << EOF
export TF_VAR_aws_access_key="AKIA..."
export TF_VAR_aws_secret_key="..."
EOF

# Carregar variáveis
source .env
```

### 3. Backend remoto (S3)

```bash
# Criar bucket para state (fazer manualmente primeiro)
aws s3 mb s3://cloud4health-terraform-state --region us-east-1

# Habilitar versionamento
aws s3api put-bucket-versioning \
  --bucket cloud4health-terraform-state \
  --versioning-configuration Status=Enabled

# Habilitar encryption
aws s3api put-bucket-encryption \
  --bucket cloud4health-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Criar DynamoDB table para locking
aws dynamodb create-table \
  --table-name cloud4health-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

## 📦 Workspace (Múltiplos Ambientes)

```bash
# Criar workspace de produção
terraform workspace new prod

# Listar workspaces
terraform workspace list

# Mudar para workspace
terraform workspace select dev

# Ver workspace atual
terraform workspace show
```

## 🎓 Dicas para o Projeto Acadêmico

### Capturar evidências

```bash
# Salvar outputs
terraform output -json > evidence/outputs.json

# Salvar plano
terraform plan -out=evidence/tfplan.binary
terraform show -json evidence/tfplan.binary > evidence/plan.json

# Ver grafo visual
terraform graph > evidence/graph.dot
```

### Gerar documentação

```bash
# Usar terraform-docs (se instalado)
terraform-docs markdown table . > TERRAFORM_DOCS.md

# Listar recursos criados
terraform state list > evidence/resources.txt
```

## ⚠️ IMPORTANTE - Custos

### Recursos que GERAM CUSTO:

- ❌ **NAT Gateway:** ~$32/mês (0.045/hora)
- ❌ **VPC Flow Logs:** ~$0.50/mês
- ✅ **VPC, Subnets, IGW:** GRÁTIS

### Economizar durante desenvolvimento:

```bash
# Destruir NAT Gateway quando não usar
terraform destroy -target=module.networking.aws_nat_gateway.main

# Ou desabilitar completamente
# Editar terraform.tfvars:
# enable_nat_gateway = false

terraform apply
```

## 🆘 Suporte

### Documentação Oficial
- Terraform: https://www.terraform.io/docs
- AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

### Comunidade
- Terraform Community: https://discuss.hashicorp.com/
- AWS re:Post: https://repost.aws/

---

**📅 Última atualização:** Fase 1  
**🎓 Projeto Acadêmico** - Marcos Barbosa Carvalho dos Santos
