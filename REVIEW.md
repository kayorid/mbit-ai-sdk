# REVIEW MBit v0.2.0

Revisão de profundidade pré-release a squads piloto. Foco em bugs reais,
portabilidade macOS/Linux, conformidade com spec do Claude Code e
inconsistências de release. Auditados:
- 8 plugins, 8 hooks shell, 6 scripts em `scripts/`, 3 libs, 2 achievements.
- 11 manifestos JSON (marketplace + plugin.json + hooks.json + allowlist + definitions).
- 30+ comandos `*.md` e 6 SKILL.md.
- Suite smoke (58 PASS) só cobre estrutura — vários bugs de runtime abaixo
  passariam pela suite atual.

---

## BLOCK (impede release)

### B-1: marketplace declara `mb-ai-core@0.2.0` mas o plugin.json diz `0.1.0`
**Arquivo:** `/Users/kayoridolfi/Documents/vibecoding/plugin-mb-ai/.claude-plugin/marketplace.json:12` vs
`/Users/kayoridolfi/Documents/vibecoding/plugin-mb-ai/plugins/mb-ai-core/.claude-plugin/plugin.json:4`
**Problema:** Marketplace anuncia v0.2.0 do core; o plugin.json (fonte de
verdade que o Claude Code carrega) ainda está em 0.1.0. Todos os outros 7
plugins estão em 0.1.0 nos dois lados. `update.sh` compara
`plugin.json.version` com `marketplace.json.plugins[].version` — vai
*sempre* sinalizar update disponível, e o `pull` não vai mudar nada (já
está na "última" do repo).
**Como reproduzir:** `for f in plugins/*/.claude-plugin/plugin.json; do jq -r '.name+"@"+.version' "$f"; done`
e comparar com `jq -r '.plugins[]|.name+"@"+.version' .claude-plugin/marketplace.json`.
**Sugestão:** decidir o número (0.2.0) e atualizar **todos** os
plugin.jsons + marketplace para o mesmo. Adicionar teste smoke
`plugin.version == marketplace.plugins[name].version`.

### B-2: `cost-report.sh` quebra com `unbound variable: FEAT` em day/week/month
**Arquivo:** `plugins/mb-cost/scripts/cost-report.sh:64` (e linha 6 `set -uo pipefail`)
**Problema:** `FEAT` só é setado no caso `feature`. Linha 64 passa
`-v feat="$FEAT"` ao awk; com `-u` ativo, qualquer `/mb-cost`,
`/mb-cost-alert` ou `/mb-cost <day|week|month>` aborta no meio do
relatório (mas só **depois** de imprimir cabeçalho — pior UX,
`exit_code` continua 0 por causa do pipe).
**Como reproduzir:**
```
mkdir -p /tmp/c/.mb/audit && cd /tmp/c
echo "2026-05-09T10:00:00Z | feature=foo | phase=PLAN | tool=Bash | in_tokens=100 | out_tokens=50 | model=x | actor=t" > .mb/audit/cost.log
bash plugins/mb-cost/scripts/cost-report.sh week
# → "FEAT: unbound variable"
```
**Sugestão:** `FEAT="${FEAT:-}"` antes do `case`, ou inicializar `FEAT=""` no topo.

### B-3: `pii-scan.sh` e `private-key-scan.sh` usam sintaxe Perl (`(?:...)`) com `grep -E` (POSIX ERE)
**Arquivo:** `plugins/mb-security/hooks/scripts/pii-scan.sh:49` e
`plugins/mb-security/hooks/scripts/private-key-scan.sh:19-20`
**Problema:** `grep -E` não suporta non-capturing groups Perl `(?:...)`.
Exemplos no código:
- pii: `\b(4[0-9]{12}(?:[0-9]{3})?|5[1-5]...|3[47]...|6(?:011|5[0-9]{2})...)\b`
- private-key: `\b(?:0x)?[a-fA-F0-9]{64}\b...` e `\b(?:[a-z]+ ){11,23}[a-z]+`

