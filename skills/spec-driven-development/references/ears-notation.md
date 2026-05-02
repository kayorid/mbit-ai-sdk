# EARS Notation — Easy Approach to Requirements Syntax

EARS resolve um problema real: requisitos em prosa solta são ambíguos demais para uma IA implementar com precisão e difíceis demais para um humano validar. EARS impõe estrutura mínima sem virar "linguagem formal" pesada.

A estrutura base de qualquer requisito é:

> *Enquanto* `<pré-condições>`, *quando* `<gatilho>`, o `<sistema>` *deve* `<resposta>`.

Pré-condições e gatilho podem estar ausentes; o sistema e a resposta são sempre obrigatórios. A partir dessa base, surgem cinco padrões.

## Os cinco padrões

### 1. Ubíquo (Ubiquitous) — comportamento sempre verdadeiro

**Forma**: `O <sistema> deve <resposta>.`

Sem condições, sem gatilho. Vale a todo momento.

**Exemplos:**
- O sistema de autenticação deve emitir tokens JWT com expiração de 24 horas.
- A API deve retornar respostas em JSON com Content-Type aplicado.
- Toda mutation no backend deve registrar entrada de audit log.

### 2. Direcionado por estado (State-driven) — `Enquanto`

**Forma**: `Enquanto <estado>, o <sistema> deve <resposta>.`

A resposta é contínua enquanto o estado é verdadeiro.

**Exemplos:**
- Enquanto o usuário não tiver completado o onboarding, o sistema deve exibir o banner de progresso no topo.
- Enquanto o tenant estiver no plano Free, a API deve limitar a 100 requisições por minuto.
- Enquanto há jobs em fila, o worker deve manter conexão ativa com o Redis.

### 3. Direcionado por evento (Event-driven) — `Quando`

**Forma**: `Quando <gatilho>, o <sistema> deve <resposta>.`

A resposta é disparada uma vez por ocorrência do gatilho.

**Exemplos:**
- Quando o usuário completa um bloco de jornada, o sistema deve recalcular o progresso percentual da jornada.
- Quando uma mensagem de boas-vindas é publicada, o sistema deve enviar notificação push para o destinatário.
- Quando um upload é finalizado, o sistema deve emitir evento `upload.completed` no barramento.

### 4. Feature opcional (Optional feature) — `Onde`

**Forma**: `Onde <feature/condição>, o <sistema> deve <resposta>.`

Para comportamentos que existem apenas em determinadas configurações ou planos.

**Exemplos:**
- Onde o tenant está no plano Enterprise, a API pública deve estar disponível.
- Onde o feature flag `gamification` está ativo, o dashboard deve exibir leaderboard.
- Onde o tenant tem white-label habilitado, o sistema deve renderizar o logotipo do cliente em vez do nosso.

### 5. Comportamento indesejado (Unwanted behaviour) — `Se ... então`

**Forma**: `Se <gatilho indesejado>, então o <sistema> deve <resposta>.`

Para erros, falhas, casos de exceção. Cobre o "o que acontece quando dá errado" — frequentemente esquecido.

**Exemplos:**
- Se um usuário não autenticado tenta acessar um endpoint privado, então o sistema deve responder 401 e não revelar a existência do recurso.
- Se a fila de processamento ultrapassa 10 mil itens, então o sistema deve emitir alerta e ativar circuit breaker.
- Se um upload excede 100 MB, então o sistema deve recusar com 413 e mensagem indicando o limite.

## Combinando padrões

Os padrões podem ser combinados quando o requisito tem múltiplas dimensões:

- **Estado + evento**: Enquanto o usuário estiver autenticado, quando ele clicar "Sair", o sistema deve invalidar a sessão e redirecionar para a tela de login.
- **Evento + feature**: Onde o plano é Pro, quando um certificado é gerado, o sistema deve aplicar branding customizado do tenant.
- **Estado + indesejado**: Enquanto há sincronização em andamento, se o usuário fechar a aba, então o sistema deve persistir o progresso e retomar na próxima sessão.

Use combinações com parcimônia. Se um requisito está virando frase longa demais (3+ cláusulas), provavelmente são **dois requisitos** disfarçados — separe.

## Boas práticas

### Sempre observável
A resposta deve ser algo que se possa **medir, ver, ou registrar**. Não:
- ❌ "O sistema deve ser performático."
- ✅ "O sistema deve responder ao endpoint X em menos de 200ms para o p95 das requisições autenticadas."

### Sempre testável
Se você não consegue imaginar o teste que provaria o requisito, ele está mal escrito.

### Sem stack
EARS é sobre comportamento, não implementação. Não escreva "o sistema deve usar Redis para cache" — isso é decisão técnica, vai em `design.md`. Escreva "o sistema deve servir resposta cacheada quando a mesma query repete em 60s".

### Linguagem ativa
Sujeito + verbo modal + ação. Evite passiva ("o token deve ser invalidado") — prefira ativa ("o sistema deve invalidar o token").

## Convertendo prosa → EARS

Cenário comum: o stakeholder escreve em prosa solta. Sua tarefa é converter em EARS antes de plan.

**Original (prosa)**:
> "O sistema deve permitir que usuários alterem sua senha. Eles precisam confirmar a senha antiga e fornecer a nova duas vezes. Se a senha antiga estiver errada, mostra erro. Senhas devem ter pelo menos 8 caracteres e incluir um número."

**Convertido (EARS)**:
1. *Quando* o usuário envia formulário de alteração de senha com senha antiga válida e duas senhas novas idênticas, *então* o sistema deve atualizar a senha e invalidar todas as sessões ativas.
2. *Se* o usuário envia o formulário com senha antiga incorreta, *então* o sistema deve recusar com mensagem genérica "credenciais inválidas".
3. *Se* o usuário envia o formulário com senhas novas que não coincidem, *então* o sistema deve exibir erro "senhas não coincidem".
4. *Se* a senha nova tem menos de 8 caracteres ou não contém ao menos um dígito, *então* o sistema deve exibir erro de política de senha antes de tentar a alteração.

Note como a conversão **revelou** dois cenários (sessões e mensagem genérica) que estavam implícitos. Esse é o ganho real de EARS para SDD: **reduz ambiguidade**.

## Anti-patterns

| Frase | Por que é ruim | Reformule para |
|-------|----------------|----------------|
| "deve ser able to..." | "able to" não é resposta | "quando X, deve fazer Y" |
| "should support..." | suporte de quê? | gatilho + resposta concretos |
| "must work..." | trabalhar como? | comportamento observável |
| "be intuitive" | subjetivo | métrica de UX testável |
| "fast" / "scalable" | adjetivo solto | número + cenário |
| "appropriate" / "as needed" | depende | regra explícita |

## Quando NÃO usar EARS

EARS é ideal para **comportamento de sistema**. Não é o melhor formato para:
- **Visão/objetivo de produto** — use prosa de produto
- **Constraints de UX/visual** — use mockups, design system
- **Requisitos não funcionais transversais** (LGPD, acessibilidade) — listas/checklist são melhores
- **Específicos de negócio puros** ("comissão de 3%") — fórmulas/tabelas explicam melhor

Combine EARS com outros formatos quando útil — `requirements.md` pode ter seção EARS para o core e seção em prosa para visão/contexto.
