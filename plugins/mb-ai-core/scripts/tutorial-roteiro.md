# Tutorial guiado MBit · Roteiro

Tempo: 45-60 min. Pré-requisito: sandbox criado via `/mb-tutorial init`.

## Cenário

Você é dev no squad **listings** da exchange MBExchangeMini. Sua próxima tarefa: **adicionar o par BTC/USDC** à listagem.

## Passo 1 (5 min) — Bootstrap do squad

```
/mb-bootstrap
```

Quando o agente fizer perguntas, responda como se você fosse o squad listings:
1. Domínio: "Gerenciar pares de trading da exchange MBExchangeMini."
2. Fluxos críticos: "(1) listar pares ativos, (2) adicionar par novo, (3) remover par."
3. Stakeholders: "Devs do core de matching, suporte ao cliente, compliance."
4. Dores recentes: "Deploy de novo par já causou 1h de incidente em março/2026."
5. Prioridades trim: "Ampliar pares de cripto para fiat estrangeiras."
6. Estilo de revisão: "Async, 1 reviewer obrigatório."
7. Maturidade testes: "Cobertura ~60%, sem E2E."
8. Gargalos: "Tempo gasto validando se par já existe em outros sistemas."
9. Glossário: "pair=par de trading | base=moeda comprada | quote=moeda paga | matching engine=motor de ordens."
10. Regulação: "Sim — KYC tier varia por par."

Verifique que `.mb/CLAUDE.md` foi gerado.

## Passo 2 (15 min) — Spec da feature

```
/mb-spec adicionar-par-btc-usdc
```

Conduza pelo ciclo. Em cada fase, **aprove** com `/mb-approve <FASE>`.

## Passo 3 (10 min) — Hotfix simulado

```
/mb-hotfix
```

Simule: "Par BTC/BRL parou de aparecer na listagem após deploy de ontem".

## Passo 4 (10 min) — Threat model

```
/mb-threat-model
```

Para uma feature fictícia "permitir saque automático".

## Passo 5 (10 min) — Retro final

```
/mb-spec-retro
```

Reflita sobre o tutorial: o que você aprendeu? O que faria diferente?

## Conclusão

Ao fim, gere certificado:

```bash
echo "# MBit Tutorial concluído" > tutorial-completed.md
echo "Dev: $(git config user.email)" >> tutorial-completed.md
echo "Data: $(date -u +%F)" >> tutorial-completed.md
```

Compartilhe com seu Tech Lead e AI Champion.