Em `grep -E`, `(?:` é tratado como literal `(`, depois `?` quantificador
sem antecedente → comportamento indefinido / não casa nada na maioria
das implementações (no GNU grep dá warning silencioso e nunca dispara).
Resultado: hooks de cartão de crédito, chave Ethereum hex e BIP-39
mnemonic **nunca bloqueiam** — falsa sensação de segurança.
**Como reproduzir:**
```
echo '{"tool_name":"Write","tool_input":{"file_path":"src/x.go","content":"card 4111111111111111"}}' \
  | bash plugins/mb-security/hooks/scripts/pii-scan.sh; echo $?
# → 0 (deveria ser 2)
```
**Sugestão:** trocar para `grep -P` (PCRE) **OU** reescrever sem
non-capturing groups (use `( ... )` simples e ignore captures), **OU**
chamar `perl -ne` para essas regras. A solução mais portável: remover
`?:`, aceitar grupos capturáveis. Adicionar caso de smoke positivo
("payload com cartão deve bloquear").

### B-4: cost-capture roda em **toda** PostToolUse — overhead alto e sem dados
**Arquivo:** `plugins/mb-cost/hooks/hooks.json:5` (matcher `.*`) +
`plugins/mb-cost/hooks/scripts/cost-capture.sh`
**Problema:** o hook é executado depois de **cada** chamada de tool
(Read, Glob, Bash etc.) — em uma sessão típica isso são centenas de
forks `bash + jq + git + find`. Pior: o payload PostToolUse não inclui
`usage.input_tokens` no Claude Code (esses tokens vêm no nível de
mensagem do agente, não do tool result). O script sai cedo (`[[ -z ... ]]
&& exit 0`) **mas só depois de invocar `jq` 6 vezes + `git config` +
`find docs/specs/_active`** em todo tool call. Em projetos grandes,
`find` em `docs/specs/_active` pode ser 100-300ms cada.

Estimativa: 200 tool calls × ~150ms = 30s de overhead acumulado por
sessão sem nenhuma linha gravada em `cost.log`.
**Sugestão (uma de):**
1. Restringir matcher a algo que de fato carrega usage (`Task` se a tool
   `Task` expor; ou mover pra `Stop`/`SessionEnd` lendo transcript).
2. Curto-circuito antes de qualquer `jq`: `grep -q '"usage"' <<<"$INPUT" || exit 0`.
3. Cachear a "feature/phase" atuais em `.mb/_runtime/current-phase` atualizado
   por outro hook menos frequente, em vez de rodar `find` em todo tool.

### B-5: scripts shell usam `set -uo pipefail` (sem `-e`) — falhas silenciosas
**Arquivos:** `plugins/mb-ai-core/scripts/{dashboard,doctor,update}.sh`,
`plugins/mb-cost/scripts/cost-report.sh`, `tests/smoke/run.sh`
**Problema:** sem `-e`, qualquer `find ... | wc -l` ou `jq` que falhe
não interrompe o script — números errados (zero ou string vazia) são
exibidos como métricas válidas. Combinado com `-u`, mistura o pior dos
mundos: aborta em variável não-definida (B-2) mas continua em comando
que falhou.
**Sugestão:** padronizar `set -euo pipefail` em **scripts CLI**;
manter `set -euo pipefail` nos hooks (já está). Auditar lugares onde a
falha é esperada e usar `cmd || true` explicitamente.

---

## HIGH (resolver antes de v0.3)

### H-1: CHANGELOG está congelado em v0.1.0 e RELEASE-NOTES é de outro projeto
**Arquivo:** `CHANGELOG.md` (só tem `## [0.1.0]`), `RELEASE-NOTES.md` (fala de "1.0.0 — extraído do projeto wis-lms")
**Problema:** estamos em v0.2.0, mas:
- nenhuma entrada `## [0.2.0]` no CHANGELOG;
- `mb-cost` não é mencionado em lugar nenhum (CHANGELOG, README, playbook);
- `RELEASE-NOTES.md` descreve a v1.0 do plugin SDD original (wis-lms),
  totalmente desalinhado com o que está em produção neste repo.
