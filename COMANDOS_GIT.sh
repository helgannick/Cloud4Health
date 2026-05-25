# ============================================================================
# COMANDOS PRONTOS - COPIE E COLE NO SEU TERMINAL WSL
# ============================================================================

# ============================================================================
# OPÇÃO 1: Usando Script Automático (RECOMENDADO)
# ============================================================================

cd ~/cloud4health-terraform

# Executar script que faz tudo automaticamente
./scripts/quick-commit.sh

# O script vai:
# 1. Verificar formatação e validação
# 2. Mostrar arquivos modificados
# 3. Pedir confirmação
# 4. Solicitar mensagem de commit
# 5. Fazer commit
# 6. Perguntar se quer fazer push


# ============================================================================
# OPÇÃO 2: Passo a Passo Manual
# ============================================================================

cd ~/cloud4health-terraform

# 1. Verificar status
git status

# 2. Executar verificações (IMPORTANTE!)
./scripts/pre-commit-check.sh

# 3. Formatar código
terraform fmt -recursive

# 4. Validar
terraform validate

# 5. Ver arquivos modificados
git status

# 6. Adicionar TODOS os arquivos
git add .

# 7. Ver o que será commitado
git status

# 8. Fazer commit (copie a mensagem abaixo)
git commit -m "chore: initial commit - fase 1 networking complete

Implementação completa da Fase 1 - Networking

Features:
- Módulo de networking com Terraform
- VPC multi-AZ (us-east-1a, us-east-1b)
- 6 subnets (2 public, 2 private, 2 database)
- Internet Gateway e NAT Gateway
- Route tables configuradas
- VPC Flow Logs para auditoria
- DB Subnet Group para RDS

Documentação:
- README com quick start
- Arquitetura de rede detalhada
- Guia de execução no WSL
- Checklist completo das 7 fases
- Guia de contribuição

Conformidade:
- AWS Well-Architected Framework
- Segurança em camadas
- Multi-AZ para alta disponibilidade
- IaC com Terraform

Projeto Integrado - Anhanguera
Aluno: Marcos Barbosa Carvalho dos Santos
Matrícula: 2025154184"

# 9. Verificar se commit funcionou
git log --oneline -1

# 10. Ver remote configurado
git remote -v

# 11. Push para GitHub
git push origin main

# OU se for a primeira vez:
git push -u origin main


# ============================================================================
# VERIFICAÇÕES APÓS PUSH
# ============================================================================

# Ver último commit
git log -1

# Ver arquivos no repositório
git ls-files

# Ver status limpo
git status


# ============================================================================
# COMANDOS ÚTEIS EXTRAS
# ============================================================================

# Ver histórico de commits
git log --oneline --graph --all

# Ver diferenças do último commit
git show HEAD

# Ver estatísticas
git diff --stat

# Criar tag para a Fase 1
git tag -a v1.0.0-fase1 -m "Fase 1: Networking completa"
git push origin --tags


# ============================================================================
# PRÓXIMOS PASSOS (Para Fase 2)
# ============================================================================

# Criar branch para Fase 2
git checkout -b feature/fase2-security

# Após desenvolver a Fase 2
git add .
git commit -m "feat(security): add security groups and IAM roles"
git push -u origin feature/fase2-security

# Criar Pull Request no GitHub e fazer merge


# ============================================================================
# TROUBLESHOOTING
# ============================================================================

# Se der erro "permission denied"
chmod +x scripts/*.sh

# Se der erro de remote
git remote -v
git remote add origin git@github.com:SEU_USUARIO/REPO.git

# Se der erro de autenticação SSH
ssh -T git@github.com

# Ou usar HTTPS
git remote set-url origin https://github.com/SEU_USUARIO/REPO.git

# Se precisar refazer o commit
git reset --soft HEAD~1
# Edite a mensagem e faça commit novamente

# Ver o que mudou
git diff HEAD~1


# ============================================================================
# COMANDOS DE EMERGÊNCIA
# ============================================================================

# Desfazer TUDO (cuidado!)
git reset --hard HEAD

# Remover arquivo do git mas manter localmente
git rm --cached arquivo.tf

# Forçar push (MUITO CUIDADO!)
git push --force origin main

# Reverter último commit mantendo mudanças
git revert HEAD


# ============================================================================
# FIM
# ============================================================================

echo "✅ Comandos prontos!"
echo "📖 Veja mais em: docs/GIT_GUIDE.md"
