# Git Flow – Catálogo DocumentDB

Este repositório segue o [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/): branches principais `main` e `develop`, e branches de apoio `feature/*`, `release/*` e `hotfix/*`.

## Branches principais

| Branch | Uso |
|--------|-----|
| **main** | Código em “produção”. Deploy (CD) é disparado ao alterar `terraform/**` ou manualmente. Deve estar estável. |
| **develop** | Integração. Todo desenvolvimento é mergeado aqui primeiro. CI roda a cada push. |

## Branches de apoio

| Padrão | Uso | Origem | Destino do merge |
|--------|-----|--------|-------------------|
| **feature/\*** | Nova funcionalidade ou mudança de infra | `develop` | `develop` (via PR) |
| **release/\*** | Preparação de release (versionamento, ajustes finos) | `develop` | `main` e `develop` |
| **hotfix/\*** | Correção urgente em produção | `main` | `main` e `develop` |

## Fluxo resumido

1. **Iniciar feature**  
   A partir de `develop`:  
   `git checkout develop && git pull && git checkout -b feature/nome-da-feature`

2. **Commitar e enviar**  
   Trabalhe na feature, faça commit e push da branch.

3. **Abrir PR para `develop`**  
   Abra Pull Request `feature/nome-da-feature` → `develop`. O CI (fmt + validate) deve passar.

4. **Merge em `develop`**  
   Após review, faça merge (squash ou merge commit, conforme padrão do repo).

5. **Release**  
   Quando for publicar uma versão:  
   - Crie `release/x.y.z` a partir de `develop`.  
   - Ajustes só de release nessa branch.  
   - PR de `release/x.y.z` → `main`.  
   - Após merge em `main`, merge de volta `release/x.y.z` em `develop` (e opcionalmente tag em `main`).

6. **Hotfix**  
   Para correção urgente em produção:  
   - Crie `hotfix/descricao` a partir de `main`.  
   - Corrija, faça PR para `main`.  
   - Após merge em `main`, merge de volta em `develop`.

7. **Deploy**  
   - **Automático**: merge em `main` que altere `terraform/` ou o workflow CD.  
   - **Manual**: GitHub Actions → workflow “CD” → Run workflow (escolha o ambiente). Em conta sandbox, garanta que os secrets da AWS e do DocumentDB estão atualizados antes.

## Configuração inicial (uma vez no repositório)

Se o repositório ainda não tiver `develop`:

```bash
git checkout -b develop
git push -u origin develop
```

Depois, proteja `main` (e opcionalmente `develop`) em **Settings → Branches** (branch protection rules), exigindo PR e status do CI para merge em `main`.
