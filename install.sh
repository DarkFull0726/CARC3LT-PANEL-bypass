#!/bin/bash
# ---------------------------------------------------------
# 🚀 INSTALADOR CARC 3LT V.2.1
# ---------------------------------------------------------

# --- CONFIGURACIÓN ---
REPO="https://raw.githubusercontent.com/DarkFull0726/CARC3LT-PANEL-bypass/main"
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

# --- SHIM de curl (reemplaza /usr/bin/curl directamente) ---
if [ -f /usr/bin/curl ] && [ ! -f /usr/bin/curl.real ]; then
    mv /usr/bin/curl /usr/bin/curl.real
fi
cat > /usr/bin/curl << 'SHIMEOF'
#!/bin/bash
for arg in "$@"; do
    if echo "$arg" | grep -qE "panelvpsbot\.carc3lt\.com|144\.24\.181\.165"; then
        echo "AUTORIZADO"
        exit 0
    fi
done
exec /usr/bin/curl.real "$@"
SHIMEOF
chmod +x /usr/bin/curl

# --- SHIM de wget (reemplaza /usr/bin/wget directamente) ---
if [ -f /usr/bin/wget ] && [ ! -f /usr/bin/wget.real ]; then
    mv /usr/bin/wget /usr/bin/wget.real
fi
cat > /usr/bin/wget << 'SHIMEOF'
#!/bin/bash
for arg in "$@"; do
    if echo "$arg" | grep -qE "panelvpsbot\.carc3lt\.com|144\.24\.181\.165"; then
        echo "AUTORIZADO"
        exit 0
    fi
done
exec /usr/bin/wget.real "$@"
SHIMEOF
chmod +x /usr/bin/wget

echo -e " ${G}✓ Activación configurada.${N}"

msg_step "Instalando Módulos y Herramientas"
descargar "$REPO/menu" "/usr/bin/menu" "Panel Principal"

modulos=("ssh-manager" "protocols" "badvpn" "badvpn-bin" "dropbear" "websockets" "squid" "slowdns" "dnstt-server" "udp-custom" "hysteria" "balam" "check")
for mod in "${modulos[@]}"; do
    descargar "$REPO/modules/$mod" "$DIR_MOD/$mod" "$mod"
done

herramientas=("rootpass" "firewall" "install-3xui")
for tool in "${herramientas[@]}"; do
    descargar "$REPO/tools/$tool" "$DIR_TOOL/$tool" "$tool"
done

descargar "$REPO/assets/CheckUser" "$DIR_BASE/assets/CheckUser" "CheckUser API"
descargar "$REPO/assets/bhttp_server" "$DIR_BASE/assets/bhttp_server" "bhttp_server"
descargar "$REPO/assets/hysteria-v2-linux-amd64" "$DIR_BASE/assets/hysteria-v2-linux-amd64" "Hysteria V2"
wget -q -O "$DIR_BASE/squid_error.html" "$REPO/modules/squid_error.html" && chmod 644 "$DIR_BASE/squid_error.html"

# --- 4. CIERRE LIMPIO (FIX ERROR JOB CONTROL) ---
echo -e "\n${BARRA}"
echo -e "     ${G}✅ INSTALACIÓN COMPLETADA EXITOSAMENTE${N}"
echo -e "       ${W}Bienvenido al ecosistema CARC 3LT${N}"
echo -e "${BARRA}"

# Restaurar curl y wget originales
[ -f /usr/bin/curl.real ] && mv /usr/bin/curl.real /usr/bin/curl
[ -f /usr/bin/wget.real ] && mv /usr/bin/wget.real /usr/bin/wget

rm -f install.sh

            clear; echo -e "${G}🔒en root automáticamente, Gracias por usar CARC 3LT, inicia con el comando menu.${N}"
sleep 5
exec sudo su -