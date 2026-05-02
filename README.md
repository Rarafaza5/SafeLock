# SafeLock — Sistema de Controlo Parental

## Resultado Final: 2 Instaladores .exe

```
output/
├── SafeLock Admin Setup.exe     → Instalar NO TEU PC (pai)
└── SafeLockAgent-Setup.exe      → Instalar NO PC DO FILHO
```

---

## Como Funciona

```
[Teu PC]          [Internet - Gratuito]     [PC do Filho]
Admin App    ←──── Render.com Relay ────→   Agent Service
(Electron)          (sempre online)          (Windows Service)
```

---

## Processo Completo (fazer uma única vez)

### Pré-requisitos (instala no teu PC)
| Software | Link |
|---|---|
| Node.js 18+ | https://nodejs.org |
| Python 3.11+ | https://python.org/downloads |
| Inno Setup 6 | https://jrsoftware.org/isdl.php |

---

### Passo 1 — Deploy do Relay (5 minutos)

1. Cria conta gratuita em **[render.com](https://render.com)**
2. Clica **New → Web Service**
3. Escolhe **"Deploy from a Git repository"** ou usa o **Deploy direto**:

```
Build Command: npm install
Start Command: npm start
Pasta:         safelock-relay/
Plan:          Free
```

4. Após deploy (2-3 min), copia o URL: `https://xxx.onrender.com`

> **Alternativa rápida:** Corre `deploy-relay.bat` para guia passo a passo.

---

### Passo 2 — Configurar (1 minuto)

```
configure.bat
```

O script pergunta:
- URL do relay (do Passo 1)
- Palavra-passe do Admin
- Segredo de comunicação
- ID do cliente (ex: `filho-joao`)

---

### Passo 3 — Build dos 2 EXEs (5-10 minutos)

```
build-all.bat
```

Gera automaticamente na pasta `output/`:
- `SafeLock Admin Setup.exe`
- `SafeLockAgent-Setup.exe`

---

### Passo 4 — Instalar

| EXE | Onde instalar | Como |
|---|---|---|
| `SafeLock Admin Setup.exe` | **Teu PC** | Duplo clique → seguir assistente |
| `SafeLockAgent-Setup.exe` | **PC do filho** | **Botão direito → Executar como Admin** |

Após instalar o Agent, o serviço inicia automaticamente e permanece ativo para sempre, em todos os utilizadores do PC.

---

## Funcionalidades

| | |
|---|---|
| 🌐 Bloquear sites | Edita o ficheiro hosts do Windows |
| 📱 Bloquear apps | Monitoriza e fecha processos |
| 🔒 Lockdown total | Ecrã bloqueado com mensagem |
| ⏰ Horários | Bloqueio automático por dia/hora |
| 📊 Histórico | Sites e apps usados |
| 🔄 Tempo real | WebSocket — comandos instantâneos |
| 🔁 Reconexão | Automática se a internet falhar |

---

## Palavra-passe por defeito

```
safelock2024
```

> Altera em configure.bat antes de fazer o build.

---

## Resolução de Problemas

| Problema | Solução |
|---|---|
| Admin mostra "A ligar..." | Relay no Render demora ~30s ao arrancar (normal na 1ª vez) |
| Cliente aparece "Offline" | Vai a `services.msc` → verifica se `SafeLockAgent` está a correr |
| Bloqueio de sites não funciona | O serviço precisa de correr como SYSTEM — verifica os logs em `C:\ProgramData\SafeLock\logs\` |
| Ecrã de lockdown não abre | Confirma que `SafeLockUI.exe` está em `C:\Program Files\SafeLock\` |

---

## Ficheiros de Log

```
C:\ProgramData\SafeLock\
├── logs\agent.log      → Log do serviço
├── state.json          → Bloqueios ativos (persistente)
├── schedule.json       → Horários configurados
└── history.db          → Histórico (SQLite)
```
