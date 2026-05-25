# 🤝 Guia de Contribuição

## 📋 Convenções de Commit

Este projeto segue o padrão [Conventional Commits](https://www.conventionalcommits.org/).

### Formato
```
<tipo>(<escopo>): <descrição>

[corpo opcional]

[rodapé opcional]
```

### Tipos de Commit

- **feat**: Nova funcionalidade
- **fix**: Correção de bug
- **docs**: Apenas documentação
- **style**: Mudanças de formatação (não afeta código)
- **refactor**: Refatoração de código
- **test**: Adição/modificação de testes
- **chore**: Tarefas de manutenção
- **ci**: Mudanças em CI/CD

### Exemplos

```bash
# Commit inicial
git commit -m "chore: initial commit - fase 1 networking"

# Nova feature
git commit -m "feat(networking): add VPC with multi-az subnets"

# Documentação
git commit -m "docs: add network architecture documentation"

# Correção
git commit -m "fix(networking): correct NAT gateway configuration"

# Múltiplas mudanças
git commit -m "feat(networking): implement VPC flow logs

- Add CloudWatch log group
- Configure IAM role for flow logs
- Enable flow logs on VPC
- Add retention policy"
```

## 🌿 Branches

- `main` - Código estável e testado
- `develop` - Desenvolvimento ativo
- `feature/*` - Novas funcionalidades
- `fix/*` - Correções
- `docs/*` - Documentação

## 📝 Pull Request

1. Criar branch a partir de `develop`
2. Fazer commits seguindo convenções
3. Testar localmente (`terraform plan`)
4. Criar PR para `develop`
5. Aguardar review

## ✅ Checklist antes do Commit

- [ ] `terraform fmt -recursive` executado
- [ ] `terraform validate` passou
- [ ] Documentação atualizada
- [ ] .gitignore configurado corretamente
- [ ] Sem credenciais sensíveis
- [ ] README atualizado (se necessário)

## 🔒 Segurança

**NUNCA** commite:
- Credenciais AWS
- Access Keys / Secret Keys
- Arquivos `.tfstate`
- Arquivos `.tfvars` com dados sensíveis
- Certificados SSL/TLS privados

Use `.gitignore` para prevenir commits acidentais.
