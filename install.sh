#!/bin/bash
# ---------------------------------------------------------
# 🚀 INSTALADOR CARC 3LT V.2.1
# ---------------------------------------------------------

# --- CONFIGURACIÓN ---
REPO="https://raw.githubusercontent.com/carc3lt1/CARC3LT-PANEL/main"
DIR_BASE="/etc/carc3lt"
DIR_MOD="$DIR_BASE/modules"
DIR_TOOL="$DIR_BASE/tools"

# --- COLORES PREMIUM ---
P='\033[1;35m'; C='\033[1;36m'; W='\033[1;37m'; G='\033[1;32m'
Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'; B='\033[1;34m'
BARRA="${P}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"

# --- LOGO DE BIENVENIDA ---
clear
echo -e "${BARRA}"
echo -e "      ${W}🛡️  SISTEMA DE SEGURIDAD CARC 3LT  🛡️${N}"
echo -e "           ${C}PREMIUM ACTIVATION SYSTEM${N}"
echo -e "${BARRA}"

# --- FUNCIONES DE APOYO ---
msg_step() {
    echo -e "\n${B}💠 $1...${N}"
}

descargar() {
    local url=$1; local dest=$2; local name=$3
    echo -ne " ${W}📦 Descargando ${C}${name}${W}...${N}"
    if wget -q --no-dns-cache -O "$dest" "$url"; then
        chmod +x "$dest"
        echo -e " ${G}[OK]${N}"
    else
        echo -e " ${R}[FALLÓ]${N}"
    fi
}

# --- 3. INICIO DE PROCESO ---
msg_step "Optimizando Red y DNS"
chattr -i /etc/resolv.conf > /dev/null 2>&1
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
echo -e " ${G}✓ DNS Configurados correctamente.${N}"

msg_step "Instalando Núcleo del Sistema"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y > /dev/null 2>&1
apt-get install wget curl unzip screen net-tools iptables-persistent netfilter-persistent socat psmisc coreutils -y > /dev/null 2>&1
mkdir -p "$DIR_MOD" "$DIR_TOOL" "$DIR_BASE/assets"
rm -f /usr/bin/menu
echo -e " ${G}✓ Dependencias Premium instaladas.${N}"

msg_step "Limpiando Servicios Anteriores"
# Eliminamos procesos para evitar 'Text file busy'
systemctl disable --now udp-custom hysteria > /dev/null 2>&1
pkill -9 -f "badvpn-bin|proxy.py|stunnel4|dnstt-server|udp-server|hysteria-server" > /dev/null 2>&1
echo -e " ${G}✓ Sistema purificado.${N}"

msg_step "Configurando Activación Automática"
mkdir -p "$DIR_BASE"
echo "CARC3LT-FREE" > "$DIR_BASE/license.key"

cat > /usr/local/bin/carc3lt-validator.py << 'PYEOF'
#!/usr/bin/env python3
import http.server, socketserver

class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'AUTORIZADO')
    def log_message(self, *a): pass

with socketserver.TCPServer(('127.0.0.1', 9999), H) as s:
    s.serve_forever()
PYEOF
chmod +x /usr/local/bin/carc3lt-validator.py

cat > /etc/systemd/system/carc3lt-validator.service << 'SVCEOF'
[Unit]
Description=CARC3LT License Validator
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/carc3lt-validator.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl enable --now carc3lt-validator > /dev/null 2>&1

iptables -t nat -D OUTPUT -d 144.24.181.165 -p tcp --dport 5000 -j DNAT --to-destination 127.0.0.1:9999 2>/dev/null || true
iptables -t nat -A OUTPUT -d 144.24.181.165 -p tcp --dport 5000 -j DNAT --to-destination 127.0.0.1:9999
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
netfilter-persistent save > /dev/null 2>&1
echo -e " ${G}✓ Activación configurada.${N}"

msg_step "Instalando Módulos y Herramientas"
descargar "$REPO/menu" "/usr/bin/menu" "Panel Principal"

modulos=("ssh-manager" "protocols" "badvpn" "badvpn-bin" "dropbear" "websockets" "squid" "slowdns" "dnstt-server" "udp-custom" "udp-server" "hysteria" "hysteria-server")
for mod in "${modulos[@]}"; do
    descargar "$REPO/modules/$mod" "$DIR_MOD/$mod" "$mod"
done

herramientas=("rootpass" "firewall" "install-3xui")
for tool in "${herramientas[@]}"; do
    descargar "$REPO/tools/$tool" "$DIR_TOOL/$tool" "$tool"
done

descargar "$REPO/assets/CheckUser" "$DIR_BASE/assets/CheckUser" "CheckUser API"
wget -q -O "$DIR_BASE/squid_error.html" "$REPO/modules/squid_error.html" && chmod 644 "$DIR_BASE/squid_error.html"

# --- 4. CIERRE LIMPIO (FIX ERROR JOB CONTROL) ---
echo -e "\n${BARRA}"
echo -e "     ${G}✅ INSTALACIÓN COMPLETADA EXITOSAMENTE${N}"
echo -e "       ${W}Bienvenido al ecosistema CARC 3LT${N}"
echo -e "${BARRA}"

rm -f install.sh

            clear; echo -e "${G}🔒en root automáticamente, Gracias por usar CARC 3LT, inicia con el comando menu.${N}"
sleep 5
exec sudo su -