**Sugestão:** adicionar bloco `## [0.2.0] — 2026-05-10` listando: `mb-cost`,
achievements, dashboard, snapshot, tutorial, doctor, statusline, update,
hooks de PII/private-key. Reescrever ou apagar `RELEASE-NOTES.md`.

### H-2: `audit-log.sh` / `hook-fires.log` sem proteção contra writes concorrentes
**Arquivo:** `plugins/mb-ai-core/hooks/scripts/audit-log.sh:17` (e
todos os hooks que fazem `echo ... >> .mb/audit/<x>.log`)
**Problema:** múltiplos hooks (PreToolUse Write|Edit roda 3 scripts em
paralelo: secret-scan + pii-scan + private-key-scan). Quando dois
escrevem `>>` no mesmo log, o `echo` de uma linha individual é atômico
no POSIX (até `PIPE_BUF`, normalmente 4096B), e como cada `>> file` faz
`open(O_APPEND)`, geralmente está OK. Mas o write do `audit-log.sh`
inclui `head -c 300` da linha `command` — se o comando contiver newlines
sem escape, a "linha" pode quebrar em duas e corromper parsing
(`dashboard.sh` faz `awk -F'|' '$1>=wa'` — um command com `|` literal
ou newline já corrompe a separação).
**Sugestão:**
1. Sanitizar com `tr -d '\n|'` antes do `head -c 300`.
2. Para garantir atomicidade total, usar `flock`:
   `( flock -x 200; echo "..." >&200; ) 200>>"$AUDIT_DIR/.lock"`.

### H-3: `BLOCKS_WEEK` no dashboard usa `awk -F'|' '$1>=wa'` — quebra com `|` no comando
**Arquivo:** `plugins/mb-ai-core/scripts/dashboard.sh:34`
**Problema:** linhas do `audit-log.sh` têm formato
`<ts> | actor=... | exit=... | cmd=...`. Se o `cmd` original contém `|`
(pipes shell, e.g. `git log | head`), o `head -c 300` deixa `|`
literal — o awk vai contar campos errados e o filtro `$1>=wa` ainda
funciona (campo 1 = timestamp), então OK aqui — mas em **achievements
checker linha 31** (`grep -c ... | awk -F: '{s+=$2}'`) o output do grep
com múltiplos arquivos é `path:count`, e se o path contiver `:` (raro
em `.mb/audit/*` então OK na prática).

