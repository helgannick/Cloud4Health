# 🔧 Guia Git - Cloud4Health

## 🚀 Comandos para o Primeiro Commit

### Passo 1: Verificar Status
```bash
cd ~/cloud4health-terraform

# Ver status dos arquivos
git status

# Ver branch atual
git branch
```

### Passo 2: Verificação Pré-Commit (RECOMENDADO)
```bash
# Executar verificações automáticas
./scripts/pre-commit-check.sh

# Ou manualmente:
terraform fmt -recursive
terraform validate
```

### Passo 3: Adicionar Arquivos
```bash
# Adicionar TODOS os arquivos
git add .

# OU adicionar seletivamente (mais seguro)
git add main.tf variables.tf outputs.tf terraform.tfvars
git add modules/
git add docs/
git add scripts/
git add README.md CHECKLIST.md CONTRIBUTING.md LICENSE
git add .gitignore .gitattributes
```

### Passo 4: Ver o que será commitado
```bash
# Ver arquivos staged
git status

# Ver diff dos arquivos
git diff --cached
```

### Passo 5: Commit
```bash
# Commit com mensagem descritiva
git commit -m "chore: initial commit - fase 1 networking complete

- Implementa módulo de networking com Terraform
- VPC multi-AZ com subnets públicas, privadas e database
- NAT Gateway e Internet Gateway configurados
- VPC Flow Logs para auditoria
- Documentação completa da arquitetura
- Scripts de inicialização e verificação
- Conformidade com AWS Well-Architected Framework"
```

### Passo 6: Push para GitHub
```bash
# Ver remotes configurados
git remote -v

# Push para a branch main
git push origin main

# Ou se for a primeira vez
git push -u origin main
```

---

## 🌿 Trabalhando com Branches

### Criar Branch de Desenvolvimento
```bash
# Criar e mudar para branch develop
git checkout -b develop

# Push da branch
git push -u origin develop

# Configurar develop como branch padrão (no GitHub)
# Settings → Branches → Default branch → develop
```

### Workflow de Feature
```bash
# Criar branch de feature
git checkout -b feature/fase2-security

# Fazer mudanças...
git add .
git commit -m "feat(security): add security groups module"

# Push da feature
git push -u origin feature/fase2-security

# Criar Pull Request no GitHub
# Após aprovação, merge para develop
```

---

## 📝 Convenções de Commit

### Formato
```
<tipo>(<escopo>): <descrição curta>

[descrição detalhada opcional]

[rodapé opcional]
```

### Exemplos por Fase

**Fase 1 - Networking:**
```bash
git commit -m "feat(networking): implement VPC with multi-az architecture"
git commit -m "docs(networking): add network architecture diagrams"
git commit -m "chore(networking): configure VPC flow logs"
```

**Fase 2 - Security:**
```bash
git commit -m "feat(security): add security groups for ALB, ECS, and RDS"
git commit -m "feat(security): implement IAM roles for ECS tasks"
git commit -m "fix(security): correct RDS security group rules"
```

**Fase 3 - Compute:**
```bash
git commit -m "feat(compute): add ECS cluster with Fargate"
git commit -m "feat(compute): configure Application Load Balancer"
git commit -m "feat(compute): implement auto scaling policies"
```

---

## 🔍 Comandos Úteis

### Verificar Histórico
```bash
# Ver últimos commits
git log --oneline --graph --all

# Ver mudanças de um commit específico
git show <commit-hash>

# Ver histórico de um arquivo
git log --follow main.tf
```

### Desfazer Mudanças
```bash
# Desfazer mudanças não staged
git checkout -- arquivo.tf

# Remover arquivo do staging
git reset HEAD arquivo.tf

# Desfazer último commit (mantém mudanças)
git reset --soft HEAD~1

# Desfazer último commit (descarta mudanças)
git reset --hard HEAD~1
```

### Stash (Salvar temporariamente)
```bash
# Salvar mudanças temporariamente
git stash

# Ver stashes
git stash list

# Recuperar último stash
git stash pop

# Aplicar stash específico
git stash apply stash@{0}
```

### Tags (Versões)
```bash
# Criar tag
git tag -a v1.0.0 -m "Fase 1 - Networking completa"

# Push de tags
git push origin --tags

# Ver tags
git tag -l

# Checkout de tag
git checkout v1.0.0
```

---

## 🔒 Segurança - O que NÃO commitar

### Arquivos Sensíveis (já no .gitignore)
```
❌ *.tfstate
❌ *.tfstate.backup
❌ *.pem
❌ *.key
❌ .env
❌ secrets.tfvars
❌ terraform.tfvars (se contiver credenciais)
```

### Verificar antes do Push
```bash
# Ver o que vai ser enviado
git diff origin/main..HEAD

# Ver arquivos que serão enviados
git diff --name-only origin/main..HEAD

# Verificar por strings sensíveis
git grep -i "aws_access_key"
git grep -i "password"
git grep -i "secret"
```

### Remover Arquivo Commitado por Engano
```bash
# Remover do Git mas manter localmente
git rm --cached arquivo-sensivel.txt

# Adicionar ao .gitignore
echo "arquivo-sensivel.txt" >> .gitignore

# Commit
git commit -m "chore: remove sensitive file from tracking"

# Push com force (cuidado!)
git push origin main
```

---

## 🚨 Troubleshooting

### Erro: "remote: Permission denied"
```bash
# Verificar SSH keys
ssh -T git@github.com

# Ou usar HTTPS com token
git remote set-url origin https://github.com/username/repo.git
```

### Erro: "Updates were rejected"
```bash
# Pull antes de push
git pull origin main --rebase

# Ou merge
git pull origin main
```

### Erro: "fatal: not a git repository"
```bash
# Inicializar repositório
git init

# Adicionar remote
git remote add origin git@github.com:username/repo.git
```

### Arquivos grandes
```bash
# Ver tamanho dos arquivos
git ls-files -s | awk '{print $4, $2}' | sort -k2 -n -r | head

# Usar Git LFS para arquivos grandes
git lfs install
git lfs track "*.psd"
git add .gitattributes
```

---

## 📊 Estatísticas

```bash
# Ver contribuições
git shortlog -sn

# Ver quantidade de linhas por autor
git log --author="Marcos" --pretty=tformat: --numstat | \
  awk '{ add += $1; subs += $2; loc += $1 - $2 } END \
  { printf "added: %s removed: %s total: %s\n", add, subs, loc }'

# Ver arquivos mais modificados
git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10
```

---

## 🎯 Checklist Antes do Push

- [ ] `./scripts/pre-commit-check.sh` passou
- [ ] `terraform fmt -recursive` executado
- [ ] `terraform validate` sem erros
- [ ] Nenhum arquivo sensível no commit
- [ ] .gitignore atualizado
- [ ] Mensagem de commit descritiva
- [ ] README atualizado (se necessário)
- [ ] Documentação atualizada

---

## 📚 Recursos

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)

---

**🎓 Projeto Acadêmico** - Cloud4Health  
**👤 Autor:** Marcos Barbosa Carvalho dos Santos  
**📅 Fase 1:** Networking Completa
