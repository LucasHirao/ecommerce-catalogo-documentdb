# Git Flow – Catálogo DocumentDB

Este repositório usa um fluxo com branch **`sandbox`** para deploy: CI em qualquer branch e CD ao fazer merge em `sandbox`.

## Branches principais

| Branch | Uso |
|--------|-----|
| **main** | Código em “produção”. |
| **sandbox** | Branch de deploy para ambiente sandbox. **Merge aqui dispara o CD** (terraform apply). Deve existir no repo. |
| **develop** | Integração. |

## Fluxo com sandbox

1. **Trabalhe em uma branch** (ex.: `feature/nome` a partir de `develop` ou `sandbox`).  
   `git checkout -b feature/nome`

2. **Commit e push**  
   A cada push, o **CI** roda (terraform fmt, init, validate) em qualquer branch.

3. **PR para sandbox**  
   Ao final do CI (após push), o workflow **abre automaticamente um PR** da sua branch para `sandbox` (se ainda não existir). Você também pode abrir o PR manualmente.

4. **Merge em `sandbox`**  
   Aprove o PR e faça merge em `sandbox`. Isso **dispara o CD** (deploy na AWS em ambiente sandbox).

5. **Deploy manual**  
   Quando precisar: GitHub Actions → workflow “CD” → Run workflow (escolha o ambiente). Em conta sandbox, garanta que os secrets da AWS e do DocumentDB estão atualizados antes.

## Configuração inicial (uma vez no repositório)

Crie a branch **`sandbox`** (necessária para o CD e para os PRs automáticos do CI):

```bash
git checkout -b sandbox
git push -u origin sandbox
```

Opcional: crie `develop` se ainda não existir e proteja `main` e `sandbox` em **Settings → Branches** (branch protection rules), exigindo PR e status do CI para merge.