Na prática o bug real é diferente: `WEEK_AGO` usa `date -u -v-7d` (BSD)
ou `date -u -d "7 days ago"` (GNU); cair em ambiente sem nenhum dos
dois deixa `WEEK_AGO=""` e o `if [[ -n "$WEEK_AGO" ]]` pula a contagem
— fica `BLOCKS_WEEK=0` silenciosamente. Está protegido, mas merece um
warning visível ("dashboard sem dados semanais — date utility não
suportada"). Tratar como **medium-low** dependendo da política.
**Sugestão:** se `WEEK_AGO=""`, exibir "n/d" em vez de `0` para evitar
métrica falsa que parece "tudo limpo".

### H-4: `notify.sh` (achievements) não está plugado em nenhum hook
**Arquivo:** `plugins/mb-ai-core/achievements/notify.sh` — nunca
referenciado em `hooks/hooks.json`. Único caller é `commands/mb-achievements.md`.
**Problema:** dashboard menciona "achievements 0/12" e definições
existem, mas o desbloqueio só é detectado se o usuário rodar
`/mb-achievements` manualmente. Roteiro de tutorial implica que
desbloqueios aparecem "mágica e celebrativamente". Sem hook
SessionEnd/Stop, ninguém vê o banner.
**Sugestão:** adicionar entrada em `hooks/hooks.json` (Stop ou
SessionEnd):
```json
"Stop": [{ "hooks": [{ "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/achievements/notify.sh" }]}]
```
(Stop já tem `stop-farewell.sh` — adicionar segundo entry no array, ou
criar evento dedicado.)

### H-5: `doctor.sh` linha 107 — `find` com `-o` sem parens é sintaticamente correto mas frágil
**Arquivo:** `plugins/mb-ai-core/scripts/doctor.sh:107`
**Problema:** `find "$PLUGIN_PARENT" -path '*/hooks/scripts/*.sh' -o -path '*/scripts/*.sh' -o -path '*/lib/*.sh'`
sem `-print` explícito após o último termo: o `find` aplica `-print`
implícito **só** ao último predicado da disjunção quando há `-o`. Na
prática o GNU find e BSD find tratam isto diferente — em alguns
ambientes só os matches do último `-path` são impressos, fazendo o
loop `while read script` ignorar hooks/scripts. **Verificar
empiricamente é simples:** rode em macOS e Linux e compare contagem.
**Sugestão:**
```bash
find "$PLUGIN_PARENT" \( -path '*/hooks/scripts/*.sh' -o -path '*/scripts/*.sh' -o -path '*/lib/*.sh' \) -print
```

### H-6: `update.sh` faz `cd "$CACHE"` e roda `git pull` cegamente
**Arquivo:** `plugins/mb-ai-core/scripts/update.sh:27,58`
**Problema:**
- assume que `~/.claude/plugins/cache/mb` é git repo limpo. Se o usuário
  fez qualquer mod local, `git pull` falha sem tratamento;
- `cd "$CACHE" 2>/dev/null || exit 1` perde o motivo;
- após `cd`, qualquer leitura subsequente assume cwd = cache, então o
  retorno do prompt para o usuário também muda cwd (o `read -p` é
  recebido na pasta errada);
- não valida que o `LATEST` extraído do remoto é válido (semver) antes
  de comparar string. Bug clássico: `0.10.0 == 0.1.0` ordem
  lexicográfica.
**Sugestão:** fazer `git -C "$CACHE" fetch && git -C "$CACHE" pull`
sem `cd`. Comparar versões com `sort -V` ou `dpkg --compare-versions`
(ou warn explícito que comparação é só igualdade).

### H-7: `secret-scan.sh` regex `.env` heurística bloqueia até `KEY=` vazio se houver content
**Arquivo:** `plugins/mb-ai-core/hooks/scripts/secret-scan.sh:48-49`
**Problema:** `^[A-Z_]+=[^[:space:]]+` casa qualquer linha com `KEY=valor`,
incluindo placeholders intencionais como `KEY=changeme`,
`KEY=<your-token-here>` (porque `<` não é whitespace). Bloqueia também
`.env.local`, `.env.development` (não filtrados — só `.env.example` e
`.env.template`). Resultado esperável: usuário cria `.env.local` com
placeholders → bloqueado → frustração.
**Sugestão:** estender allowlist: `*.env.example|*.env.template|*.env.sample`
e adicionar regra de exceção: ignorar valores entre `<...>` ou `${...}`.

### H-8: SessionStart hook pode quebrar se `manifesto.txt` tem linhas em branco
**Arquivo:** `plugins/mb-ai-core/hooks/scripts/session-start-banner.sh:24-27`
**Problema:** `TOTAL_LINES=$(grep -c . "$MANIFESTO_FILE")` conta só
linhas não-vazias. `RAND_LINE=$(( (RANDOM % TOTAL_LINES) + 1 ))`. Mas
`sed -n "${RAND_LINE}p"` aplica em **todas** as linhas do arquivo
incluindo as vazias → `QUOTE` pode sair vazia. Se `RANDOM=0` e
TOTAL_LINES=0 (arquivo manifesto vazio ou ausente) → divisão por zero
(`% 0` → erro aritmético em bash). O `|| echo 1` no `grep -c` ajuda só
se o `grep` falhar com exit≠0; com arquivo vazio `grep -c` retorna 0
exit 1 (sem match) → fallback `1` aplicado, OK. Mas se o arquivo
existe e tem 1 linha, `RANDOM % 1 == 0`, `+1 == 1`, OK. Edge robusto:
adicionar guard explícito.
**Sugestão:** ler arquivo via `mapfile -t lines < <(grep -v '^$' "$MANIFESTO_FILE")`
e selecionar `${lines[$((RANDOM % ${#lines[@]}))]}`.

### H-9: regex `git[[:space:]]+push[[:space:]]+.*-f([[:space:]]|$)` em destructive-confirm é frágil
**Arquivo:** `plugins/mb-ai-core/hooks/scripts/destructive-confirm.sh:20`
**Problema:** casa qualquer comando contendo `-f` em qualquer posição
após `git push` — incluindo `git push --force-with-lease` (correto
inclui `-f` literal? Sim: `--force-with-lease=...` contém `-f` mas
precedido de `-`). Mas também `git push origin main:my-feature -f` é
legítimo bloqueado. Mais sério: pula `--force-with-lease` que é
**preferido** sobre `--force` por ser mais seguro. Tratamento atual
bloqueia o seguro **e** o inseguro.

E `:>[[:space:]]*[^[:space:]]+\.(go|...)$` (linha 30): pretende casar
"truncate file" via `: > foo.go`. O `$` ancora em fim de string, mas
shell scripts costumam ser passados como uma string única — OK.
Porém `:>foo.go` (sem espaço) também deveria casar e o `[[:space:]]*`
permite zero espaço, então OK. Edge: `echo > foo.go` (não casa, mas é
igualmente destrutivo).
**Sugestão:** whitelist `--force-with-lease` explicitamente; documentar
limitações.

---

## MEDIUM (próxima sprint)

### M-1: hooks PreToolUse Write|Edit do mb-ai-core e mb-security executam em paralelo — duplicação custosa
**Arquivos:** `plugins/mb-ai-core/hooks/hooks.json:53-60` (Write|Edit →
secret-scan) + `plugins/mb-security/hooks/hooks.json` (Write|Edit →
pii-scan + private-key-scan).
**Problema:** três scripts shell + jq parsing do mesmo payload em todo
Write/Edit. Além disso `secret-scan` cobre a regra de chave privada
(linha 22) — sobreposição com `private-key-scan`.
**Sugestão:** consolidar em um único script `pre-write-guard.sh` com
todas as regras, ou rodar um e marcar o outro como "unless other plugin
already covers". Reduz overhead em ~3x para Write/Edit.

### M-2: `statusline.sh` não tem fallback para terminal estreito
**Arquivo:** `plugins/mb-ai-core/hooks/scripts/statusline.sh:57-58`
**Problema:** linha de status tem ~120 colunas com 6 separadores `│`.
Em terminal de 80 cols (laptop, Cursor split-pane) quebra horrivelmente,
quebra a linha do prompt.
**Sugestão:** detectar `${COLUMNS}` (do payload `workspace`?) e usar
formato compacto se < 100. Ou abreviações: `boot ✓ · 3 · PLAN · 🛡 0`.

### M-3: `mcp-allowlist.sh` falha aberta se allowlist sintaticamente inválida
**Arquivo:** `plugins/mb-ai-core/hooks/scripts/mcp-allowlist.sh:24`
**Problema:** `APPROVED=$(jq -r '.approved[].name' "$ALLOWLIST_FILE" 2>/dev/null || true)`.
Se o JSON está corrompido, APPROVED fica vazio → todos os MCPs sem
prefixo `mb_*` ou `mercadobitcoin_*` são bloqueados. OK (failsafe), mas
sem mensagem informativa.
**Sugestão:** se `jq` retornar erro, log explícito "[mb-ai-core] WARN —
allowlist file corrupto, bloqueando preventivamente" com path do
arquivo.

### M-4: extração de SQUAD em statusline e session-banner usa `head -c 20` que pode cortar UTF-8 no meio de byte
**Arquivo:** `plugins/mb-ai-core/hooks/scripts/statusline.sh:30` e
`session-start-banner.sh:38`
**Problema:** `head -c 20` corta por bytes; squads com nome em emoji
ou acento (e.g. "Squad Câmbio") podem mostrar caractere quebrado. macOS
`head` não tem `-m` (chars).
**Sugestão:** usar `awk 'BEGIN{l=20} {print substr($0,1,l)}'` ou trocar
para `cut -c1-20` (também byte-based mas comum) — solução real é
limitar antes via jq: `--arg max 20 ... | .[0:$max]`.

### M-5: `cost-capture` hardcoda preços padrão em `cost-report.sh` mas não em `cost-capture` — log fica sem custo
**Arquivo:** `plugins/mb-cost/hooks/scripts/cost-capture.sh:39`
**Problema:** `cost.log` registra só tokens, conversão para USD/BRL
acontece no relatório. Se `MB_PRICE_IN/OUT/USD_BRL` mudar, dados
históricos refletem **novo** preço (não o que foi pago). Para auditoria
financeira isso é problemático (LGPD/Bacen contábil exige snapshot do
preço vigente).
**Sugestão:** gravar `price_in/price_out/rate` na linha do `cost.log`
no momento da captura.

### M-6: `dashboard.sh` faz `cd "$CWD" 2>/dev/null || true` indiretamente via statusline — não, dashboard é stand-alone
Skip — sem bug confirmado.

### M-7: achievement `centurion` (`spec_commits>=100`) usa `git log | grep -c '\[spec:' || echo 0`
**Arquivo:** `plugins/mb-ai-core/achievements/checker.sh:73-74`
**Problema:** `grep -c` retorna `0` com exit code `1` quando não há match;
isso aciona o `|| echo 0` correto. Mas `git log --oneline` em repos
antigos com 50k commits + grep gera ~150ms. O checker roda toda vez que
`/mb-achievements` é invocado (sync, ~1-2s total). Aceitável mas vai
ser lento em monorepos.
**Sugestão:** cachear resultado em `.mb/achievements.json` com `last_evaluated_at` e re-avaliar só se diff > 5 min.

### M-8: SessionStart hook output usa `additionalContext` — formato OK mas conteúdo tem ANSI colors
**Arquivo:** `plugins/mb-ai-core/hooks/scripts/session-start-banner.sh:60-82`
**Problema:** `additionalContext` vai para o **contexto do agente**
(LLM input), não para o terminal. ANSI escapes (`\033[...`) entram no
prompt do modelo — gasta tokens (cada `\033[38;5;220m` = 8 tokens) e
pode confundir o modelo. Banner inteiro com cores → 100-200 tokens
desperdiçados em **toda** sessão nova.
**Sugestão:** ter dois modos: imprimir versão colorida em **stderr**
(para o terminal) e versão sem ANSI em `additionalContext`. Ou separar
em dois hooks: visual no stderr, contexto textual via additionalContext
sem cores.

### M-9: Stop hook escreve em stderr — visibilidade depende do harness
**Arquivo:** `plugins/mb-ai-core/hooks/scripts/stop-farewell.sh:39`
**Problema:** stderr de hooks Stop é capturado pelo Claude Code e
exibido como "hook output" no terminal, mas com prefixo. Em alguns
clientes (Cursor, headless) pode ser engolido. Mensagem "Sessão
encerrada · 0 aprovações..." pode nunca aparecer se cliente filtrar
stderr de hooks Stop.
**Sugestão:** validar comportamento em pelo menos 2 clientes (CLI +
Cursor) antes de release. Se Cursor filtra, considerar usar
`hookSpecificOutput.additionalContext` no Stop hook em vez de stderr.

### M-10: `private-key-scan.sh` regex `mnemonic.{0,40}=.{0,400}\b...` é vulnerável a ReDoS
**Arquivo:** `plugins/mb-security/hooks/scripts/private-key-scan.sh:20`
**Problema:** `.{0,400}` antes de outro padrão complexo causa
backtracking exponencial em conteúdos adversariais. Atacante interno
poderia DoS o hook com payload de 50KB que faz o grep gastar minutos.
Risco baixo (atacante já tem write no repo) mas degrada UX em files
legítimos grandes (e.g. arquivo `wordlist.txt` com 2k palavras em
inglês).
**Sugestão:** ancorar melhor o padrão; limitar input via `head -c 100k`
antes do grep.

---

## INFO / sugestão

### I-1: nenhum dos hooks valida `jq` está instalado antes de chamar
Se o usuário não tem `jq`, **todos** os hooks abortam com `command not
found` impresso em stderr — mas exit 127, não 2, então o Claude Code
não trata como block. `doctor.sh` detecta ausência mas é sob demanda.
Sugestão: hook leve em SessionStart que avisa se `jq` está ausente.

### I-2: `tests/smoke/run.sh` usa `set -uo pipefail` e cobre só estrutura
Adicionar testes de execução real de hooks com payloads sintéticos
(payload válido / payload sem usage / payload corrompido) — capturaria
B-2, B-3, B-4 trivialmente.

### I-3: cross-reference `/mb-threat-model` — verificado, está correto
`mb-sdd/commands/mb-spec-design.md:12` referencia `/mb-threat-model`,
que existe em `mb-security/commands/mb-threat-model.md`. OK.

### I-4: comandos sem `argument-hint` quando recebem args (mb-update, mb-banner)
`/mb-update` e `/mb-banner` não recebem args (OK omitir). `/mb-help`,
`/mb-status`, `/mb-doctor`, `/mb-dashboard`, `/mb-achievements`,
`/mb-cost-alert`, `/mb-cost`: sem args → OK. Verificado todos os com
`$ARGUMENTS` têm `argument-hint`. **Compliance OK.**

### I-5: `dashboard.sh` sparkline usa `find` por trimestre — N+1 em monorepos
Faz 8 chamadas de `find docs/specs/_archive/<Y>-Q<N>` mesmo se a pasta
não existe. Aceitável para v0.2.0; otimizar quando dashboard for
chamado em hook (não está, OK por enquanto).

### I-6: README e MANUAL não mencionam mb-cost / achievements / tutorial
README.md fala de v0.1 / v0.5 / v1.0 roadmap mas comandos novos do core
(achievements, dashboard, tutorial, snapshot, doctor, update) não
aparecem na tabela "comandos disponíveis". Atualizar antes de mostrar
para piloto.

### I-7: `mcp-allowlist` não permite MCPs com underscore no `server`
Pattern `^mcp__([^_]+(_[^_]+)*)__.*`: nome de server precisa ser
`a_b_c` (split por `_`) ou `single`. MCPs com nome contendo `__`
(double underscore) seriam quebrados. Não confirmado em produção;
documentar limitação.

---

## Resumo executivo

- **5 BLOCK** — versões dessincronizadas, cost-report quebrado,
  hooks de PII com regex inválida, cost-capture caro demais, falta
  `set -e`. **Todos reproduzíveis em 1 minuto.**
- **9 HIGH** — CHANGELOG/release notes desatualizados, race conditions
  em audit, achievements órfãos, edge cases em scripts.
- **10 MEDIUM** — overhead de hooks duplicados, statusline em terminal
  estreito, contexto poluído com ANSI.
- **7 INFO** — melhorias de robustez e doc.

**Recomendação:** não promover a piloto sem resolver pelo menos
B-1 a B-4. B-3 é especialmente crítico — comunica falsa proteção de
PII/cripto, exatamente o oposto da promessa do plugin de segurança.
