"""
SafeLock - Configure Helper
Atualiza os ficheiros de configuracao com os valores fornecidos.
Chamado pelo configure.bat
"""
import sys
import re
import os

def main():
    if len(sys.argv) < 5:
        print("[ERRO] Uso: configure_helper.py <relay_url> <password> <secret> <client_id>")
        sys.exit(1)

    relay_url   = sys.argv[1].strip().rstrip('/')
    admin_pass  = sys.argv[2].strip()
    relay_secret = sys.argv[3].strip()
    client_id   = sys.argv[4].strip()

    # Garantir que o URL tem protocolo
    if relay_url and not relay_url.startswith(('http://', 'https://')):
        relay_url = 'https://' + relay_url
        print(f"  [AVISO] Protocolo em falta. URL ajustado para: {relay_url}")

    print(f"  Relay URL : {relay_url}")
    print(f"  Client ID : {client_id}")
    print()

    errors = 0

    # ── 1. safelock-agent/config.py ─────────────────────────────────
    agent_config = "safelock-agent/config.py"
    if os.path.exists(agent_config):
        with open(agent_config, "r", encoding="utf-8") as f:
            content = f.read()

        content = re.sub(r'RELAY_URL\s*=\s*".*?"',   f'RELAY_URL = "{relay_url}"',    content)
        content = re.sub(r'RELAY_SECRET\s*=\s*".*?"', f'RELAY_SECRET = "{relay_secret}"', content)
        content = re.sub(r'CLIENT_ID\s*=\s*".*?"',    f'CLIENT_ID = "{client_id}"',    content)

        with open(agent_config, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"  [OK] {agent_config}")
    else:
        print(f"  [ERRO] Ficheiro nao encontrado: {agent_config}")
        errors += 1

    # ── 2. safelock-admin/src/context/SocketContext.jsx ─────────────
    socket_ctx = "safelock-admin/src/context/SocketContext.jsx"
    if os.path.exists(socket_ctx):
        with open(socket_ctx, "r", encoding="utf-8") as f:
            content = f.read()

        content = re.sub(r"const RELAY_URL\s*=\s*'.*?'",    f"const RELAY_URL = '{relay_url}'",    content)
        content = re.sub(r"const RELAY_SECRET\s*=\s*'.*?'", f"const RELAY_SECRET = '{relay_secret}'", content)

        with open(socket_ctx, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"  [OK] {socket_ctx}")
    else:
        print(f"  [ERRO] Ficheiro nao encontrado: {socket_ctx}")
        errors += 1

    # ── 3. safelock-admin/src/App.jsx (password) ─────────────────────
    app_jsx = "safelock-admin/src/App.jsx"
    if os.path.exists(app_jsx):
        with open(app_jsx, "r", encoding="utf-8") as f:
            content = f.read()

        content = re.sub(r"const MASTER_PASSWORD\s*=\s*'.*?'", f"const MASTER_PASSWORD = '{admin_pass}'", content)

        with open(app_jsx, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"  [OK] {app_jsx}")
    else:
        print(f"  [ERRO] Ficheiro nao encontrado: {app_jsx}")
        errors += 1

    # ── 4. safelock-relay/server.js (secret fallback) ────────────────
    relay_server = "safelock-relay/server.js"
    if os.path.exists(relay_server):
        with open(relay_server, "r", encoding="utf-8") as f:
            content = f.read()

        content = re.sub(
            r"process\.env\.RELAY_SECRET \|\| '.*?'",
            f"process.env.RELAY_SECRET || '{relay_secret}'",
            content
        )

        with open(relay_server, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"  [OK] {relay_server}")

    # ── 5. safelock-relay/render.yaml (secret principal no Render) ───
    render_yaml = "safelock-relay/render.yaml"
    if os.path.exists(render_yaml):
        with open(render_yaml, "r", encoding="utf-8") as f:
            content = f.read()

        # Procura a secção do RELAY_SECRET e muda o value
        # Nota: Isto é um regex simples que assume o formato padrão do render.yaml
        pattern = r"(- key: RELAY_SECRET\s+generateValue: false\s+value: ).*"
        content = re.sub(pattern, rf"\1{relay_secret}", content)

        with open(render_yaml, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"  [OK] {render_yaml}")

    if errors > 0:
        print(f"\n  [ERRO] {errors} ficheiro(s) nao foram atualizados.")
        sys.exit(1)
    else:
        print("\n" + "="*50)
        print("  CONFIGURACAO CONCLUIDA!")
        print("="*50)
        print("\n  IMPORTANTE:")
        print(f"  1. Precisas de fazer PUSH das alteracoes para o teu GitHub.")
        print(f"  2. Garante que o Render.com fez redeploy do Relay com o novo segredo.")
        print(f"  3. SO DEPOIS corre o build-all.bat para gerar os novos EXEs.")
        print("="*50)

if __name__ == "__main__":
    main()
