# Entrevista de bootstrap — 10 perguntas

Use estas perguntas exatamente como escritas. Uma por mensagem. Registre cada resposta antes da próxima.

## 1. Domínio
**Em uma frase, o que esse serviço/produto faz para o cliente final?**
*Captura intenção de negócio em linguagem simples, evita jargão técnico.*

## 2. Fluxos críticos
**Quais são os 3-5 fluxos que, se quebrarem, geram incidente Sev1?**
*Identifica onde o código mais "importa". Vai virar prioridade de runbook e observability.*

## 3. Stakeholders
**Quem usa o que vocês entregam? (clientes finais, B2B, times internos, reguladores)**
*Mapeia audiência das mudanças e quem precisa ser comunicado em incidentes.*

## 4. Dores recentes
**Que tipo de bug/incidente mais consumiu vocês nos últimos 90 dias?**
*Revela padrões de fragilidade — vão informar threat-model e checklist de revisão.*

## 5. Prioridades trimestrais
**Quais são os 2-3 objetivos do squad para o próximo trimestre?**
*Define o que é "alto valor" para classificação de tarefas.*

## 6. Estilo de revisão
**Vocês fazem PR review síncrono, assíncrono? Há rituais (pair, mob, ensemble)?**
*Define como `mb-review` deve se integrar ao fluxo do squad.*

## 7. Maturidade de testes
**Cobertura aproximada? E2E existe? Testes em produção (canary, shadow)?**
*Ajusta rigor de hooks de qualidade e expectativas de verification.*

## 8. Gargalos atuais
**Onde o time gasta tempo demais? (debug, ambientes, deploy, contexto, comunicação)**
*Identifica oportunidades para skills custom e automação.*

## 9. Glossário
**Liste 5-10 jargões/abreviações/conceitos que um dev novo precisa entender no primeiro dia.**
*Vai virar `.mb/glossary.md` — o agente usa para entender o contexto certo.*

## 10. Relação com regulação
**Esse serviço toca algo regulado? (KYC, AML, custódia, ordens, dados fiscais, PII de cliente)**
*Aciona regras adicionais de compliance e threat-model obrigatório.*

---

## Como conduzir

- **Tom:** colaborativo, não inquisitorial. O squad está te ensinando.
- **Profundidade:** 1-2 follow-ups por pergunta se a resposta inicial for genérica.
- **Tempo:** ~2-3 min por pergunta. Total ~25-30 min.
- **Registro:** anote literalmente, sem reformular. Reformulação para `.mb/CLAUDE.md` é depois.
