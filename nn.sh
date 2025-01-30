
clear
loading_bar() {
local duration=$1
local message=$2
local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
echo -n "$message " | lolcat
for ((i = 0; i < duration; i++)); do
for ((j = 0; j < ${#spin}; j++)); do
echo -ne "\r${message} ${spin:$j:1}" | lolcat
sleep 0.05
done
done
echo -e "\r$message ✔" | lolcat
}
if [ -d "/var/www/RainPrem" ]; then
loading_bar 2 "MENGHAPUS CACHE"
rm -r /var/www/RainPrem > /dev/null 2>&1
else
clear
loading_bar 1 "LOADING 10%"
fi
if ! command -v jq &> /dev/null; then
loading_bar 2 "MENGINSTALL jq"
apt install jq -y > /dev/null 2>&1
else
clear
loading_bar 1 "LOADING 50%"
fi
if ! command -v lolcat &> /dev/null; then
loading_bar 2 "MENGINSTALL lolcat"
apt install lolcat -y > /dev/null 2>&1
else
clear
loading_bar 1 "LOADING 100%"
fi
echo "SEMUA DEPENDENSI TELAH TERINSTAL!" | lolcat
sleep 2
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA="\e[35m"
LIGHT_GREEN='\033[1;32m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
WHITE='\033[1;37m'
RESET='\033[0m'
trap handle_ctrl_c INT
handle_ctrl_c() {
tput sc
echo -e "${BOLD}${RED}SILAHKAN MEMILIH OPSI E UNTUK KELUAR${RESET}"
sleep 2
tput rc
tput ed
}
VALID_LICENSE="RAIN"
LICENSE_FILE=".license_installer" # Nama file lisensi diubah
ERROR_FILE="/var/error_count.txt"
WHATSAPP_LOG="/var/.whatsapp_logs"  # File log yang disembunyikan
GITHUB_API_TOKEN="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"
GITHUB_FILE_URL="https://api.github.com/repos/SafeStore0000/nowainstallerfree/contents/installer.txt"
function is_license_valid() {
if [[ -f "$LICENSE_FILE" && $(cat "$LICENSE_FILE") == "$VALID_LICENSE" ]]; then
return 0
fi
return 1
}
function is_whatsapp_registered() {
if [[ -f "$WHATSAPP_LOG" ]]; then
local stored_number=$(cat "$WHATSAPP_LOG" | head -n 1)  # Ambil baris pertama saja
if [[ -n "$stored_number" ]]; then
echo "$stored_number"
return 0
fi
fi
return 1
}
function is_whatsapp_in_github() {
response=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN" "$GITHUB_FILE_URL")
content=$(echo "$response" | jq -r '.content' | base64 --decode)
if [[ "$content" == *"$1"* ]]; then
return 0  # Nomor ditemukan
fi
return 1  # Nomor tidak ditemukan
}
function add_whatsapp_number() {
local whatsapp_number=$1
response=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN" "$GITHUB_FILE_URL")
sha=$(echo "$response" | jq -r '.sha')
content=$(echo "$response" | jq -r '.content' | base64 --decode)
updated_content=$(echo -e "$content\n$whatsapp_number" | base64)
curl -s -X PUT "$GITHUB_FILE_URL" \
-H "Authorization: token $GITHUB_API_TOKEN" \
-H "Content-Type: application/json" \
-d @- <<EOF
{
"message": "Add WhatsApp number: $whatsapp_number",
"content": "$updated_content",
"sha": "$sha"
}
EOF
}
clear
echo -e "${LIGHT_GREEN}  |        _ \     ___|  _ _|    \  | "
echo -e "${LIGHT_GREEN}  |       |   |   |        |      \ | "
echo -e "${LIGHT_GREEN}  |       |   |   |   |    |    |\  | "
echo -e "${LIGHT_GREEN} _____|  \___/   \____|  ___|  _| \_| "
echo -e "${LIGHT_GREEN}                                       "
echo -e "${RESET}"
function ask_for_license() {
ERROR_COUNT=0
while [[ $ERROR_COUNT -lt 3 ]]; do
echo -e "${BOLD}${LIGHT_GREEN}MASUKAN KEY INSTALLER:${RESET}"
read license_input
if [[ "$license_input" == "$VALID_LICENSE" ]]; then
echo "$VALID_LICENSE" > "$LICENSE_FILE"  # Simpan lisensi ke file
echo "0" > "$ERROR_FILE"  # Reset error count
echo -e "${BOLD}${ORANGE}KEY BENAR${RESET}"
return 0
else
ERROR_COUNT=$((ERROR_COUNT + 1))
echo -e "${RED}Key salah! Anda memiliki $((3 - ERROR_COUNT)) kesempatan lagi.${RESET}"
fi
done
echo -e "${RED}Lisensi tidak valid setelah 3 percobaan. Keluar.${RESET}"exit 1
}
if ! is_license_valid; then
ask_for_license
fi
stored_number=$(is_whatsapp_registered)
if [[ $? -eq 0 ]]; then
echo -e "${GREEN}Nomor WhatsApp Anda sudah terdaftar: $stored_number${RESET}"
else
echo -e "${BOLD}${LIGHT_GREEN}MASUKAN NOMOR WHATSAPP ANDA:${RESET}"
read whatsapp_number
if [[ ! "$whatsapp_number" =~ ^[0-9]{10,15}$ ]]; then
echo -e "${RED}Nomor WhatsApp tidak valid. Pastikan hanya angka dan panjang 10-15 karakter.${RESET}"
exit 1
fi
if is_whatsapp_in_github "$whatsapp_number"; then
echo -e "${RED}Nomor WhatsApp ini sudah terdaftar di GitHub. Nomor tidak akan ditambahkan ke GitHub.${RESET}"
else
add_whatsapp_number "$whatsapp_number"
if [[ $? -eq 0 ]]; then
echo -e "${BOLD}${LIGHT_GREEN}NOMOR BERHASIL DITAMBAHKAN${RESET}"
else
echo -e "${RED}Gagal${RESET}"
exit 1
fi
fi
echo "$whatsapp_number" >> "$WHATSAPP_LOG"
chmod 600 "$WHATSAPP_LOG"  # Sembunyikan log agar hanya dapat diakses oleh root
echo -e "${WHITE}NOMOR BERHASIL DITAMBAHKAN${RESET}"
clear
echo -e " _____  _____   ____   _____ ______  _____
|  __ \|  __ \ / __ \ / ____|  ____|/ ____|
| |__) | |__) | |  | | (___ | |__  | (___
|  ___/|  _  /| |  | |\___ \|  __|  \___ \
| |    | | \ \| |__| |____) | |____ ____) |
|_|    |_|  \_\\____/|_____/|______|_____/
" | lolcat
fi
clear
echo -e " _____  _____   ____   _____ ______  _____
|  __ \|  __ \ / __ \ / ____|  ____|/ ____|
| |__) | |__) | |  | | (___ | |__  | (___
|  ___/|  _  /| |  | |\___ \|  __|  \___ \
| |    | | \ \| |__| |____) | |____ ____) |
|_|    |_|  \_\\____/|_____/|______|_____/
" | lolcat
sleep 5
if [[ ! -d "/var/www/pterodactyl" ]]; then
read -p "Apakah anda telah menginstal Panel pterodactyl? (y/n): " answerif [[ "$answer" == "y" ]]; then
while true; do
read -p "Dimanakah file pterodactyl berada (contoh: /path/to/file): " pterodactyl_path
if [[ -d "$pterodactyl_path" ]]; then
cp -rL "$pterodactyl_path" /var/www/pterodactyl_backup
echo "BACKUP BERHASIL" > /dev/null 2>&1
break
else
echo -e "${BOLD}${RED}FILE PTERODACTYL TIDAK BERADA DISANA,COBA LAGI${RESET}"
fi
done
else
echo -e "${BOLD}${RED}BACKUP DIBATALKAN${RESET}"
fi
else
cp -rL /var/www/pterodactyl /var/www/pterodactyl_backup > /dev/null 2>&1echo "Backup berhasil dari /var/www/pterodactyl ke /var/www/pterodactyl_backup" > /dev/null 2>&1
fi
VERIFICATION_FILE="/tmp/verification_status.txt"
generate_code() {
tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6
}
verify_code() {
local generated_code=$1
echo -e -n "${BOLD}${LIGHT_GREEN}MASUKKAN CODE VERIFIKASI: ${RESET}"
read -r user_input
if [[ "$user_input" == "$generated_code" ]]; then
echo -e "${BOLD}${LIGHT_GREEN}VERIFIKASI BERHASIL!!${RESET}"
return 0
else
echo -e "${BOLD}${RED}CODE SALAH, TRY AGAIN!!${RESET}"
return 1
fi
}
verify() {
if [[ -f "$VERIFICATION_FILE" ]]; then
last_verification=$(cat "$VERIFICATION_FILE")
current_time=$(date +%s)
difference=$((current_time - last_verification))
if [[ $difference -lt 86400 ]]; then
echo -e "${BOLD}${LIGHT_GREEN}ANDA TELAH DIVERIFIKASI. TIDAK PERLU VERIFIKASI ULANG.${RESET}"
sleep 1
clear
return 0
fi
fi
code=$(generate_code)
echo -e "══════════════════════════════════════════════
► VERIFIKASI ANTI BOT
> ${BOLD}${LIGHT_GREEN}CODE VERIFIKASI ANDA : $code${RESET}
══════════════════════════════════════════════" | lolcat
until verify_code "$code"; do
echo -e "${BOLD}${RED}CODE SALAH, SILAKAN ULANGI!${RESET}"
done
date +%s > "$VERIFICATION_FILE"
echo -e "${BOLD}${LIGHT_GREEN}ANDA TELAH DIVERIFIKASI${RESET}"
sleep 1
clear
}
opsi() {
echo -e "══════════════════════════════════════════════
____      _    ___ _   _ __  __  ____
|  _ \    / \  |_ _| \ | |  \/  |/ ___|
| |_) |  / _ \  | ||  \| | |\/| | |
|  _ <  / ___ \ | || |\  | |  | | |___
|_| \_\/_/   \_\___|_| \_|_|  |_|\____|
══════════════════════════════════════════════
RAINMC DEVELOPER
WhatsApp: 085263390832
YouTube: RAINMC
══════════════════════════════════════════════
TERIMA KASIH TELAH MELAKUKAN VERIFIKASI!
══════════════════════════════════════════════
► DEPENDENCIES
A. DEPEND FILES
B. DEPEND BLUEPRINT
══════════════════════════════════════════════
► THEME (FILES)
1. INSTALL STELLAR X AUTOSUSPEND
2. INSTALL BILLING MODULE X AUTOSUSPEND
3. INSTALL ENIGMA X AUTOSUSPEND
4. INSTALL NOOK THEME
5. INSTALL NOOBE THEME
6. INSTALL NIGHT CORE THEME
══════════════════════════════════════════════
► ADDON (FILES)
1A. DISPLAY-PASSWORD
══════════════════════════════════════════════
► THEME (BLUEPRINT)
1B. ADMIN PANEL THEME (MYTHICAL UI)
2B. DARKNATE THEME
3B. RECOLOR THEME
══════════════════════════════════════════════
► PTERODACTYL FEATURE
C. CREATE NEW USERS PTERODACTYL VIA VPS
══════════════════════════════════════════════
► OTHER FEATURES
1Q. INSTALL CTRLPANEL PTERODACTYL
2Q. DELETE CTRLPANEL PTERODACTYL
3Q. INSTALL PHPMYADMIN
4Q. DELETE PHPMYADMIN
══════════════════════════════════════════════
► ROLLBACK (FILES)
R. ROLLBACK FILES PTERODACTYL (NO IMPACT ON SERVER DATA)
D. DELETE ALL THEME & ADDONS (NOT RECOMMENDED)
E. EXIT INSTALLER
══════════════════════════════════════════════" | lolcat
echo -e -n "$(echo -e 'PILIH OPSI (1-6): ' | lolcat)"
read OPTION
}
verify
opsi
case "$OPTION" in
1Q)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       VALIDASI DAN PROSES INSTALASI PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 1 "Memeriksa Files CtrlPanel"
if [ "$(ls -A /var/www/ctrlpanel)" ]; then
echo -e "${BOLD}${RED}FILES CTRLPANEL TERDETEKSI, SILAHLAN HAPUS TELEBIH DAHULU SEBELUM MENGINSTAL${RESET}"
exit 1
else
echo -e "${BOLD}${BLUE}FILES TIDAK ADA, PROSES INSTALL...${RESET}"
fi
show_progress 10 "Masukan Subdomain CtrlPanel"
echo -e "${YELLOW}Masukkan nama domain Anda untuk instalasi:${RESET}"
read -p "> " domain
if [[ -z "$domain" ]]; then
error_message "Nama domain tidak boleh kosong! Silakan coba lagi."
fi
sleep 1
show_progress 15 "Memeriksa Os"
if grep -q "Ubuntu 20.04" /etc/os-release || grep -q "Ubuntu 22.04" /etc/os-release; then
echo -e "${GREEN}Sistem operasi kompatibel. Lanjutkan eksekusi skrip.${RESET}"
else
echo -e "${RED}HANYA BISA DIGUNAKAN PADA UBUNTU 22.04 & 20.04!!${RESET}"exit 1
fi
show_progress 20 "Memeriksa Connection Mysql"
mysql_root_password="SAFE"
echo -e "${CYAN}Memeriksa koneksi ke MySQL...${RESET}"
if ! mysql -u root -p"$mysql_root_password" -e "status" >/dev/null 2>&1; then
echo -e "${RED}Gagal terhubung ke MySQL. Pastikan MySQL sedang berjalan dan password root benar.${RESET}"
exit 1
fi
echo -e "${CYAN}Memeriksa database dan user MySQL...${RESET}"
mysql -u root -p"$mysql_root_password" -e "
DROP USER IF EXISTS 'ctrlpaneluser'@'127.0.0.1';
DROP DATABASE IF EXISTS ctrlpanel;
"
if [ $? -eq 0 ]; then
echo -e "${GREEN}User dan database lama berhasil dihapus (jika ada).${RESET}"
else
echo -e "${RED}Gagal memeriksa atau menghapus user/database. Periksa kembali konfigurasi MySQL Anda.${RESET}"
exit 1
fi
show_progress 25 "Menginstall Depend Ctrlpanel"
apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
apt update
apt -y install php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx git
apt -y install php8.3-{intl,redis}
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
mkdir -p /var/www/ctrlpanel && cd /var/www/ctrlpanel
git clone https://github.com/Ctrlpanel-gg/panel.git ./
show_progress 30 "Memeriksa Data Data Mysql"
mysql -u root -p"$mysql_root_password" -e "
DROP USER IF EXISTS 'ctrlpaneluser'@'127.0.0.1';
DROP DATABASE IF EXISTS ctrlpanel;
"
if [ $? -eq 0 ]; then
echo -e "${GREEN}User dan database lama berhasil dihapus (jika ada).${RESET}"
else
echo -e "${RED}Gagal memeriksa atau menghapus user/database. Periksa kembali konfigurasi MySQL Anda.${RESET}"
exit 1
fi
echo -e "${CYAN}Membuat user dan database baru...${RESET}"
mysql -u root -p"$mysql_root_password" -e "
CREATE USER 'ctrlpaneluser'@'127.0.0.1' IDENTIFIED BY 'SAFE';
CREATE DATABASE ctrlpanel;
GRANT ALL PRIVILEGES ON ctrlpanel.* TO 'ctrlpaneluser'@'127.0.0.1';
FLUSH PRIVILEGES;
EXIT
"
if [ $? -eq 0 ]; then
echo -e "${GREEN}User dan database berhasil dibuat.${RESET}"
else
echo -e "${RED}Terjadi kesalahan saat membuat user atau database.${RESET}"
exit 1
fi
show_progress 40 "Menginstall Depend Tambahan"
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
sudo apt update
sudo apt install certbot
sudo apt install python3-certbot-nginx
show_progress 45 "Mengecek Certbot"
if ! command -v certbot &> /dev/null; then
echo -e "\033[1;31mCertbot tidak ditemukan. Pastikan Certbot sudah terinstal.\033[0m"
exit 1
fi
show_progress 50 "Menjalankan Certbot"
echo -e "\033[1;33mMenjalankan Certbot untuk domain: $domain\033[0m"
certbot certonly --nginx -d "$domain"
if [ $? -eq 0 ]; then
echo -e "\033[1;32mSertifikat SSL berhasil dibuat untuk domain $domain.\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat membuat sertifikat SSL untuk domain $domain.\033[0m"
fi
rm /etc/nginx/sites-enabled/default >/dev/null 2>&1
show_progress 55 "Membuat Configurasi Baru Untuk Ctrlpanel"
config_file="/etc/nginx/sites-available/ctrlpanel.conf"
cat > "$config_file" <<EOF
server {
listen 80;
server_name $domain;
return 301 https://\$server_name\$request_uri;
}
server {
listen 443 ssl http2;
server_name $domain;
root /var/www/ctrlpanel/public;
index index.php;
access_log /var/log/nginx/ctrlpanel.app-access.log;
error_log  /var/log/nginx/ctrlpanel.app-error.log error;
client_max_body_size 100m;
client_body_timeout 120s;
sendfile off;
ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
ssl_session_cache shared:SSL:10m;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
ssl_prefer_server_ciphers on;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header X-Robots-Tag none;
add_header Content-Security-Policy "frame-ancestors 'self'";
add_header X-Frame-Options DENY;
add_header Referrer-Policy same-origin;
location / {
try_files \$uri \$uri/ /index.php?\$query_string;
}
location ~ \.php\$ {
fastcgi_split_path_info ^(.+\.php)(/.+)\$;
fastcgi_pass unix:/run/php/php8.3-fpm.sock;
fastcgi_index index.php;
include fastcgi_params;
fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
fastcgi_param HTTP_PROXY "";
fastcgi_intercept_errors off;
fastcgi_buffer_size 16k;
fastcgi_buffers 4 16k;
fastcgi_connect_timeout 300;
fastcgi_send_timeout 300;
fastcgi_read_timeout 300;
include /etc/nginx/fastcgi_params;
}
location ~ /\.ht {
deny all;
}
}
EOF
if [[ $? -eq 0 ]]; then
echo -e "\033[1;32mFile konfigurasi Nginx berhasil dibuat di: $config_file\033[0m"
echo -e "\033[1;33mJangan lupa membuat symlink ke sites-enabled:\033[0m"echo -e "\033[1;33mln -s $config_file /etc/nginx/sites-enabled/\033[0m"
echo -e "\033[1;33mKemudian restart Nginx: systemctl restart nginx\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat membuat file konfigurasi.\033[0m"
exit 1
fi
sudo ln -s /etc/nginx/sites-available/ctrlpanel.conf /etc/nginx/sites-enabled/ctrlpanel.conf
show_progress 56 "Mengecek Configurasi Nginx"
ln -s "$config_file" /etc/nginx/sites-enabled/ctrlpanel.conf
sudo nginx -t || {
echo -e "${RED}Konfigurasi Nginx gagal.Laporkan Kepada RainStoreID${RESET}"
exit 1
}
sudo systemctl restart nginx
sleep 3
show_progress 57 "Mengizinkan File Ctrlpanel"
chown -R www-data:www-data /var/www/ctrlpanel/
chmod -R 755 storage/* bootstrap/cache/
show_progress 58 "Menambahkan Perintah Crontab"
cron_entry="* * * * * php /var/www/ctrlpanel/artisan schedule:run >> /dev/null 2>&1"
if crontab -l | grep -Fxq "$cron_entry"; then
echo -e "\033[1;33mEntri cron sudah ada. Tidak perlu menambahkannya lagi.\033[0m"
else
(crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
if [ $? -eq 0 ]; then
echo -e "\033[1;32mEntri cron berhasil ditambahkan.\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat menambahkan entri cron.\033[0m"
fi
fi
show_progress 70 "Menambahkan Layanan systemd"
service_file="/etc/systemd/system/ctrlpanel.service"
service_content="[Unit]
Description=Ctrlpanel Queue Worker
[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/ctrlpanel/artisan queue:work --sleep=3 --tries=3
StartLimitBurst=0
[Install]
WantedBy=multi-user.target"
if [[ -f "$service_file" ]]; then
echo -e "\033[1;33mFile layanan $service_file sudah ada.\033[0m"
read -p "Apakah Anda ingin menimpa file ini? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
echo -e "\033[1;33mPembuatan layanan dibatalkan.\033[0m"
exit 0
fi
fi
echo "$service_content" > "$service_file"
show_progress 72 "Memberikan Izin"
chmod 644 "$service_file"
show_progress 74 "Restart Daemon"
systemctl daemon-reload
show_progress 76 "Mengaktifkan Layanan CtrlPanel"
systemctl enable ctrlpanel.service
show_progress 78 "Memulai Layanan CtrlPanel"
systemctl start ctrlpanel.service
show_progress 90 "Mengecek Status Layanan"
if systemctl is-active --quiet ctrlpanel.service; then
echo -e "\033[1;32mLayanan ctrlpanel.service berhasil dibuat dan dijalankan.\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat membuat atau menjalankan layanan ctrlpanel.service.\033[0m"
fi
show_progress 100 "Mengaktifkan Kembali CtrlPanel"
sudo systemctl enable --now ctrlpanel.service
echo -e "${BOLD}${LIGHT_GREEN}DONE!!${RESET}"
sleep 4
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © CTRLPANEL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo
echo -e "${YELLOW}Ctrlpanel berhasil diinstal pada domain: ${CYAN}https://$domain${RESET}"
echo -e "${YELLOW}Silakan buka URL tersebut di browser Anda untuk login.${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
2Q)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       PROSES UNINSTALL CTRLPANEL PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 10 "Masukan Subdomain CtrlPanel"
echo -e "${YELLOW}Masukkan Subdomain CtrlPanel Anda:${RESET}"
read -p "> " domain
if [[ -z "$domain" ]]; then
error_message "Nama domain tidak boleh kosong! Silakan coba lagi."
fi
sleep 1
show_progress 50 "Menghapus System - System CtrlPanel"
cd /var/www/ctrlpanel
sudo php artisan down
show_progress 60 "Menghapus Certbot Pada Domain"
if certbot certificates | grep -q "$domain"; then
sudo certbot delete --cert-name "$domain"
echo -e "${BOLD}${LIGHT_GREEN}CERTIFICATE BERHASIL DI HAPUS${RESET}"
else
echo -e "${BOLD}${RED}CERTIFICATE TIDAK DITEMUKAN${RESET}"
fi
show_progress 80 "Menghapus Data - Data CtrlPanel"
sudo systemctl stop ctrlpanel > /dev/null 2>&1
sudo systemctl stop ctrlpanel > /dev/null 2>&1
sudo systemctl disable ctrlpanel > /dev/null 2>&1
sudo rm /etc/systemd/system/ctrlpanel.servic > /dev/null 2>&1
sudo rm -r /etc/nginx/conf.d/ctrlpanel.conf > /dev/null 2&1
sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl reset-failed > /dev/null 2>&1
sudo rm -r /etc/systemd/system/ctrlpanel.service > /dev/null 2>&1
cd /var/www/ && bash -c "$(echo 'ZWNobyBybSAtcg==' | base64 -d | sh -c '$(cat)') ctrlpanel"
* * * * * php /var/www/ctrlpanel/artisan schedule:run >> /dev/null 2>&1
show_progress 100 "Berhasil Menghapus CtrlPanel Pterodactyl"
echo -e "${BOLD}${LIGHT_GREEN}DONE!!${RESET}"
sleep 4
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © CTRLPANEL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${YELLOW}Ctrlpanel berhasil diuninstal pada domain: ${CYAN}https://$domain${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
3Q)
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA="\e[35m"
LIGHT_GREEN='\033[1;32m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
WHITE='\033[1;37m'
RESET='\033[0m'
phpmyadmin_finish(){
clear
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Password: $PHPMYADMIN_PASSWORD
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
}
phpmyadmin_ssl(){
if [ -z "$PHPMYADMIN_EMAIL" ]; then
echo -e "══════════════════════════════════════════════" | lolcat
echo -e "${BOLD}${LIGHT_GREEN}► SILAHKAN MASUKAN EMAIL UNTUK SSL${RESET}"
echo -e "══════════════════════════════════════════════" | lolcat
echo -e -n "${BOLD}${LIGHT_GREEN}> "
read PHPMYADMIN_EMAIL
echo -e "══════════════════════════════════════════════" | lolcat
if [ -z "$PHPMYADMIN_EMAIL" ]; then
echo "Email tidak boleh kosong."
exit 1
fi
fi
certbot certonly --standalone -d $PHPMYADMIN_FQDN --staple-ocsp --no-eff-email -m $PHPMYADMIN_EMAIL --agree-tos
if [ $? -eq 0 ]; then
PHPMYADMIN_SSLSTATUS="Aktif"
phpmyadmin_user
else
phpmyadmin_user
PHPMYADMIN_SSLSTATUS="Gagal"
fi
}
phpmyadminweb(){
apt install mariadb-server -y
PHPMYADMIN_PASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
mariadb -u root -e "CREATE USER '$PHPMYADMIN_USER_LOCAL'@'localhost' IDENTIFIED BY '$PHPMYADMIN_PASSWORD';" && mariadb -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$PHPMYADMIN_USER_LOCAL'@'localhost' WITH GRANT OPTION;"
curl -o /etc/nginx/sites-enabled/phpmyadmin.conf https://raw.githubusercontent.com/guldkage/Pterodactyl-Installer/main/configs/phpmyadmin-ssl.conf
sed -i -e "s@<domain>@${PHPMYADMIN_FQDN}@g" /etc/nginx/sites-enabled/phpmyadmin.conf
systemctl restart nginx
phpmyadmin_finish
}
phpmyadmin_fqdn(){
clear
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
echo -e "${BOLD}${LIGHT_GREEN}► SILAHKAN MASUKAN SUBDOMAIN PHPMYADMIN${RESET}"
echo -e "══════════════════════════════════════════════" | lolcat
echo -e -n "${BOLD}${LIGHT_GREEN}> "
read PHPMYADMIN_FQDN
echo -e "══════════════════════════════════════════════" | lolcat
if [ -z "$PHPMYADMIN_FQDN" ]; then
echo "FQDN tidak boleh kosong."
exit 1
fi
IP=$(dig +short myip.opendns.com @resolver2.opendns.com -4)
DOMAIN=$(dig +short ${PHPMYADMIN_FQDN})
if [ "${IP}" != "${DOMAIN}" ]; then
echo "FQDN Anda tidak mengarah ke IP mesin ini."
sleep 10s
phpmyadmin_ssl
else
phpmyadmin_ssl
fi
}
phpmyadmin_summary(){
clear
echo ""
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
phpmyadmininstall
}
send_phpmyadmin_summary(){
clear
if [ -d "/var/www/phpmyadmin" ]; then
echo -e "${BOLD}${RED}[!] PHP MY ADMIN DI VPS INI SUDAH TERINSTAL${RESET} "
fi
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
}
phpmyadmin_user(){
send_phpmyadmin_summary
echo -e "══════════════════════════════════════════════" | lolcat
echo -e "${BOLD}${LIGHT_GREEN}► SILAHKAN MASUKAN USERNAME UNTUK PHPMYADMIN${RESET}"
echo -e "══════════════════════════════════════════════" | lolcat
echo -e -n "${BOLD}${LIGHT_GREEN}> "
read PHPMYADMIN_USER_LOCAL
echo -e "══════════════════════════════════════════════" | lolcat
phpmyadmin_summary
}
phpmyadmininstall(){
apt update
apt install nginx certbot -y
mkdir /var/www/phpmyadmin && cd /var/www/phpmyadmin
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz
tar xzf phpMyAdmin-5.2.1-all-languages.tar.gz
mv /var/www/phpmyadmin/phpMyAdmin-5.2.1-all-languages/* /var/www/phpmyadmin
chown -R www-data:www-data *
mkdir config
chmod o+rw config
cp config.sample.inc.php config/config.inc.php
chmod o+w config/config.inc.php
rm -rf /var/www/phpmyadmin/config
phpmyadminweb
}
phpmyadmin(){
apt install dnsutils -y
echo ""
echo "${BOLD}${ORANGE}[!] ${LIGHT_GREEN}SETELAH MENGINSTAL DEPEND SAYA MEMBUTUHKAN BEBERAPA INF0RMASI${RRSET} "
sleep 3
phpmyadmin_fqdn
}
phpmyadmin
;;
4Q)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       PROSES UNINSTALL PHPMYADMIN PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 10 "Masukan Subdomain Phpmyadmin"
echo -e "${YELLOW}Masukkan Subdomain Phpmyadmin Anda:${RESET}"
read -p "> " domain
if [[ -z "$domain" ]]; then
error_message "Nama domain tidak boleh kosong! Silakan coba lagi."
fi
sleep 1
show_progress 50 "Menghapus System - System Phpmyadmin"
cd /var/www/ && rm -rf phpmyadmin
rm -r /etc/nginx/sites-enabled/phpmyadmin.conf
show_progress 60 "Menghapus Certbot Pada Domain"
if certbot certificates | grep -q "$domain"; then
sudo certbot delete --cert-name "$domain"
echo -e "${BOLD}${LIGHT_GREEN}CERTIFICATE BERHASIL DI HAPUS${RESET}"
else
echo -e "${BOLD}${RED}CERTIFICATE TIDAK DITEMUKAN${RESET}"
fi
show_progress 100 "Berhasil Menghapus CtrlPanel Pterodactyl"
echo -e "${BOLD}${LIGHT_GREEN}DONE!!${RESET}"
sleep 4
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © PHPMYADMIN CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${YELLOW}Phpmyadminbl berhasil diuninstal pada domain: ${CYAN}https://$domain${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
D)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       VALIDASI DAN PROSES INSTALASI PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 30 "Mengupdate Files Pterodactyl"
cd /var/www/pterodactyl && yes | php artisan p:upgrade
sleep 1
show_progress 100 "Restart Nginx dan Proses Selesai"
sudo systemctl restart nginx
sleep 2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © PTERODACTYL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
R)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       VALIDASI DAN PROSES INSTALASI PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
if [ ! -d "/var/www/pterodactyl_backup" ]; then
clear
echo -e "${RED}Direktori pterodactyl_backup tidak ada! Silakan hubungi Dev.${RESET}"
exit 1
else
echo -e "${BLUE}MEMPROSES...${RESET}"
sleep 2
fi
clear
show_progress 20 "Menghapus Direktori Lama"
cd /var/www/ && rm -r pterodactyl
sleep 1
show_progress 40 "Mengembalikan Direktori Backup"
mv pterodactyl_backup pterodactyl
sleep 1
show_progress 60 "Membuat Salinan Backup Baru"
cd /var/www/pterodactyl && rm -r pterodactyl > /dev/null 2>&1
cp -rL /var/www/pterodactyl /var/www/pterodactyl_backup
sleep 1
show_progress 70 "Mengatur Hak Dan Izin"
sudo chown -R www-data:www-data /var/www/pterodactyl
sudo chmod -R 755 /var/www/pterodactyl
sleep 2
show_progress 80 "Menjalankan Composer untuk Optimasi"
composer install --no-dev --optimize-autoloader --no-interaction > /dev/null 2>&1
sleep 1
show_progress 90 "Membersihkan Cache dan Konfigurasi Laravel"
php artisan cache:clear
php artisan config:cache
php artisan view:clear
sleep 1
show_progress 100 "Restart Nginx dan Proses Selesai"
sudo systemctl restart nginx
sleep 2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © PTERODACTYL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
1)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/stellarrimake.zip" /var/www/
cd /var/www && sudo mv "$TEMP_DIR/autosuspens.zip" /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
unzip -o /var/www/stellarrimake.zip -d /var/www/
unzip -o /var/www/autosuspens.zip -d /var/www/
rm /var/www/stellarrimake.zip
rm /var/www/autosuspens.zip
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
yarn add react-feather
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
yarn add react-feather
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan migrate --force
php artisan view:clear
show_progress 95 "Menginstal Addon Auto Suspend"
cd /var/www/pterodactyl
bash installer.bash
show_progress 100 "Mengunduh File Tambahan dan Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME STELLAR BERHASIL TERINSTAL${RESET}"
echo -e "${GREEN}ADDON AUTO SUSPEND BERHASIL DIINSTALL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
2)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       INSTALASI BILLING MODULE UNTUK PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
clear
echo -e "${RED}��𝗘��𝗘��𝗗 𝗙��𝗟𝗘𝗦 ��𝗘������𝗠 𝗗��𝗜��𝗦𝗧𝗔𝗟${RESET}"
exit 1
fi
show_progress 20 "Memeriksa Node.js dan Yarn"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings > /dev/null 2>&1
echo -e "${BLUE}Direktori /etc/apt/keyrings dibuat.${RESET}"
else
echo -e "${GREEN}Direktori /etc/apt/keyrings sudah ada.${RESET}"
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg > /dev/null 2>&1
echo -e "${BLUE}File nodesource.gpg telah didownload.${RESET}"
else
echo -e "${GREEN}File nodesource.gpg sudah ada.${RESET}"
fi
if dpkg -l | grep -q "nodejs"; then
echo -e "${GREEN}Node.js sudah terinstal.${RESET}"
else
echo -e "${YELLOW}Node.js belum terinstal. Menginstal Node.js...${RESET}"
sudo apt update -y > /dev/null 2>&1 && sudo apt install -y nodejs > /dev/null 2>&1
if [ $? -eq 0 ]; then
echo -e "${GREEN}Node.js berhasil diinstal.${RESET}"
else
echo -e "${RED}Gagal menginstal Node.js.${RESET}"
exit 1
fi
fi
if npm list -g --depth=0 | grep -q "yarn"; then
echo -e "${GREEN}Yarn sudah terinstal.${RESET}"
else
echo -e "${YELLOW}Yarn belum terinstal. Menginstal Yarn...${RESET}"
npm install -g yarn > /dev/null 2>&1
if [ $? -eq 0 ]; then
echo -e "${GREEN}Yarn berhasil diinstal.${RESET}"
else
echo -e "${RED}Gagal menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 40 "Mendownload Billing Module"
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL" > /dev/null 2>&1
cd /var/www && sudo mv "$TEMP_DIR/billmodprem.zip.zip" /var/www/ > /dev/null 2>&1
unzip -o /var/www/billmodprem.zip.zip -d /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" /var/www/billmodprem.zip.zip
show_progress 60 "Mengatur Hak Akses dan Konfigurasi"
cd /var/www/pterodactyl
sudo chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null 2>&1
yarn > /dev/null 2>&1
show_progress 80 "Optimisasi Laravel"
echo "RAIN" | php artisan billing:install stable
sleep 2
show_progress 90 "Membangun Billing Module"
if ! yarn build:production; then
echo -e "${YELLOW}Kelihatannya ada kesalahan. Memulai proses perbaikan...${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn > /dev/null 2>&1
npx update-browserslist-db@latest > /dev/null 2>&1
yarn build:production
fi
sleep 2
show_progress 100 "INSTALASI SELESAI"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}           BILLING MODULE BERHASIL TERINSTAL            ${RESET}"
echo -e "${MAGENTA}               © PTERODACTYL CONFIGURATOR               ${RESET}"
echo -e "${CYAN}============================================================${RESET}";;
A)
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
DESTINATION="/var/www/pterodactyl/installer/logs"
FILE_URL="https://raw.githubusercontent.com/rainmc0123/RainPrem/main/install.sh"
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
clear
show_progress 10 "Memeriksa Files Depend"
cd /var/www
YARN_JS="/var/www/pterodactyl/blueprint.sh"
if [ -f "$YARN_JS" ]; then
echo -e "${BOLD}${ORANGE}DEPEND BLUEPRINT DI HAPUS${RESET}"
rm -r "$YARN_JS"
else
echo -e "${GREEN}PROSES${RESET}"
fi
show_progress 20 "Mengunduh Repository RainPrem"
cd /var/www/pterodactyl && rm - r installer > /dev/null 2>&1
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/yarn-depend.js" /var/www/pterodactyl
cd /var/www/ && rm -r "$TEMP_DIR"
clear
show_progress 40 "Menginstal Node.js dan Yarn"
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
apt install nodejs -y
npm i -g yarn
clear
show_progress 60 "Menginstal NVM dan Node.js v20.18.1"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
source ~/.bashrc
source ~/.profile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 20.18.1
nvm use 20.18.1
node -v
clear
show_progress 80 "Menjalankan Yarn di Direktori Pterodactyl"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BOLD}${BLUE}ADUH ERROR LAGI, AUTO FIX ACTIVE{{RESET}"
sleep 1
clear
show_progress 85 "Memperbaiki Error pada Build Production"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
echo -e "${BOLD}${GREEN}FIX BERHASIL${RESET}"
fi
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}ERROR! SILAHKAN HUBUBGI RAINSTOEEID${RESET}"
exit 1
fi
clear
show_progress 100 "Proses Instalasi Selesai!"
sleep 2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${MAGENTA}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files Depend"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ -f "$YARN_JS" ]; then
echo -e "${BOLD}${ORANGE}FILE DEPEMD YARN DI HAPUS${RESET}"
rm -r "$YARN_JS"
else
echo -e "${GREEN}PROSES${RESET}"
fi
show_progress 10 "Memulai Instalasi Dependensi"
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
npm i -g yarn
show_progress 50 "Menginstal Dependensi Tambahan"
apt install -y zip unzip git curl wget > /dev/null 2>&1
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
mv release.zip /var/www/pterodactyl/release.zip
cd /var/www/pterodactyl
unzip -o release.zip
yarn add react-feather
yarn add cross-env
show_progress 80 "Melakukan Konfigurasi"
WEBUSER="www-data"
USERSHELL="/bin/bash"
PERMISSIONS="www-data:www-data"
sed -i -E -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"$WEBUSER\" #;|g" -e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"$USERSHELL\" #;|g" -e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"$PERMISSIONS\" #;|g" ./blueprint.sh
chmod +x blueprint.sh
show_progress 99 "Memasang Blueprint"
bash blueprint.sh < <(yes "y")
sleep 3
show_progress 100 "Instalasi Selesai!"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
E)
echo -e "${BOLD}${RED}ANDA TELAH KELUAR DARI INSTALLER${RESET}"
exit 1
;;
1B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
cd /var/www
cd /var/www && rm -r RainPrem > /dev/null 2>&1
BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
if [ ! -f "$BLUEPRINT_FILE" ]; then
echo -e "${BOLD}${LIGHT_GREEN}DEPEND BLUEPRINT BELUM DIINSTAL"
exit 1
fi
show_progress 10 "Mengunduh Repository RainPrem..."
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
git clone "$REPO_URL" > /dev/null 2>&1
sudo mv "$TEMP_DIR/mythical_ui.zip" /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" > /dev/null 2>&1
unzip -o /var/www/mythical_ui.zip -d /var/www/ > /dev/null 2>&1
show_progress 80 "Menginstal Mythical UI"
cd /var/www/pterodactyl && echo -e "y" | blueprint -install mythicalui > /dev/null 2>&1
rm /var/www/mythical_ui.zip /var/www/pterodactyl/
show_progress 100 "Instalasi Selesai!"
cd /var/www/pterodactyl && rm -r mythicalui.blueprint
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
2B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
cd /var/www
cd /var/www && rm -r RainPrem > /dev/null 2>&1
BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
if [ ! -f "$BLUEPRINT_FILE" ]; then
echo -e "${BOLD}${LIGHT_GREEN}DEPEND BLUEPRINT BELUM DIINSTAL"
exit 1
fi
show_progress 10 "Mengunduh Repository RainPrem..."
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
git clone "$REPO_URL" > /dev/null 2>&1
sudo mv "$TEMP_DIR/darknate.zip" /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" > /dev/null 2>&1
unzip -o /var/www/darknate.zip -d /var/www/ > /dev/null 2>&1
show_progress 80 "Menginstal Darknate"
cd /var/www/pterodactyl && echo -e "y" | blueprint -install darknate > /dev/null 2>&1
rm /var/www/darknate.zip /var/www/pterodactyl/
show_progress 100 "Instalasi Selesai!"
cd /var/www/pterodactyl && rm -r mythicalui.blueprint
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
3B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
cd /var/www
cd /var/www && rm -r RainPrem > /dev/null 2>&1
BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
if [ ! -f "$BLUEPRINT_FILE" ]; then
echo -e "${BOLD}${LIGHT_GREEN}DEPEND BLUEPRINT BELUM DIINSTAL"
exit 1
fi
show_progress 10 "Mengunduh Repository RainPrem..."
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
git clone "$REPO_URL" > /dev/null 2>&1
sudo mv "$TEMP_DIR/recolor.zip" /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" > /dev/null 2>&1
unzip -o /var/www/recolor.zip -d /var/www/ > /dev/null 2>&1
show_progress 80 "Menginstal Recolor"
cd /var/www/pterodactyl && echo -e "y" | blueprint -install recolor > /dev/null 2>&1
rm /var/www/recolor.zip /var/www/pterodactyl/
show_progress 100 "Instalasi Selesai!"
cd /var/www/pterodactyl && rm -r recolor.blueprint
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
3)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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" # Ganti dengan token Githubmu jika perlu
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/enigmarain.zip" /var/www/
cd /var/www && sudo mv "$TEMP_DIR/autosuspens.zip" /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
unzip -o /var/www/enigmarain.zip -d /var/www/
unzip -o /var/www/autosuspens.zip -d /var/www/
rm /var/www/autosuspens.zip
rm /var/www/enigmarain.zip
show_progress 60 "Menanyakan Nomor Whatsapp"
FILE="/var/www/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx"
OLD_NUMBER="6285263390832"
echo -e -n "${BOLD}${LIGHT_GREEN}MASUKAN NOMOR WHATSAPP ANDA ( EXAMPLE 6285263390832 ) : "
read NEW_NUMBER
if [[ -f "$FILE" ]]; then
sed -i "s/$OLD_NUMBER/$NEW_NUMBER/g" "$FILE"
echo -e "${BOLD}${LIGHT_GREEN}NOMOR BERHASIL DITAMBAHKAN${RESET}"
else
echo -e "${BOLD}${RED}FILE TIDK DITEMUKAN!!${RESET}"
fi
sleep 2
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan migrate --force
php artisan view:clear
show_progress 95 "Menginstal Addon Auto Suspend"
cd /var/www/pterodactyl
bash installer.bash
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME ENIGMA BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
4)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 40 "Mematikan Panel sementara"
cd /var/www/pterodactyl
php artisan down
show_progress 50 "Mengunduh Repository dan File Tambahan"
curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
chmod -R 755 storage/* bootstrap/cache
chmod -R 755 storage/* bootstrap/cache
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
composer install --no-dev --optimize-autoloader --no-interaction > /dev/null 2>&1
php artisan view:clear
php artisan config:clear
php artisan migrate --seed --force
chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null 2>&1
chown -R nginx:nginx /var/www/pterodactyl/* > /dev/null 2>&1
chown -R apache:apache /var/www/pterodactyl/* > /dev/null 2>&1
show progress 98 "Restart Queue"
php artisan queue:restart
show progress 99 "Meng Activekan Kembali Panel Pterodactyl"
php artisan up
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME NOOK BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
5)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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" # Ganti dengan token Githubmu jika perlu
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/noobe.zip" /var/www/
unzip -o /var/www/noobe.zip -d /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
rm /var/www/noobe.zip
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan view:clear
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME NOOBE BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
6)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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" # Ganti dengan token Githubmu jika perlu
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/nightcore.zip" /var/www/
unzip -o /var/www/nightcore.zip -d /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
rm /var/www/nightcore.zip
CSS_FILE="/var/www/pterodactyl/resources/scripts/Pterodactyl_Nightcore_Theme.css"
update_background() {
echo -e -n "${BOLD}${LIGHT_GREEN}LINK BACKROUND: "
read new_background_url
if [[ $new_background_url == https://* ]]; then
sed -i "s|https://raw.githubusercontent.com/NoPro200/Pterodactyl_Nightcore_Theme/main/background.jpg|$new_background_url|g" "$CSS_FILE"
echo -e "${BOLD}${LIGHT_GREEN}BACKROUND TELAH DIUBAH${RESET}"
else
echo -e "${BOLD}${RED}URL YANG DIMASUKAN TIDAK VALID${RESET}"
fi
}
update_logo() {
echo -e -n "${BOLD}${LIGHT_GREEN}LINK LOGO LOGIN: "
read new_logo_url
if [[ $new_logo_url == https://* ]]; then
sed -i "s|https://i.imgur.com/96D5X4d.png|$new_logo_url|g" "$CSS_FILE"
echo -e "${BOLD}${LIGHT_GREEN}LOGO LOGIN TELAH DIUBAH${RESET}"
else
echo -e "${BOLD}${RED}LINK LOGO TIDAK VALID!!${RESET}"
fi
}
show_progress 65 "Backround Dashboard & Login"
echo -e -n "${BOLD}${LIGHT_GREEN}APAKAH ANDA INGIN MENGUBAH BACKROUND? (y/N)${RESET}: "
read change_bg
if [[ $change_bg == "y" || $change_bg == "Y" ]]; then
update_background
else
echo -e "${BOLD}${ORANGE}LOGO BACKROUND TIDAK DIUBAH${RESET}"
fi
show_progress 65 "Logo Login"
echo -e -n "${BOLD}${LIGHT_GREEN}APAKAH ANDA INGIN MENGUBAH LOGO LOGIN (y/N)${RESET}: "
read change_logo
if [[ $change_logo == "y" || $change_logo == "Y" ]]; then
update_logo
else
echo -e "${BOLD}${ORANGE}LOGO LOGIN TIDAK DIUBAH${RESET}"
fi
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan optimize:clear
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME NIGHT CORE BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
C)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}         © CREATE USERS IN INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
PANEL_PATH="/var/www/pterodactyl"
show_progress 50 "Mengisi Data - Data..."
buat_user() {
echo -e "${BOLD}${WHITE}=== CREATE NEW USERS IN PTERODACTYL ===${RESET}"echo -e "${BOLD}${WHITE}SILAHKAN ISI DATA - DATA BERIKUT UNTUK MEMBUAT USERS BARU.${RESET}"
echo -e -n "${BOLD}${LIGHT_GREEN}APAKAH ANDA INGIN USERS INI MENJADI ADMIN? (yes/no) [yes]: "
read is_admin
is_admin=${is_admin:-"yes"}
echo -e -n "${BOLD}${LIGHT_GREEN}EMAIL: "
read email
echo -e -n "${BOLD}${LIGHT_GREEN}NAMA LENGKAP (USERNAME): "
read username
echo -e -n "${BOLD}${LIGHT_GREEN}NAMA DEPAN: "
read first_name
echo -e -n "${BOLD}${LIGHT_GREEN}NAMA BELAKANG: "
read last_name
echo -e -n "${BOLD}${LIGHT_GREEN}PASSWORD: ${RESET}"
read -s password
echo
if [[ "$is_admin" != "yes" ]]; then
is_admin="yes"
fi
show_progress 100 "CREATE SELESAI"
cd "$PANEL_PATH" || { echo -e "${BOLD}${RED}DIREKTORI TIDAK DI TEMUKAN{RESET}"; exit 1; }
echo -e "$is_admin\n$email\n$username\n$first_name\n$last_name\n$password" | php artisan p:user:make > /dev/null 2>&1
echo
echo -e "${BOLD}${LIGHT_GREEN}===NEW USERS BERHASIL DIBUAT===${RESET}"
printf "+-------------------+------+-------------+\n"
printf "| Pertanyaan       | Data                |\n"
printf "+-------------------+------+-------------+\n"
printf "| Admin            | %-18s |\n" "$is_admin"
printf "| Email            | %-18s |\n" "$email"
printf "| Username         | %-18s |\n" "$username"
printf "| Nama Depan       | %-18s |\n" "$first_name"
printf "| Nama Belakang    | %-18s |\n" "$last_name"
printf "| Password         | %-18s |\n" "$password"
printf "+-------------------+--------------------+\n ${RESET}"
sleep 5
exit 1
}
buat_user
;;
1A)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/display-password.zip" /var/www/  >/dev/null 2>&1
unzip -o /var/www/display-password.zip -d /var/www/
rm -r "$TEMP_DIR"  >/dev/null 2>&1
rm /var/www/display-password.zip
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
yarn add react-feather
npx update-browserslist-db@latest
yarn build:production
root@15DAY:/var/freeshell-main# echo

root@15DAY:/var/freeshell-main# bash pm.sh
clear                                                                   loading_bar() {
local duration=$1
local message=$2                                                        local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
echo -n "$message " | lolcat
for ((i = 0; i < duration; i++)); do
for ((j = 0; j < ${#spin}; j++)); do
echo -ne "\r${message} ${spin:$j:1}" | lolcat
sleep 0.05
done
done
echo -e "\r$message ✔" | lolcat                                         }
if [ -d "/var/www/RainPrem" ]; then
loading_bar 2 "MENGHAPUS CACHE"
rm -r /var/www/RainPrem > /dev/null 2>&1
else
clear
loading_bar 1 "LOADING 10%"
fi
if ! command -v jq &> /dev/null; then
loading_bar 2 "MENGINSTALL jq"
apt install jq -y > /dev/null 2>&1
else
clear
loading_bar 1 "LOADING 50%"
fi
if ! command -v lolcat &> /dev/null; then
loading_bar 2 "MENGINSTALL lolcat"
apt install lolcat -y > /dev/null 2>&1
else
clear
loading_bar 1 "LOADING 100%"
fi
echo "SEMUA DEPENDENSI TELAH TERINSTAL!" | lolcat
sleep 2
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA="\e[35m"
LIGHT_GREEN='\033[1;32m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
WHITE='\033[1;37m'
RESET='\033[0m'
trap handle_ctrl_c INT
handle_ctrl_c() {
tput sc
echo -e "${BOLD}${RED}SILAHKAN MEMILIH OPSI E UNTUK KELUAR${RESET}"
sleep 2
tput rc
tput ed
}
VALID_LICENSE="RAIN"
LICENSE_FILE=".license_installer" # Nama file lisensi diubah
ERROR_FILE="/var/error_count.txt"
WHATSAPP_LOG="/var/.whatsapp_logs"  # File log yang disembunyikan
GITHUB_API_TOKEN="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"
GITHUB_FILE_URL="https://api.github.com/repos/SafeStore0000/nowainstallerfree/contents/installer.txt"
function is_license_valid() {
if [[ -f "$LICENSE_FILE" && $(cat "$LICENSE_FILE") == "$VALID_LICENSE" ]]; then
return 0
fi
return 1
}
function is_whatsapp_registered() {
if [[ -f "$WHATSAPP_LOG" ]]; then
local stored_number=$(cat "$WHATSAPP_LOG" | head -n 1)  # Ambil baris pertama saja
if [[ -n "$stored_number" ]]; then
echo "$stored_number"
return 0
fi
fi
return 1
}
function is_whatsapp_in_github() {
response=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN" "$GITHUB_FILE_URL")
content=$(echo "$response" | jq -r '.content' | base64 --decode)
if [[ "$content" == *"$1"* ]]; then
return 0  # Nomor ditemukan
fi
return 1  # Nomor tidak ditemukan
}
function add_whatsapp_number() {
local whatsapp_number=$1
response=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN" "$GITHUB_FILE_URL")
sha=$(echo "$response" | jq -r '.sha')
content=$(echo "$response" | jq -r '.content' | base64 --decode)
updated_content=$(echo -e "$content\n$whatsapp_number" | base64)
curl -s -X PUT "$GITHUB_FILE_URL" \
-H "Authorization: token $GITHUB_API_TOKEN" \
-H "Content-Type: application/json" \
-d @- <<EOF
{
"message": "Add WhatsApp number: $whatsapp_number",
"content": "$updated_content",
"sha": "$sha"
}
EOF
}
clear
echo -e "${LIGHT_GREEN}  |        _ \     ___|  _ _|    \  | "
echo -e "${LIGHT_GREEN}  |       |   |   |        |      \ | "
echo -e "${LIGHT_GREEN}  |       |   |   |   |    |    |\  | "
echo -e "${LIGHT_GREEN} _____|  \___/   \____|  ___|  _| \_| "
echo -e "${LIGHT_GREEN}                                       "
echo -e "${RESET}"
function ask_for_license() {
ERROR_COUNT=0
while [[ $ERROR_COUNT -lt 3 ]]; do
echo -e "${BOLD}${LIGHT_GREEN}MASUKAN KEY INSTALLER:${RESET}"
read license_input
if [[ "$license_input" == "$VALID_LICENSE" ]]; then
echo "$VALID_LICENSE" > "$LICENSE_FILE"  # Simpan lisensi ke file
echo "0" > "$ERROR_FILE"  # Reset error count
echo -e "${BOLD}${ORANGE}KEY BENAR${RESET}"
return 0
else
ERROR_COUNT=$((ERROR_COUNT + 1))
echo -e "${RED}Key salah! Anda memiliki $((3 - ERROR_COUNT)) kesempatan lagi.${RESET}"
fi
done
echo -e "${RED}Lisensi tidak valid setelah 3 percobaan. Keluar.${RESET}"exit 1
}
if ! is_license_valid; then
ask_for_license
fi
stored_number=$(is_whatsapp_registered)
if [[ $? -eq 0 ]]; then
echo -e "${GREEN}Nomor WhatsApp Anda sudah terdaftar: $stored_number${RESET}"
else
echo -e "${BOLD}${LIGHT_GREEN}MASUKAN NOMOR WHATSAPP ANDA:${RESET}"
read whatsapp_number
if [[ ! "$whatsapp_number" =~ ^[0-9]{10,15}$ ]]; then
echo -e "${RED}Nomor WhatsApp tidak valid. Pastikan hanya angka dan panjang 10-15 karakter.${RESET}"
exit 1
fi
if is_whatsapp_in_github "$whatsapp_number"; then
echo -e "${RED}Nomor WhatsApp ini sudah terdaftar di GitHub. Nomor tidak akan ditambahkan ke GitHub.${RESET}"
else
add_whatsapp_number "$whatsapp_number"
if [[ $? -eq 0 ]]; then
echo -e "${BOLD}${LIGHT_GREEN}NOMOR BERHASIL DITAMBAHKAN${RESET}"
else
echo -e "${RED}Gagal${RESET}"
exit 1
fi
fi
echo "$whatsapp_number" >> "$WHATSAPP_LOG"
chmod 600 "$WHATSAPP_LOG"  # Sembunyikan log agar hanya dapat diakses oleh root
echo -e "${WHITE}NOMOR BERHASIL DITAMBAHKAN${RESET}"
clear
echo -e " _____  _____   ____   _____ ______  _____
|  __ \|  __ \ / __ \ / ____|  ____|/ ____|
| |__) | |__) | |  | | (___ | |__  | (___
|  ___/|  _  /| |  | |\___ \|  __|  \___ \
| |    | | \ \| |__| |____) | |____ ____) |
|_|    |_|  \_\\____/|_____/|______|_____/
" | lolcat
fi
clear
echo -e " _____  _____   ____   _____ ______  _____
|  __ \|  __ \ / __ \ / ____|  ____|/ ____|
| |__) | |__) | |  | | (___ | |__  | (___
|  ___/|  _  /| |  | |\___ \|  __|  \___ \
| |    | | \ \| |__| |____) | |____ ____) |
|_|    |_|  \_\\____/|_____/|______|_____/
" | lolcat
sleep 5
if [[ ! -d "/var/www/pterodactyl" ]]; then
read -p "Apakah anda telah menginstal Panel pterodactyl? (y/n): " answerif [[ "$answer" == "y" ]]; then
while true; do
read -p "Dimanakah file pterodactyl berada (contoh: /path/to/file): " pterodactyl_path
if [[ -d "$pterodactyl_path" ]]; then
cp -rL "$pterodactyl_path" /var/www/pterodactyl_backup
echo "BACKUP BERHASIL" > /dev/null 2>&1
break
else
echo -e "${BOLD}${RED}FILE PTERODACTYL TIDAK BERADA DISANA,COBA LAGI${RESET}"
fi
done
else
echo -e "${BOLD}${RED}BACKUP DIBATALKAN${RESET}"
fi
else
cp -rL /var/www/pterodactyl /var/www/pterodactyl_backup > /dev/null 2>&1echo "Backup berhasil dari /var/www/pterodactyl ke /var/www/pterodactyl_backup" > /dev/null 2>&1
fi
VERIFICATION_FILE="/tmp/verification_status.txt"
generate_code() {
tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6
}
verify_code() {
local generated_code=$1
echo -e -n "${BOLD}${LIGHT_GREEN}MASUKKAN CODE VERIFIKASI: ${RESET}"
read -r user_input
if [[ "$user_input" == "$generated_code" ]]; then
echo -e "${BOLD}${LIGHT_GREEN}VERIFIKASI BERHASIL!!${RESET}"
return 0
else
echo -e "${BOLD}${RED}CODE SALAH, TRY AGAIN!!${RESET}"
return 1
fi
}
verify() {
if [[ -f "$VERIFICATION_FILE" ]]; then
last_verification=$(cat "$VERIFICATION_FILE")
current_time=$(date +%s)
difference=$((current_time - last_verification))
if [[ $difference -lt 86400 ]]; then
echo -e "${BOLD}${LIGHT_GREEN}ANDA TELAH DIVERIFIKASI. TIDAK PERLU VERIFIKASI ULANG.${RESET}"
sleep 1
clear
return 0
fi
fi
code=$(generate_code)
echo -e "══════════════════════════════════════════════
► VERIFIKASI ANTI BOT
> ${BOLD}${LIGHT_GREEN}CODE VERIFIKASI ANDA : $code${RESET}
══════════════════════════════════════════════" | lolcat
until verify_code "$code"; do
echo -e "${BOLD}${RED}CODE SALAH, SILAKAN ULANGI!${RESET}"
done
date +%s > "$VERIFICATION_FILE"
echo -e "${BOLD}${LIGHT_GREEN}ANDA TELAH DIVERIFIKASI${RESET}"
sleep 1
clear
}
opsi() {
echo -e "══════════════════════════════════════════════
____      _    ___ _   _ __  __  ____
|  _ \    / \  |_ _| \ | |  \/  |/ ___|
| |_) |  / _ \  | ||  \| | |\/| | |
|  _ <  / ___ \ | || |\  | |  | | |___
|_| \_\/_/   \_\___|_| \_|_|  |_|\____|
══════════════════════════════════════════════
RAINMC DEVELOPER
WhatsApp: 085263390832
YouTube: RAINMC
══════════════════════════════════════════════
TERIMA KASIH TELAH MELAKUKAN VERIFIKASI!
══════════════════════════════════════════════
► DEPENDENCIES
A. DEPEND FILES
B. DEPEND BLUEPRINT
══════════════════════════════════════════════
► THEME (FILES)
1. INSTALL STELLAR X AUTOSUSPEND
2. INSTALL BILLING MODULE X AUTOSUSPEND
3. INSTALL ENIGMA X AUTOSUSPEND
4. INSTALL NOOK THEME
5. INSTALL NOOBE THEME
6. INSTALL NIGHT CORE THEME
══════════════════════════════════════════════
► ADDON (FILES)
1A. DISPLAY-PASSWORD
══════════════════════════════════════════════
► THEME (BLUEPRINT)
1B. ADMIN PANEL THEME (MYTHICAL UI)
2B. DARKNATE THEME
3B. RECOLOR THEME
══════════════════════════════════════════════
► PTERODACTYL FEATURE
C. CREATE NEW USERS PTERODACTYL VIA VPS
══════════════════════════════════════════════
► OTHER FEATURES
1Q. INSTALL CTRLPANEL PTERODACTYL
2Q. DELETE CTRLPANEL PTERODACTYL
3Q. INSTALL PHPMYADMIN
4Q. DELETE PHPMYADMIN
══════════════════════════════════════════════
► ROLLBACK (FILES)
R. ROLLBACK FILES PTERODACTYL (NO IMPACT ON SERVER DATA)
D. DELETE ALL THEME & ADDONS (NOT RECOMMENDED)
E. EXIT INSTALLER
══════════════════════════════════════════════" | lolcat
echo -e -n "$(echo -e 'PILIH OPSI (1-6): ' | lolcat)"
read OPTION
}
verify
opsi
case "$OPTION" in
1Q)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       VALIDASI DAN PROSES INSTALASI PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 1 "Memeriksa Files CtrlPanel"
if [ "$(ls -A /var/www/ctrlpanel)" ]; then
echo -e "${BOLD}${RED}FILES CTRLPANEL TERDETEKSI, SILAHLAN HAPUS TELEBIH DAHULU SEBELUM MENGINSTAL${RESET}"
exit 1
else
echo -e "${BOLD}${BLUE}FILES TIDAK ADA, PROSES INSTALL...${RESET}"
fi
show_progress 10 "Masukan Subdomain CtrlPanel"
echo -e "${YELLOW}Masukkan nama domain Anda untuk instalasi:${RESET}"
read -p "> " domain
if [[ -z "$domain" ]]; then
error_message "Nama domain tidak boleh kosong! Silakan coba lagi."
fi
sleep 1
show_progress 15 "Memeriksa Os"
if grep -q "Ubuntu 20.04" /etc/os-release || grep -q "Ubuntu 22.04" /etc/os-release; then
echo -e "${GREEN}Sistem operasi kompatibel. Lanjutkan eksekusi skrip.${RESET}"
else
echo -e "${RED}HANYA BISA DIGUNAKAN PADA UBUNTU 22.04 & 20.04!!${RESET}"exit 1
fi
show_progress 20 "Memeriksa Connection Mysql"
mysql_root_password="SAFE"
echo -e "${CYAN}Memeriksa koneksi ke MySQL...${RESET}"
if ! mysql -u root -p"$mysql_root_password" -e "status" >/dev/null 2>&1; then
echo -e "${RED}Gagal terhubung ke MySQL. Pastikan MySQL sedang berjalan dan password root benar.${RESET}"
exit 1
fi
echo -e "${CYAN}Memeriksa database dan user MySQL...${RESET}"
mysql -u root -p"$mysql_root_password" -e "
DROP USER IF EXISTS 'ctrlpaneluser'@'127.0.0.1';
DROP DATABASE IF EXISTS ctrlpanel;
"
if [ $? -eq 0 ]; then
echo -e "${GREEN}User dan database lama berhasil dihapus (jika ada).${RESET}"
else
echo -e "${RED}Gagal memeriksa atau menghapus user/database. Periksa kembali konfigurasi MySQL Anda.${RESET}"
exit 1
fi
show_progress 25 "Menginstall Depend Ctrlpanel"
apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
apt update
apt -y install php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx git
apt -y install php8.3-{intl,redis}
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
mkdir -p /var/www/ctrlpanel && cd /var/www/ctrlpanel
git clone https://github.com/Ctrlpanel-gg/panel.git ./
show_progress 30 "Memeriksa Data Data Mysql"
mysql -u root -p"$mysql_root_password" -e "
DROP USER IF EXISTS 'ctrlpaneluser'@'127.0.0.1';
DROP DATABASE IF EXISTS ctrlpanel;
"
if [ $? -eq 0 ]; then
echo -e "${GREEN}User dan database lama berhasil dihapus (jika ada).${RESET}"
else
echo -e "${RED}Gagal memeriksa atau menghapus user/database. Periksa kembali konfigurasi MySQL Anda.${RESET}"
exit 1
fi
echo -e "${CYAN}Membuat user dan database baru...${RESET}"
mysql -u root -p"$mysql_root_password" -e "
CREATE USER 'ctrlpaneluser'@'127.0.0.1' IDENTIFIED BY 'SAFE';
CREATE DATABASE ctrlpanel;
GRANT ALL PRIVILEGES ON ctrlpanel.* TO 'ctrlpaneluser'@'127.0.0.1';
FLUSH PRIVILEGES;
EXIT
"
if [ $? -eq 0 ]; then
echo -e "${GREEN}User dan database berhasil dibuat.${RESET}"
else
echo -e "${RED}Terjadi kesalahan saat membuat user atau database.${RESET}"
exit 1
fi
show_progress 40 "Menginstall Depend Tambahan"
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
sudo apt update
sudo apt install certbot
sudo apt install python3-certbot-nginx
show_progress 45 "Mengecek Certbot"
if ! command -v certbot &> /dev/null; then
echo -e "\033[1;31mCertbot tidak ditemukan. Pastikan Certbot sudah terinstal.\033[0m"
exit 1
fi
show_progress 50 "Menjalankan Certbot"
echo -e "\033[1;33mMenjalankan Certbot untuk domain: $domain\033[0m"
certbot certonly --nginx -d "$domain"
if [ $? -eq 0 ]; then
echo -e "\033[1;32mSertifikat SSL berhasil dibuat untuk domain $domain.\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat membuat sertifikat SSL untuk domain $domain.\033[0m"
fi
rm /etc/nginx/sites-enabled/default >/dev/null 2>&1
show_progress 55 "Membuat Configurasi Baru Untuk Ctrlpanel"
config_file="/etc/nginx/sites-available/ctrlpanel.conf"
cat > "$config_file" <<EOF
server {
listen 80;
server_name $domain;
return 301 https://\$server_name\$request_uri;
}
server {
listen 443 ssl http2;
server_name $domain;
root /var/www/ctrlpanel/public;
index index.php;
access_log /var/log/nginx/ctrlpanel.app-access.log;
error_log  /var/log/nginx/ctrlpanel.app-error.log error;
client_max_body_size 100m;
client_body_timeout 120s;
sendfile off;
ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
ssl_session_cache shared:SSL:10m;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
ssl_prefer_server_ciphers on;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header X-Robots-Tag none;
add_header Content-Security-Policy "frame-ancestors 'self'";
add_header X-Frame-Options DENY;
add_header Referrer-Policy same-origin;
location / {
try_files \$uri \$uri/ /index.php?\$query_string;
}
location ~ \.php\$ {
fastcgi_split_path_info ^(.+\.php)(/.+)\$;
fastcgi_pass unix:/run/php/php8.3-fpm.sock;
fastcgi_index index.php;
include fastcgi_params;
fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
fastcgi_param HTTP_PROXY "";
fastcgi_intercept_errors off;
fastcgi_buffer_size 16k;
fastcgi_buffers 4 16k;
fastcgi_connect_timeout 300;
fastcgi_send_timeout 300;
fastcgi_read_timeout 300;
include /etc/nginx/fastcgi_params;
}
location ~ /\.ht {
deny all;
}
}
EOF
if [[ $? -eq 0 ]]; then
echo -e "\033[1;32mFile konfigurasi Nginx berhasil dibuat di: $config_file\033[0m"
echo -e "\033[1;33mJangan lupa membuat symlink ke sites-enabled:\033[0m"echo -e "\033[1;33mln -s $config_file /etc/nginx/sites-enabled/\033[0m"
echo -e "\033[1;33mKemudian restart Nginx: systemctl restart nginx\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat membuat file konfigurasi.\033[0m"
exit 1
fi
sudo ln -s /etc/nginx/sites-available/ctrlpanel.conf /etc/nginx/sites-enabled/ctrlpanel.conf
show_progress 56 "Mengecek Configurasi Nginx"
ln -s "$config_file" /etc/nginx/sites-enabled/ctrlpanel.conf
sudo nginx -t || {
echo -e "${RED}Konfigurasi Nginx gagal.Laporkan Kepada RainStoreID${RESET}"
exit 1
}
sudo systemctl restart nginx
sleep 3
show_progress 57 "Mengizinkan File Ctrlpanel"
chown -R www-data:www-data /var/www/ctrlpanel/
chmod -R 755 storage/* bootstrap/cache/
show_progress 58 "Menambahkan Perintah Crontab"
cron_entry="* * * * * php /var/www/ctrlpanel/artisan schedule:run >> /dev/null 2>&1"
if crontab -l | grep -Fxq "$cron_entry"; then
echo -e "\033[1;33mEntri cron sudah ada. Tidak perlu menambahkannya lagi.\033[0m"
else
(crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
if [ $? -eq 0 ]; then
echo -e "\033[1;32mEntri cron berhasil ditambahkan.\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat menambahkan entri cron.\033[0m"
fi
fi
show_progress 70 "Menambahkan Layanan systemd"
service_file="/etc/systemd/system/ctrlpanel.service"
service_content="[Unit]
Description=Ctrlpanel Queue Worker
[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/ctrlpanel/artisan queue:work --sleep=3 --tries=3
StartLimitBurst=0
[Install]
WantedBy=multi-user.target"
if [[ -f "$service_file" ]]; then
echo -e "\033[1;33mFile layanan $service_file sudah ada.\033[0m"
read -p "Apakah Anda ingin menimpa file ini? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
echo -e "\033[1;33mPembuatan layanan dibatalkan.\033[0m"
exit 0
fi
fi
echo "$service_content" > "$service_file"
show_progress 72 "Memberikan Izin"
chmod 644 "$service_file"
show_progress 74 "Restart Daemon"
systemctl daemon-reload
show_progress 76 "Mengaktifkan Layanan CtrlPanel"
systemctl enable ctrlpanel.service
show_progress 78 "Memulai Layanan CtrlPanel"
systemctl start ctrlpanel.service
show_progress 90 "Mengecek Status Layanan"
if systemctl is-active --quiet ctrlpanel.service; then
echo -e "\033[1;32mLayanan ctrlpanel.service berhasil dibuat dan dijalankan.\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat membuat atau menjalankan layanan ctrlpanel.service.\033[0m"
fi
show_progress 100 "Mengaktifkan Kembali CtrlPanel"
sudo systemctl enable --now ctrlpanel.service
echo -e "${BOLD}${LIGHT_GREEN}DONE!!${RESET}"
sleep 4
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © CTRLPANEL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo
echo -e "${YELLOW}Ctrlpanel berhasil diinstal pada domain: ${CYAN}https://$domain${RESET}"
echo -e "${YELLOW}Silakan buka URL tersebut di browser Anda untuk login.${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
2Q)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       PROSES UNINSTALL CTRLPANEL PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 10 "Masukan Subdomain CtrlPanel"
echo -e "${YELLOW}Masukkan Subdomain CtrlPanel Anda:${RESET}"
read -p "> " domain
if [[ -z "$domain" ]]; then
error_message "Nama domain tidak boleh kosong! Silakan coba lagi."
fi
sleep 1
show_progress 50 "Menghapus System - System CtrlPanel"
cd /var/www/ctrlpanel
sudo php artisan down
show_progress 60 "Menghapus Certbot Pada Domain"
if certbot certificates | grep -q "$domain"; then
sudo certbot delete --cert-name "$domain"
echo -e "${BOLD}${LIGHT_GREEN}CERTIFICATE BERHASIL DI HAPUS${RESET}"
else
echo -e "${BOLD}${RED}CERTIFICATE TIDAK DITEMUKAN${RESET}"
fi
show_progress 80 "Menghapus Data - Data CtrlPanel"
sudo systemctl stop ctrlpanel > /dev/null 2>&1
sudo systemctl stop ctrlpanel > /dev/null 2>&1
sudo systemctl disable ctrlpanel > /dev/null 2>&1
sudo rm /etc/systemd/system/ctrlpanel.servic > /dev/null 2>&1
sudo rm -r /etc/nginx/conf.d/ctrlpanel.conf > /dev/null 2&1
sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl reset-failed > /dev/null 2>&1
sudo rm -r /etc/systemd/system/ctrlpanel.service > /dev/null 2>&1
cd /var/www/ && bash -c "$(echo 'ZWNobyBybSAtcg==' | base64 -d | sh -c '$(cat)') ctrlpanel"
* * * * * php /var/www/ctrlpanel/artisan schedule:run >> /dev/null 2>&1
show_progress 100 "Berhasil Menghapus CtrlPanel Pterodactyl"
echo -e "${BOLD}${LIGHT_GREEN}DONE!!${RESET}"
sleep 4
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © CTRLPANEL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${YELLOW}Ctrlpanel berhasil diuninstal pada domain: ${CYAN}https://$domain${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
3Q)
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA="\e[35m"
LIGHT_GREEN='\033[1;32m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
WHITE='\033[1;37m'
RESET='\033[0m'
phpmyadmin_finish(){
clear
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Password: $PHPMYADMIN_PASSWORD
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
}
phpmyadmin_ssl(){
if [ -z "$PHPMYADMIN_EMAIL" ]; then
echo -e "══════════════════════════════════════════════" | lolcat
echo -e "${BOLD}${LIGHT_GREEN}► SILAHKAN MASUKAN EMAIL UNTUK SSL${RESET}"
echo -e "══════════════════════════════════════════════" | lolcat
echo -e -n "${BOLD}${LIGHT_GREEN}> "
read PHPMYADMIN_EMAIL
echo -e "══════════════════════════════════════════════" | lolcat
if [ -z "$PHPMYADMIN_EMAIL" ]; then
echo "Email tidak boleh kosong."
exit 1
fi
fi
certbot certonly --standalone -d $PHPMYADMIN_FQDN --staple-ocsp --no-eff-email -m $PHPMYADMIN_EMAIL --agree-tos
if [ $? -eq 0 ]; then
PHPMYADMIN_SSLSTATUS="Aktif"
phpmyadmin_user
else
phpmyadmin_user
PHPMYADMIN_SSLSTATUS="Gagal"
fi
}
phpmyadminweb(){
apt install mariadb-server -y
PHPMYADMIN_PASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
mariadb -u root -e "CREATE USER '$PHPMYADMIN_USER_LOCAL'@'localhost' IDENTIFIED BY '$PHPMYADMIN_PASSWORD';" && mariadb -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$PHPMYADMIN_USER_LOCAL'@'localhost' WITH GRANT OPTION;"
curl -o /etc/nginx/sites-enabled/phpmyadmin.conf https://raw.githubusercontent.com/guldkage/Pterodactyl-Installer/main/configs/phpmyadmin-ssl.conf
sed -i -e "s@<domain>@${PHPMYADMIN_FQDN}@g" /etc/nginx/sites-enabled/phpmyadmin.conf
systemctl restart nginx
phpmyadmin_finish
}
phpmyadmin_fqdn(){
clear
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
echo -e "${BOLD}${LIGHT_GREEN}► SILAHKAN MASUKAN SUBDOMAIN PHPMYADMIN${RESET}"
echo -e "══════════════════════════════════════════════" | lolcat
echo -e -n "${BOLD}${LIGHT_GREEN}> "
read PHPMYADMIN_FQDN
echo -e "══════════════════════════════════════════════" | lolcat
if [ -z "$PHPMYADMIN_FQDN" ]; then
echo "FQDN tidak boleh kosong."
exit 1
fi
IP=$(dig +short myip.opendns.com @resolver2.opendns.com -4)
DOMAIN=$(dig +short ${PHPMYADMIN_FQDN})
if [ "${IP}" != "${DOMAIN}" ]; then
echo "FQDN Anda tidak mengarah ke IP mesin ini."
sleep 10s
phpmyadmin_ssl
else
phpmyadmin_ssl
fi
}
phpmyadmin_summary(){
clear
echo ""
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
phpmyadmininstall
}
send_phpmyadmin_summary(){
clear
if [ -d "/var/www/phpmyadmin" ]; then
echo -e "${BOLD}${RED}[!] PHP MY ADMIN DI VPS INI SUDAH TERINSTAL${RESET} "
fi
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
}
phpmyadmin_user(){
send_phpmyadmin_summary
echo -e "══════════════════════════════════════════════" | lolcat
echo -e "${BOLD}${LIGHT_GREEN}► SILAHKAN MASUKAN USERNAME UNTUK PHPMYADMIN${RESET}"
echo -e "══════════════════════════════════════════════" | lolcat
echo -e -n "${BOLD}${LIGHT_GREEN}> "
read PHPMYADMIN_USER_LOCAL
echo -e "══════════════════════════════════════════════" | lolcat
phpmyadmin_summary
}
phpmyadmininstall(){
apt update
apt install nginx certbot -y
mkdir /var/www/phpmyadmin && cd /var/www/phpmyadmin
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz
tar xzf phpMyAdmin-5.2.1-all-languages.tar.gz
mv /var/www/phpmyadmin/phpMyAdmin-5.2.1-all-languages/* /var/www/phpmyadmin
chown -R www-data:www-data *
mkdir config
chmod o+rw config
cp config.sample.inc.php config/config.inc.php
chmod o+w config/config.inc.php
rm -rf /var/www/phpmyadmin/config
phpmyadminweb
}
phpmyadmin(){
apt install dnsutils -y
echo ""
echo "${BOLD}${ORANGE}[!] ${LIGHT_GREEN}SETELAH MENGINSTAL DEPEND SAYA MEMBUTUHKAN BEBERAPA INF0RMASI${RRSET} "
sleep 3
phpmyadmin_fqdn
}
phpmyadmin
;;
4Q)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       PROSES UNINSTALL PHPMYADMIN PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 10 "Masukan Subdomain Phpmyadmin"
echo -e "${YELLOW}Masukkan Subdomain Phpmyadmin Anda:${RESET}"
read -p "> " domain
if [[ -z "$domain" ]]; then
error_message "Nama domain tidak boleh kosong! Silakan coba lagi."
fi
sleep 1
show_progress 50 "Menghapus System - System Phpmyadmin"
cd /var/www/ && rm -rf phpmyadmin
rm -r /etc/nginx/sites-enabled/phpmyadmin.conf
show_progress 60 "Menghapus Certbot Pada Domain"
if certbot certificates | grep -q "$domain"; then
sudo certbot delete --cert-name "$domain"
echo -e "${BOLD}${LIGHT_GREEN}CERTIFICATE BERHASIL DI HAPUS${RESET}"
else
echo -e "${BOLD}${RED}CERTIFICATE TIDAK DITEMUKAN${RESET}"
fi
show_progress 100 "Berhasil Menghapus CtrlPanel Pterodactyl"
echo -e "${BOLD}${LIGHT_GREEN}DONE!!${RESET}"
sleep 4
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © PHPMYADMIN CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${YELLOW}Phpmyadminbl berhasil diuninstal pada domain: ${CYAN}https://$domain${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
D)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       VALIDASI DAN PROSES INSTALASI PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 30 "Mengupdate Files Pterodactyl"
cd /var/www/pterodactyl && yes | php artisan p:upgrade
sleep 1
show_progress 100 "Restart Nginx dan Proses Selesai"
sudo systemctl restart nginx
sleep 2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © PTERODACTYL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
R)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       VALIDASI DAN PROSES INSTALASI PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
if [ ! -d "/var/www/pterodactyl_backup" ]; then
clear
echo -e "${RED}Direktori pterodactyl_backup tidak ada! Silakan hubungi Dev.${RESET}"
exit 1
else
echo -e "${BLUE}MEMPROSES...${RESET}"
sleep 2
fi
clear
show_progress 20 "Menghapus Direktori Lama"
cd /var/www/ && rm -r pterodactyl
sleep 1
show_progress 40 "Mengembalikan Direktori Backup"
mv pterodactyl_backup pterodactyl
sleep 1
show_progress 60 "Membuat Salinan Backup Baru"
cd /var/www/pterodactyl && rm -r pterodactyl > /dev/null 2>&1
cp -rL /var/www/pterodactyl /var/www/pterodactyl_backup
sleep 1
show_progress 70 "Mengatur Hak Dan Izin"
sudo chown -R www-data:www-data /var/www/pterodactyl
sudo chmod -R 755 /var/www/pterodactyl
sleep 2
show_progress 80 "Menjalankan Composer untuk Optimasi"
composer install --no-dev --optimize-autoloader --no-interaction > /dev/null 2>&1
sleep 1
show_progress 90 "Membersihkan Cache dan Konfigurasi Laravel"
php artisan cache:clear
php artisan config:cache
php artisan view:clear
sleep 1
show_progress 100 "Restart Nginx dan Proses Selesai"
sudo systemctl restart nginx
sleep 2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © PTERODACTYL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
1)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/stellarrimake.zip" /var/www/
cd /var/www && sudo mv "$TEMP_DIR/autosuspens.zip" /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
unzip -o /var/www/stellarrimake.zip -d /var/www/
unzip -o /var/www/autosuspens.zip -d /var/www/
rm /var/www/stellarrimake.zip
rm /var/www/autosuspens.zip
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
yarn add react-feather
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
yarn add react-feather
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan migrate --force
php artisan view:clear
show_progress 95 "Menginstal Addon Auto Suspend"
cd /var/www/pterodactyl
bash installer.bash
show_progress 100 "Mengunduh File Tambahan dan Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME STELLAR BERHASIL TERINSTAL${RESET}"
echo -e "${GREEN}ADDON AUTO SUSPEND BERHASIL DIINSTALL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
2)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       INSTALASI BILLING MODULE UNTUK PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
clear
echo -e "${RED}��𝗘��𝗘��𝗗 𝗙��𝗟𝗘𝗦 ��𝗘������𝗠 𝗗��𝗜��𝗦𝗧𝗔𝗟${RESET}"
exit 1
fi
show_progress 20 "Memeriksa Node.js dan Yarn"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings > /dev/null 2>&1
echo -e "${BLUE}Direktori /etc/apt/keyrings dibuat.${RESET}"
else
echo -e "${GREEN}Direktori /etc/apt/keyrings sudah ada.${RESET}"
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg > /dev/null 2>&1
echo -e "${BLUE}File nodesource.gpg telah didownload.${RESET}"
else
echo -e "${GREEN}File nodesource.gpg sudah ada.${RESET}"
fi
if dpkg -l | grep -q "nodejs"; then
echo -e "${GREEN}Node.js sudah terinstal.${RESET}"
else
echo -e "${YELLOW}Node.js belum terinstal. Menginstal Node.js...${RESET}"
sudo apt update -y > /dev/null 2>&1 && sudo apt install -y nodejs > /dev/null 2>&1
if [ $? -eq 0 ]; then
echo -e "${GREEN}Node.js berhasil diinstal.${RESET}"
else
echo -e "${RED}Gagal menginstal Node.js.${RESET}"
exit 1
fi
fi
if npm list -g --depth=0 | grep -q "yarn"; then
echo -e "${GREEN}Yarn sudah terinstal.${RESET}"
else
echo -e "${YELLOW}Yarn belum terinstal. Menginstal Yarn...${RESET}"
npm install -g yarn > /dev/null 2>&1
if [ $? -eq 0 ]; then
echo -e "${GREEN}Yarn berhasil diinstal.${RESET}"
else
echo -e "${RED}Gagal menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 40 "Mendownload Billing Module"
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL" > /dev/null 2>&1
cd /var/www && sudo mv "$TEMP_DIR/billmodprem.zip.zip" /var/www/ > /dev/null 2>&1
unzip -o /var/www/billmodprem.zip.zip -d /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" /var/www/billmodprem.zip.zip
show_progress 60 "Mengatur Hak Akses dan Konfigurasi"
cd /var/www/pterodactyl
sudo chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null 2>&1
yarn > /dev/null 2>&1
show_progress 80 "Optimisasi Laravel"
echo "RAIN" | php artisan billing:install stable
sleep 2
show_progress 90 "Membangun Billing Module"
if ! yarn build:production; then
echo -e "${YELLOW}Kelihatannya ada kesalahan. Memulai proses perbaikan...${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn > /dev/null 2>&1
npx update-browserslist-db@latest > /dev/null 2>&1
yarn build:production
fi
sleep 2
show_progress 100 "INSTALASI SELESAI"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}           BILLING MODULE BERHASIL TERINSTAL            ${RESET}"
echo -e "${MAGENTA}               © PTERODACTYL CONFIGURATOR               ${RESET}"
echo -e "${CYAN}============================================================${RESET}";;
A)
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
DESTINATION="/var/www/pterodactyl/installer/logs"
FILE_URL="https://raw.githubusercontent.com/rainmc0123/RainPrem/main/install.sh"
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
clear
show_progress 10 "Memeriksa Files Depend"
cd /var/www
YARN_JS="/var/www/pterodactyl/blueprint.sh"
if [ -f "$YARN_JS" ]; then
echo -e "${BOLD}${ORANGE}DEPEND BLUEPRINT DI HAPUS${RESET}"
rm -r "$YARN_JS"
else
echo -e "${GREEN}PROSES${RESET}"
fi
show_progress 20 "Mengunduh Repository RainPrem"
cd /var/www/pterodactyl && rm - r installer > /dev/null 2>&1
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/yarn-depend.js" /var/www/pterodactyl
cd /var/www/ && rm -r "$TEMP_DIR"
clear
show_progress 40 "Menginstal Node.js dan Yarn"
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
apt install nodejs -y
npm i -g yarn
clear
show_progress 60 "Menginstal NVM dan Node.js v20.18.1"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
source ~/.bashrc
source ~/.profile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 20.18.1
nvm use 20.18.1
node -v
clear
show_progress 80 "Menjalankan Yarn di Direktori Pterodactyl"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BOLD}${BLUE}ADUH ERROR LAGI, AUTO FIX ACTIVE{{RESET}"
sleep 1
clear
show_progress 85 "Memperbaiki Error pada Build Production"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
echo -e "${BOLD}${GREEN}FIX BERHASIL${RESET}"
fi
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}ERROR! SILAHKAN HUBUBGI RAINSTOEEID${RESET}"
exit 1
fi
clear
show_progress 100 "Proses Instalasi Selesai!"
sleep 2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${MAGENTA}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files Depend"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ -f "$YARN_JS" ]; then
echo -e "${BOLD}${ORANGE}FILE DEPEMD YARN DI HAPUS${RESET}"
rm -r "$YARN_JS"
else
echo -e "${GREEN}PROSES${RESET}"
fi
show_progress 10 "Memulai Instalasi Dependensi"
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
npm i -g yarn
show_progress 50 "Menginstal Dependensi Tambahan"
apt install -y zip unzip git curl wget > /dev/null 2>&1
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
mv release.zip /var/www/pterodactyl/release.zip
cd /var/www/pterodactyl
unzip -o release.zip
yarn add react-feather
yarn add cross-env
show_progress 80 "Melakukan Konfigurasi"
WEBUSER="www-data"
USERSHELL="/bin/bash"
PERMISSIONS="www-data:www-data"
sed -i -E -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"$WEBUSER\" #;|g" -e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"$USERSHELL\" #;|g" -e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"$PERMISSIONS\" #;|g" ./blueprint.sh
chmod +x blueprint.sh
show_progress 99 "Memasang Blueprint"
bash blueprint.sh < <(yes "y")
sleep 3
show_progress 100 "Instalasi Selesai!"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
E)
echo -e "${BOLD}${RED}ANDA TELAH KELUAR DARI INSTALLER${RESET}"
exit 1
;;
1B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
cd /var/www
cd /var/www && rm -r RainPrem > /dev/null 2>&1
BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
if [ ! -f "$BLUEPRINT_FILE" ]; then
echo -e "${BOLD}${LIGHT_GREEN}DEPEND BLUEPRINT BELUM DIINSTAL"
exit 1
fi
show_progress 10 "Mengunduh Repository RainPrem..."
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
git clone "$REPO_URL" > /dev/null 2>&1
sudo mv "$TEMP_DIR/mythical_ui.zip" /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" > /dev/null 2>&1
unzip -o /var/www/mythical_ui.zip -d /var/www/ > /dev/null 2>&1
show_progress 80 "Menginstal Mythical UI"
cd /var/www/pterodactyl && echo -e "y" | blueprint -install mythicalui > /dev/null 2>&1
rm /var/www/mythical_ui.zip /var/www/pterodactyl/
show_progress 100 "Instalasi Selesai!"
cd /var/www/pterodactyl && rm -r mythicalui.blueprint
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
2B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
cd /var/www
cd /var/www && rm -r RainPrem > /dev/null 2>&1
BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
if [ ! -f "$BLUEPRINT_FILE" ]; then
echo -e "${BOLD}${LIGHT_GREEN}DEPEND BLUEPRINT BELUM DIINSTAL"
exit 1
fi
show_progress 10 "Mengunduh Repository RainPrem..."
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
git clone "$REPO_URL" > /dev/null 2>&1
sudo mv "$TEMP_DIR/darknate.zip" /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" > /dev/null 2>&1
unzip -o /var/www/darknate.zip -d /var/www/ > /dev/null 2>&1
show_progress 80 "Menginstal Darknate"
cd /var/www/pterodactyl && echo -e "y" | blueprint -install darknate > /dev/null 2>&1
rm /var/www/darknate.zip /var/www/pterodactyl/
show_progress 100 "Instalasi Selesai!"
cd /var/www/pterodactyl && rm -r mythicalui.blueprint
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
3B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
cd /var/www
cd /var/www && rm -r RainPrem > /dev/null 2>&1
BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
if [ ! -f "$BLUEPRINT_FILE" ]; then
echo -e "${BOLD}${LIGHT_GREEN}DEPEND BLUEPRINT BELUM DIINSTAL"
exit 1
fi
show_progress 10 "Mengunduh Repository RainPrem..."
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
git clone "$REPO_URL" > /dev/null 2>&1
sudo mv "$TEMP_DIR/recolor.zip" /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" > /dev/null 2>&1
unzip -o /var/www/recolor.zip -d /var/www/ > /dev/null 2>&1
show_progress 80 "Menginstal Recolor"
cd /var/www/pterodactyl && echo -e "y" | blueprint -install recolor > /dev/null 2>&1
rm /var/www/recolor.zip /var/www/pterodactyl/
show_progress 100 "Instalasi Selesai!"
cd /var/www/pterodactyl && rm -r recolor.blueprint
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
3)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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" # Ganti dengan token Githubmu jika perlu
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/enigmarain.zip" /var/www/
cd /var/www && sudo mv "$TEMP_DIR/autosuspens.zip" /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
unzip -o /var/www/enigmarain.zip -d /var/www/
unzip -o /var/www/autosuspens.zip -d /var/www/
rm /var/www/autosuspens.zip
rm /var/www/enigmarain.zip
show_progress 60 "Menanyakan Nomor Whatsapp"
FILE="/var/www/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx"
OLD_NUMBER="6285263390832"
echo -e -n "${BOLD}${LIGHT_GREEN}MASUKAN NOMOR WHATSAPP ANDA ( EXAMPLE 6285263390832 ) : "
read NEW_NUMBER
if [[ -f "$FILE" ]]; then
sed -i "s/$OLD_NUMBER/$NEW_NUMBER/g" "$FILE"
echo -e "${BOLD}${LIGHT_GREEN}NOMOR BERHASIL DITAMBAHKAN${RESET}"
else
echo -e "${BOLD}${RED}FILE TIDK DITEMUKAN!!${RESET}"
fi
sleep 2
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan migrate --force
php artisan view:clear
show_progress 95 "Menginstal Addon Auto Suspend"
cd /var/www/pterodactyl
bash installer.bash
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME ENIGMA BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
4)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 40 "Mematikan Panel sementara"
cd /var/www/pterodactyl
php artisan down
show_progress 50 "Mengunduh Repository dan File Tambahan"
curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
chmod -R 755 storage/* bootstrap/cache
chmod -R 755 storage/* bootstrap/cache
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
composer install --no-dev --optimize-autoloader --no-interaction > /dev/null 2>&1
php artisan view:clear
php artisan config:clear
php artisan migrate --seed --force
chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null 2>&1
chown -R nginx:nginx /var/www/pterodactyl/* > /dev/null 2>&1
chown -R apache:apache /var/www/pterodactyl/* > /dev/null 2>&1
show progress 98 "Restart Queue"
php artisan queue:restart
show progress 99 "Meng Activekan Kembali Panel Pterodactyl"
php artisan up
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME NOOK BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
5)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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" # Ganti dengan token Githubmu jika perlu
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/noobe.zip" /var/www/
unzip -o /var/www/noobe.zip -d /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
rm /var/www/noobe.zip
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan view:clear
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME NOOBE BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
6)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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" # Ganti dengan token Githubmu jika perlu
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/nightcore.zip" /var/www/
unzip -o /var/www/nightcore.zip -d /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
rm /var/www/nightcore.zip
CSS_FILE="/var/www/pterodactyl/resources/scripts/Pterodactyl_Nightcore_Theme.css"
update_background() {
echo -e -n "${BOLD}${LIGHT_GREEN}LINK BACKROUND: "
read new_background_url
if [[ $new_background_url == https://* ]]; then
sed -i "s|https://raw.githubusercontent.com/NoPro200/Pterodactyl_Nightcore_Theme/main/background.jpg|$new_background_url|g" "$CSS_FILE"
echo -e "${BOLD}${LIGHT_GREEN}BACKROUND TELAH DIUBAH${RESET}"
else
echo -e "${BOLD}${RED}URL YANG DIMASUKAN TIDAK VALID${RESET}"
fi
}
update_logo() {
echo -e -n "${BOLD}${LIGHT_GREEN}LINK LOGO LOGIN: "
read new_logo_url
if [[ $new_logo_url == https://* ]]; then
sed -i "s|https://i.imgur.com/96D5X4d.png|$new_logo_url|g" "$CSS_FILE"
echo -e "${BOLD}${LIGHT_GREEN}LOGO LOGIN TELAH DIUBAH${RESET}"
else
echo -e "${BOLD}${RED}LINK LOGO TIDAK VALID!!${RESET}"
fi
}
show_progress 65 "Backround Dashboard & Login"
echo -e -n "${BOLD}${LIGHT_GREEN}APAKAH ANDA INGIN MENGUBAH BACKROUND? (y/N)${RESET}: "
read change_bg
if [[ $change_bg == "y" || $change_bg == "Y" ]]; then
update_background
else
echo -e "${BOLD}${ORANGE}LOGO BACKROUND TIDAK DIUBAH${RESET}"
fi
show_progress 65 "Logo Login"
echo -e -n "${BOLD}${LIGHT_GREEN}APAKAH ANDA INGIN MENGUBAH LOGO LOGIN (y/N)${RESET}: "
read change_logo
if [[ $change_logo == "y" || $change_logo == "Y" ]]; then
update_logo
else
echo -e "${BOLD}${ORANGE}LOGO LOGIN TIDAK DIUBAH${RESET}"
fi
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan optimize:clear
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME NIGHT CORE BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
C)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}         © CREATE USERS IN INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
PANEL_PATH="/var/www/pterodactyl"
show_progress 50 "Mengisi Data - Data..."
buat_user() {
echo -e "${BOLD}${WHITE}=== CREATE NEW USERS IN PTERODACTYL ===${RESET}"echo -e "${BOLD}${WHITE}SILAHKAN ISI DATA - DATA BERIKUT UNTUK MEMBUAT USERS BARU.${RESET}"
echo -e -n "${BOLD}${LIGHT_GREEN}APAKAH ANDA INGIN USERS INI MENJADI ADMIN? (yes/no) [yes]: "
read is_admin
is_admin=${is_admin:-"yes"}
echo -e -n "${BOLD}${LIGHT_GREEN}EMAIL: "
read email
echo -e -n "${BOLD}${LIGHT_GREEN}NAMA LENGKAP (USERNAME): "
read username
echo -e -n "${BOLD}${LIGHT_GREEN}NAMA DEPAN: "
read first_name
echo -e -n "${BOLD}${LIGHT_GREEN}NAMA BELAKANG: "
read last_name
echo -e -n "${BOLD}${LIGHT_GREEN}PASSWORD: ${RESET}"
read -s password
echo
if [[ "$is_admin" != "yes" ]]; then
is_admin="yes"
fi
show_progress 100 "CREATE SELESAI"
cd "$PANEL_PATH" || { echo -e "${BOLD}${RED}DIREKTORI TIDAK DI TEMUKAN{RESET}"; exit 1; }
echo -e "$is_admin\n$email\n$username\n$first_name\n$last_name\n$password" | php artisan p:user:make > /dev/null 2>&1
echo
echo -e "${BOLD}${LIGHT_GREEN}===NEW USERS BERHASIL DIBUAT===${RESET}"
printf "+-------------------+------+-------------+\n"
printf "| Pertanyaan       | Data                |\n"
printf "+-------------------+------+-------------+\n"
printf "| Admin            | %-18s |\n" "$is_admin"
printf "| Email            | %-18s |\n" "$email"
printf "| Username         | %-18s |\n" "$username"
printf "| Nama Depan       | %-18s |\n" "$first_name"
printf "| Nama Belakang    | %-18s |\n" "$last_name"
printf "| Password         | %-18s |\n" "$password"
printf "+-------------------+--------------------+\n ${RESET}"
sleep 5
exit 1
}
buat_user
;;
1A)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/display-password.zip" /var/www/  >/dev/null 2>&1
unzip -o /var/www/display-password.zip -d /var/www/
rm -r "$TEMP_DIR"  >/dev/null 2>&1
rm /var/www/display-password.zip
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
yarn add react-feather
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 100 "Menyelesaikan"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}ADDON DISPLAY PASSWORD BERHASIL DIINSTALL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
esac
  GNU nano 4.8                     wh.sh                      Modified  




  GNU nano 4.8                     wh.sh                      Modified  


























root@15DAY:/var/freeshell-main# bash pm.sh
clear
loading_bar() {
local duration=$1
local message=$2
local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
echo -n "$message " | lolcat
for ((i = 0; i < duration; i++)); do
for ((j = 0; j < ${#spin}; j++)); do
echo -ne "\r${message} ${spin:$j:1}" | lolcat
sleep 0.05
done
done
echo -e "\r$message ✔" | lolcat
}
if [ -d "/var/www/RainPrem" ]; then
loading_bar 2 "MENGHAPUS CACHE"
rm -r /var/www/RainPrem > /dev/null 2>&1
else
clear
loading_bar 1 "LOADING 10%"
fi
if ! command -v jq &> /dev/null; then
loading_bar 2 "MENGINSTALL jq"
apt install jq -y > /dev/null 2>&1
else
clear
loading_bar 1 "LOADING 50%"
fi
if ! command -v lolcat &> /dev/null; then
loading_bar 2 "MENGINSTALL lolcat"
apt install lolcat -y > /dev/null 2>&1
else
clear
loading_bar 1 "LOADING 100%"
fi
echo "SEMUA DEPENDENSI TELAH TERINSTAL!" | lolcat
sleep 2
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA="\e[35m"
LIGHT_GREEN='\033[1;32m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
WHITE='\033[1;37m'
RESET='\033[0m'
trap handle_ctrl_c INT
handle_ctrl_c() {
tput sc
echo -e "${BOLD}${RED}SILAHKAN MEMILIH OPSI E UNTUK KELUAR${RESET}"
sleep 2
tput rc
tput ed
}
VALID_LICENSE="RAIN"
LICENSE_FILE=".license_installer" # Nama file lisensi diubah
ERROR_FILE="/var/error_count.txt"
WHATSAPP_LOG="/var/.whatsapp_logs"  # File log yang disembunyikan
GITHUB_API_TOKEN="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"
GITHUB_FILE_URL="https://api.github.com/repos/SafeStore0000/nowainstallerfree/contents/installer.txt"
function is_license_valid() {
if [[ -f "$LICENSE_FILE" && $(cat "$LICENSE_FILE") == "$VALID_LICENSE" ]]; then
return 0
fi
return 1
}
function is_whatsapp_registered() {
if [[ -f "$WHATSAPP_LOG" ]]; then
local stored_number=$(cat "$WHATSAPP_LOG" | head -n 1)  # Ambil baris pertama saja
if [[ -n "$stored_number" ]]; then
echo "$stored_number"
return 0
fi
fi
return 1
}
function is_whatsapp_in_github() {
response=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN" "$GITHUB_FILE_URL")
content=$(echo "$response" | jq -r '.content' | base64 --decode)
if [[ "$content" == *"$1"* ]]; then
return 0  # Nomor ditemukan
fi
return 1  # Nomor tidak ditemukan
}
function add_whatsapp_number() {
local whatsapp_number=$1
response=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN" "$GITHUB_FILE_URL")
sha=$(echo "$response" | jq -r '.sha')
content=$(echo "$response" | jq -r '.content' | base64 --decode)
updated_content=$(echo -e "$content\n$whatsapp_number" | base64)
curl -s -X PUT "$GITHUB_FILE_URL" \
-H "Authorization: token $GITHUB_API_TOKEN" \
-H "Content-Type: application/json" \
-d @- <<EOF
{
"message": "Add WhatsApp number: $whatsapp_number",
"content": "$updated_content",
"sha": "$sha"
}
EOF
}
clear
echo -e "${LIGHT_GREEN}  |        _ \     ___|  _ _|    \  | "
echo -e "${LIGHT_GREEN}  |       |   |   |        |      \ | "
echo -e "${LIGHT_GREEN}  |       |   |   |   |    |    |\  | "
echo -e "${LIGHT_GREEN} _____|  \___/   \____|  ___|  _| \_| "
echo -e "${LIGHT_GREEN}                                       "
echo -e "${RESET}"
function ask_for_license() {
ERROR_COUNT=0
while [[ $ERROR_COUNT -lt 3 ]]; do
echo -e "${BOLD}${LIGHT_GREEN}MASUKAN KEY INSTALLER:${RESET}"
read license_input
if [[ "$license_input" == "$VALID_LICENSE" ]]; then
echo "$VALID_LICENSE" > "$LICENSE_FILE"  # Simpan lisensi ke file
echo "0" > "$ERROR_FILE"  # Reset error count
echo -e "${BOLD}${ORANGE}KEY BENAR${RESET}"
return 0
else
ERROR_COUNT=$((ERROR_COUNT + 1))
echo -e "${RED}Key salah! Anda memiliki $((3 - ERROR_COUNT)) kesempatan lagi.${RESET}"
fi
done
echo -e "${RED}Lisensi tidak valid setelah 3 percobaan. Keluar.${RESET}"exit 1
}
if ! is_license_valid; then
ask_for_license
fi
stored_number=$(is_whatsapp_registered)
if [[ $? -eq 0 ]]; then
echo -e "${GREEN}Nomor WhatsApp Anda sudah terdaftar: $stored_number${RESET}"
else
echo -e "${BOLD}${LIGHT_GREEN}MASUKAN NOMOR WHATSAPP ANDA:${RESET}"
read whatsapp_number
if [[ ! "$whatsapp_number" =~ ^[0-9]{10,15}$ ]]; then
echo -e "${RED}Nomor WhatsApp tidak valid. Pastikan hanya angka dan panjang 10-15 karakter.${RESET}"
exit 1
fi
if is_whatsapp_in_github "$whatsapp_number"; then
echo -e "${RED}Nomor WhatsApp ini sudah terdaftar di GitHub. Nomor tidak akan ditambahkan ke GitHub.${RESET}"
else
add_whatsapp_number "$whatsapp_number"
if [[ $? -eq 0 ]]; then
echo -e "${BOLD}${LIGHT_GREEN}NOMOR BERHASIL DITAMBAHKAN${RESET}"
else
echo -e "${RED}Gagal${RESET}"
exit 1
fi
fi
echo "$whatsapp_number" >> "$WHATSAPP_LOG"
chmod 600 "$WHATSAPP_LOG"  # Sembunyikan log agar hanya dapat diakses oleh root
echo -e "${WHITE}NOMOR BERHASIL DITAMBAHKAN${RESET}"
clear
echo -e " _____  _____   ____   _____ ______  _____
|  __ \|  __ \ / __ \ / ____|  ____|/ ____|
| |__) | |__) | |  | | (___ | |__  | (___
|  ___/|  _  /| |  | |\___ \|  __|  \___ \
| |    | | \ \| |__| |____) | |____ ____) |
|_|    |_|  \_\\____/|_____/|______|_____/
" | lolcat
fi
clear
echo -e " _____  _____   ____   _____ ______  _____
|  __ \|  __ \ / __ \ / ____|  ____|/ ____|
| |__) | |__) | |  | | (___ | |__  | (___
|  ___/|  _  /| |  | |\___ \|  __|  \___ \
| |    | | \ \| |__| |____) | |____ ____) |
|_|    |_|  \_\\____/|_____/|______|_____/
" | lolcat
sleep 5
if [[ ! -d "/var/www/pterodactyl" ]]; then
read -p "Apakah anda telah menginstal Panel pterodactyl? (y/n): " answerif [[ "$answer" == "y" ]]; then
while true; do
read -p "Dimanakah file pterodactyl berada (contoh: /path/to/file): " pterodactyl_path
if [[ -d "$pterodactyl_path" ]]; then
cp -rL "$pterodactyl_path" /var/www/pterodactyl_backup
echo "BACKUP BERHASIL" > /dev/null 2>&1
break
else
echo -e "${BOLD}${RED}FILE PTERODACTYL TIDAK BERADA DISANA,COBA LAGI${RESET}"
fi
done
else
echo -e "${BOLD}${RED}BACKUP DIBATALKAN${RESET}"
fi
else
cp -rL /var/www/pterodactyl /var/www/pterodactyl_backup > /dev/null 2>&1echo "Backup berhasil dari /var/www/pterodactyl ke /var/www/pterodactyl_backup" > /dev/null 2>&1
fi
VERIFICATION_FILE="/tmp/verification_status.txt"
generate_code() {
tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6
}
verify_code() {
local generated_code=$1
echo -e -n "${BOLD}${LIGHT_GREEN}MASUKKAN CODE VERIFIKASI: ${RESET}"
read -r user_input
if [[ "$user_input" == "$generated_code" ]]; then
echo -e "${BOLD}${LIGHT_GREEN}VERIFIKASI BERHASIL!!${RESET}"
return 0
else
echo -e "${BOLD}${RED}CODE SALAH, TRY AGAIN!!${RESET}"
return 1
fi
}
verify() {
if [[ -f "$VERIFICATION_FILE" ]]; then
last_verification=$(cat "$VERIFICATION_FILE")
current_time=$(date +%s)
difference=$((current_time - last_verification))
if [[ $difference -lt 86400 ]]; then
echo -e "${BOLD}${LIGHT_GREEN}ANDA TELAH DIVERIFIKASI. TIDAK PERLU VERIFIKASI ULANG.${RESET}"
sleep 1
clear
return 0
fi
fi
code=$(generate_code)
echo -e "══════════════════════════════════════════════
► VERIFIKASI ANTI BOT
> ${BOLD}${LIGHT_GREEN}CODE VERIFIKASI ANDA : $code${RESET}
══════════════════════════════════════════════" | lolcat
until verify_code "$code"; do
echo -e "${BOLD}${RED}CODE SALAH, SILAKAN ULANGI!${RESET}"
done
date +%s > "$VERIFICATION_FILE"
echo -e "${BOLD}${LIGHT_GREEN}ANDA TELAH DIVERIFIKASI${RESET}"
sleep 1
clear
}
opsi() {
echo -e "══════════════════════════════════════════════
____      _    ___ _   _ __  __  ____
|  _ \    / \  |_ _| \ | |  \/  |/ ___|
| |_) |  / _ \  | ||  \| | |\/| | |
|  _ <  / ___ \ | || |\  | |  | | |___
|_| \_\/_/   \_\___|_| \_|_|  |_|\____|
══════════════════════════════════════════════
RAINMC DEVELOPER
WhatsApp: 085263390832
YouTube: RAINMC
══════════════════════════════════════════════
TERIMA KASIH TELAH MELAKUKAN VERIFIKASI!
══════════════════════════════════════════════
► DEPENDENCIES
A. DEPEND FILES
B. DEPEND BLUEPRINT
══════════════════════════════════════════════
► THEME (FILES)
1. INSTALL STELLAR X AUTOSUSPEND
2. INSTALL BILLING MODULE X AUTOSUSPEND
3. INSTALL ENIGMA X AUTOSUSPEND
4. INSTALL NOOK THEME
5. INSTALL NOOBE THEME
6. INSTALL NIGHT CORE THEME
══════════════════════════════════════════════
► ADDON (FILES)
1A. DISPLAY-PASSWORD
══════════════════════════════════════════════
► THEME (BLUEPRINT)
1B. ADMIN PANEL THEME (MYTHICAL UI)
2B. DARKNATE THEME
3B. RECOLOR THEME
══════════════════════════════════════════════
► PTERODACTYL FEATURE
C. CREATE NEW USERS PTERODACTYL VIA VPS
══════════════════════════════════════════════
► OTHER FEATURES
1Q. INSTALL CTRLPANEL PTERODACTYL
2Q. DELETE CTRLPANEL PTERODACTYL
3Q. INSTALL PHPMYADMIN
4Q. DELETE PHPMYADMIN
══════════════════════════════════════════════
► ROLLBACK (FILES)
R. ROLLBACK FILES PTERODACTYL (NO IMPACT ON SERVER DATA)
D. DELETE ALL THEME & ADDONS (NOT RECOMMENDED)
E. EXIT INSTALLER
══════════════════════════════════════════════" | lolcat
echo -e -n "$(echo -e 'PILIH OPSI (1-6): ' | lolcat)"
read OPTION
}
verify
opsi
case "$OPTION" in
1Q)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       VALIDASI DAN PROSES INSTALASI PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 1 "Memeriksa Files CtrlPanel"
if [ "$(ls -A /var/www/ctrlpanel)" ]; then
echo -e "${BOLD}${RED}FILES CTRLPANEL TERDETEKSI, SILAHLAN HAPUS TELEBIH DAHULU SEBELUM MENGINSTAL${RESET}"
exit 1
else
echo -e "${BOLD}${BLUE}FILES TIDAK ADA, PROSES INSTALL...${RESET}"
fi
show_progress 10 "Masukan Subdomain CtrlPanel"
echo -e "${YELLOW}Masukkan nama domain Anda untuk instalasi:${RESET}"
read -p "> " domain
if [[ -z "$domain" ]]; then
error_message "Nama domain tidak boleh kosong! Silakan coba lagi."
fi
sleep 1
show_progress 15 "Memeriksa Os"
if grep -q "Ubuntu 20.04" /etc/os-release || grep -q "Ubuntu 22.04" /etc/os-release; then
echo -e "${GREEN}Sistem operasi kompatibel. Lanjutkan eksekusi skrip.${RESET}"
else
echo -e "${RED}HANYA BISA DIGUNAKAN PADA UBUNTU 22.04 & 20.04!!${RESET}"exit 1
fi
show_progress 20 "Memeriksa Connection Mysql"
mysql_root_password="SAFE"
echo -e "${CYAN}Memeriksa koneksi ke MySQL...${RESET}"
if ! mysql -u root -p"$mysql_root_password" -e "status" >/dev/null 2>&1; then
echo -e "${RED}Gagal terhubung ke MySQL. Pastikan MySQL sedang berjalan dan password root benar.${RESET}"
exit 1
fi
echo -e "${CYAN}Memeriksa database dan user MySQL...${RESET}"
mysql -u root -p"$mysql_root_password" -e "
DROP USER IF EXISTS 'ctrlpaneluser'@'127.0.0.1';
DROP DATABASE IF EXISTS ctrlpanel;
"
if [ $? -eq 0 ]; then
echo -e "${GREEN}User dan database lama berhasil dihapus (jika ada).${RESET}"
else
echo -e "${RED}Gagal memeriksa atau menghapus user/database. Periksa kembali konfigurasi MySQL Anda.${RESET}"
exit 1
fi
show_progress 25 "Menginstall Depend Ctrlpanel"
apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
apt update
apt -y install php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx git
apt -y install php8.3-{intl,redis}
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
mkdir -p /var/www/ctrlpanel && cd /var/www/ctrlpanel
git clone https://github.com/Ctrlpanel-gg/panel.git ./
show_progress 30 "Memeriksa Data Data Mysql"
mysql -u root -p"$mysql_root_password" -e "
DROP USER IF EXISTS 'ctrlpaneluser'@'127.0.0.1';
DROP DATABASE IF EXISTS ctrlpanel;
"
if [ $? -eq 0 ]; then
echo -e "${GREEN}User dan database lama berhasil dihapus (jika ada).${RESET}"
else
echo -e "${RED}Gagal memeriksa atau menghapus user/database. Periksa kembali konfigurasi MySQL Anda.${RESET}"
exit 1
fi
echo -e "${CYAN}Membuat user dan database baru...${RESET}"
mysql -u root -p"$mysql_root_password" -e "
CREATE USER 'ctrlpaneluser'@'127.0.0.1' IDENTIFIED BY 'SAFE';
CREATE DATABASE ctrlpanel;
GRANT ALL PRIVILEGES ON ctrlpanel.* TO 'ctrlpaneluser'@'127.0.0.1';
FLUSH PRIVILEGES;
EXIT
"
if [ $? -eq 0 ]; then
echo -e "${GREEN}User dan database berhasil dibuat.${RESET}"
else
echo -e "${RED}Terjadi kesalahan saat membuat user atau database.${RESET}"
exit 1
fi
show_progress 40 "Menginstall Depend Tambahan"
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
sudo apt update
sudo apt install certbot
sudo apt install python3-certbot-nginx
show_progress 45 "Mengecek Certbot"
if ! command -v certbot &> /dev/null; then
echo -e "\033[1;31mCertbot tidak ditemukan. Pastikan Certbot sudah terinstal.\033[0m"
exit 1
fi
show_progress 50 "Menjalankan Certbot"
echo -e "\033[1;33mMenjalankan Certbot untuk domain: $domain\033[0m"
certbot certonly --nginx -d "$domain"
if [ $? -eq 0 ]; then
echo -e "\033[1;32mSertifikat SSL berhasil dibuat untuk domain $domain.\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat membuat sertifikat SSL untuk domain $domain.\033[0m"
fi
rm /etc/nginx/sites-enabled/default >/dev/null 2>&1
show_progress 55 "Membuat Configurasi Baru Untuk Ctrlpanel"
config_file="/etc/nginx/sites-available/ctrlpanel.conf"
cat > "$config_file" <<EOF
server {
listen 80;
server_name $domain;
return 301 https://\$server_name\$request_uri;
}
server {
listen 443 ssl http2;
server_name $domain;
root /var/www/ctrlpanel/public;
index index.php;
access_log /var/log/nginx/ctrlpanel.app-access.log;
error_log  /var/log/nginx/ctrlpanel.app-error.log error;
client_max_body_size 100m;
client_body_timeout 120s;
sendfile off;
ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
ssl_session_cache shared:SSL:10m;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
ssl_prefer_server_ciphers on;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header X-Robots-Tag none;
add_header Content-Security-Policy "frame-ancestors 'self'";
add_header X-Frame-Options DENY;
add_header Referrer-Policy same-origin;
location / {
try_files \$uri \$uri/ /index.php?\$query_string;
}
location ~ \.php\$ {
fastcgi_split_path_info ^(.+\.php)(/.+)\$;
fastcgi_pass unix:/run/php/php8.3-fpm.sock;
fastcgi_index index.php;
include fastcgi_params;
fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
fastcgi_param HTTP_PROXY "";
fastcgi_intercept_errors off;
fastcgi_buffer_size 16k;
fastcgi_buffers 4 16k;
fastcgi_connect_timeout 300;
fastcgi_send_timeout 300;
fastcgi_read_timeout 300;
include /etc/nginx/fastcgi_params;
}
location ~ /\.ht {
deny all;
}
}
EOF
if [[ $? -eq 0 ]]; then
echo -e "\033[1;32mFile konfigurasi Nginx berhasil dibuat di: $config_file\033[0m"
echo -e "\033[1;33mJangan lupa membuat symlink ke sites-enabled:\033[0m"echo -e "\033[1;33mln -s $config_file /etc/nginx/sites-enabled/\033[0m"
echo -e "\033[1;33mKemudian restart Nginx: systemctl restart nginx\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat membuat file konfigurasi.\033[0m"
exit 1
fi
sudo ln -s /etc/nginx/sites-available/ctrlpanel.conf /etc/nginx/sites-enabled/ctrlpanel.conf
show_progress 56 "Mengecek Configurasi Nginx"
ln -s "$config_file" /etc/nginx/sites-enabled/ctrlpanel.conf
sudo nginx -t || {
echo -e "${RED}Konfigurasi Nginx gagal.Laporkan Kepada RainStoreID${RESET}"
exit 1
}
sudo systemctl restart nginx
sleep 3
show_progress 57 "Mengizinkan File Ctrlpanel"
chown -R www-data:www-data /var/www/ctrlpanel/
chmod -R 755 storage/* bootstrap/cache/
show_progress 58 "Menambahkan Perintah Crontab"
cron_entry="* * * * * php /var/www/ctrlpanel/artisan schedule:run >> /dev/null 2>&1"
if crontab -l | grep -Fxq "$cron_entry"; then
echo -e "\033[1;33mEntri cron sudah ada. Tidak perlu menambahkannya lagi.\033[0m"
else
(crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
if [ $? -eq 0 ]; then
echo -e "\033[1;32mEntri cron berhasil ditambahkan.\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat menambahkan entri cron.\033[0m"
fi
fi
show_progress 70 "Menambahkan Layanan systemd"
service_file="/etc/systemd/system/ctrlpanel.service"
service_content="[Unit]
Description=Ctrlpanel Queue Worker
[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/ctrlpanel/artisan queue:work --sleep=3 --tries=3
StartLimitBurst=0
[Install]
WantedBy=multi-user.target"
if [[ -f "$service_file" ]]; then
echo -e "\033[1;33mFile layanan $service_file sudah ada.\033[0m"
read -p "Apakah Anda ingin menimpa file ini? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
echo -e "\033[1;33mPembuatan layanan dibatalkan.\033[0m"
exit 0
fi
fi
echo "$service_content" > "$service_file"
show_progress 72 "Memberikan Izin"
chmod 644 "$service_file"
show_progress 74 "Restart Daemon"
systemctl daemon-reload
show_progress 76 "Mengaktifkan Layanan CtrlPanel"
systemctl enable ctrlpanel.service
show_progress 78 "Memulai Layanan CtrlPanel"
systemctl start ctrlpanel.service
show_progress 90 "Mengecek Status Layanan"
if systemctl is-active --quiet ctrlpanel.service; then
echo -e "\033[1;32mLayanan ctrlpanel.service berhasil dibuat dan dijalankan.\033[0m"
else
echo -e "\033[1;31mTerjadi kesalahan saat membuat atau menjalankan layanan ctrlpanel.service.\033[0m"
fi
show_progress 100 "Mengaktifkan Kembali CtrlPanel"
sudo systemctl enable --now ctrlpanel.service
echo -e "${BOLD}${LIGHT_GREEN}DONE!!${RESET}"
sleep 4
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © CTRLPANEL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo
echo -e "${YELLOW}Ctrlpanel berhasil diinstal pada domain: ${CYAN}https://$domain${RESET}"
echo -e "${YELLOW}Silakan buka URL tersebut di browser Anda untuk login.${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
2Q)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       PROSES UNINSTALL CTRLPANEL PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 10 "Masukan Subdomain CtrlPanel"
echo -e "${YELLOW}Masukkan Subdomain CtrlPanel Anda:${RESET}"
read -p "> " domain
if [[ -z "$domain" ]]; then
error_message "Nama domain tidak boleh kosong! Silakan coba lagi."
fi
sleep 1
show_progress 50 "Menghapus System - System CtrlPanel"
cd /var/www/ctrlpanel
sudo php artisan down
show_progress 60 "Menghapus Certbot Pada Domain"
if certbot certificates | grep -q "$domain"; then
sudo certbot delete --cert-name "$domain"
echo -e "${BOLD}${LIGHT_GREEN}CERTIFICATE BERHASIL DI HAPUS${RESET}"
else
echo -e "${BOLD}${RED}CERTIFICATE TIDAK DITEMUKAN${RESET}"
fi
show_progress 80 "Menghapus Data - Data CtrlPanel"
sudo systemctl stop ctrlpanel > /dev/null 2>&1
sudo systemctl stop ctrlpanel > /dev/null 2>&1
sudo systemctl disable ctrlpanel > /dev/null 2>&1
sudo rm /etc/systemd/system/ctrlpanel.servic > /dev/null 2>&1
sudo rm -r /etc/nginx/conf.d/ctrlpanel.conf > /dev/null 2&1
sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl reset-failed > /dev/null 2>&1
sudo rm -r /etc/systemd/system/ctrlpanel.service > /dev/null 2>&1
cd /var/www/ && bash -c "$(echo 'ZWNobyBybSAtcg==' | base64 -d | sh -c '$(cat)') ctrlpanel"
* * * * * php /var/www/ctrlpanel/artisan schedule:run >> /dev/null 2>&1
show_progress 100 "Berhasil Menghapus CtrlPanel Pterodactyl"
echo -e "${BOLD}${LIGHT_GREEN}DONE!!${RESET}"
sleep 4
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © CTRLPANEL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${YELLOW}Ctrlpanel berhasil diuninstal pada domain: ${CYAN}https://$domain${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
3Q)
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA="\e[35m"
LIGHT_GREEN='\033[1;32m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
WHITE='\033[1;37m'
RESET='\033[0m'
phpmyadmin_finish(){
clear
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Password: $PHPMYADMIN_PASSWORD
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
}
phpmyadmin_ssl(){
if [ -z "$PHPMYADMIN_EMAIL" ]; then
echo -e "══════════════════════════════════════════════" | lolcat
echo -e "${BOLD}${LIGHT_GREEN}► SILAHKAN MASUKAN EMAIL UNTUK SSL${RESET}"
echo -e "══════════════════════════════════════════════" | lolcat
echo -e -n "${BOLD}${LIGHT_GREEN}> "
read PHPMYADMIN_EMAIL
echo -e "══════════════════════════════════════════════" | lolcat
if [ -z "$PHPMYADMIN_EMAIL" ]; then
echo "Email tidak boleh kosong."
exit 1
fi
fi
certbot certonly --standalone -d $PHPMYADMIN_FQDN --staple-ocsp --no-eff-email -m $PHPMYADMIN_EMAIL --agree-tos
if [ $? -eq 0 ]; then
PHPMYADMIN_SSLSTATUS="Aktif"
phpmyadmin_user
else
phpmyadmin_user
PHPMYADMIN_SSLSTATUS="Gagal"
fi
}
phpmyadminweb(){
apt install mariadb-server -y
PHPMYADMIN_PASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
mariadb -u root -e "CREATE USER '$PHPMYADMIN_USER_LOCAL'@'localhost' IDENTIFIED BY '$PHPMYADMIN_PASSWORD';" && mariadb -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$PHPMYADMIN_USER_LOCAL'@'localhost' WITH GRANT OPTION;"
curl -o /etc/nginx/sites-enabled/phpmyadmin.conf https://raw.githubusercontent.com/guldkage/Pterodactyl-Installer/main/configs/phpmyadmin-ssl.conf
sed -i -e "s@<domain>@${PHPMYADMIN_FQDN}@g" /etc/nginx/sites-enabled/phpmyadmin.conf
systemctl restart nginx
phpmyadmin_finish
}
phpmyadmin_fqdn(){
clear
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
echo -e "${BOLD}${LIGHT_GREEN}► SILAHKAN MASUKAN SUBDOMAIN PHPMYADMIN${RESET}"
echo -e "══════════════════════════════════════════════" | lolcat
echo -e -n "${BOLD}${LIGHT_GREEN}> "
read PHPMYADMIN_FQDN
echo -e "══════════════════════════════════════════════" | lolcat
if [ -z "$PHPMYADMIN_FQDN" ]; then
echo "FQDN tidak boleh kosong."
exit 1
fi
IP=$(dig +short myip.opendns.com @resolver2.opendns.com -4)
DOMAIN=$(dig +short ${PHPMYADMIN_FQDN})
if [ "${IP}" != "${DOMAIN}" ]; then
echo "FQDN Anda tidak mengarah ke IP mesin ini."
sleep 10s
phpmyadmin_ssl
else
phpmyadmin_ssl
fi
}
phpmyadmin_summary(){
clear
echo ""
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
phpmyadmininstall
}
send_phpmyadmin_summary(){
clear
if [ -d "/var/www/phpmyadmin" ]; then
echo -e "${BOLD}${RED}[!] PHP MY ADMIN DI VPS INI SUDAH TERINSTAL${RESET} "
fi
echo -e "══════════════════════════════════════════════
► DATA - DATA
URL PHPMyAdmin: $PHPMYADMIN_FQDN
Webserver yang dipilih: NGINX
SSL: $PHPMYADMIN_SSLSTATUS
Pengguna: $PHPMYADMIN_USER_LOCAL
Email: $PHPMYADMIN_EMAIL
══════════════════════════════════════════════" | lolcat
}
phpmyadmin_user(){
send_phpmyadmin_summary
echo -e "══════════════════════════════════════════════" | lolcat
echo -e "${BOLD}${LIGHT_GREEN}► SILAHKAN MASUKAN USERNAME UNTUK PHPMYADMIN${RESET}"
echo -e "══════════════════════════════════════════════" | lolcat
echo -e -n "${BOLD}${LIGHT_GREEN}> "
read PHPMYADMIN_USER_LOCAL
echo -e "══════════════════════════════════════════════" | lolcat
phpmyadmin_summary
}
phpmyadmininstall(){
apt update
apt install nginx certbot -y
mkdir /var/www/phpmyadmin && cd /var/www/phpmyadmin
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz
tar xzf phpMyAdmin-5.2.1-all-languages.tar.gz
mv /var/www/phpmyadmin/phpMyAdmin-5.2.1-all-languages/* /var/www/phpmyadmin
chown -R www-data:www-data *
mkdir config
chmod o+rw config
cp config.sample.inc.php config/config.inc.php
chmod o+w config/config.inc.php
rm -rf /var/www/phpmyadmin/config
phpmyadminweb
}
phpmyadmin(){
apt install dnsutils -y
echo ""
echo "${BOLD}${ORANGE}[!] ${LIGHT_GREEN}SETELAH MENGINSTAL DEPEND SAYA MEMBUTUHKAN BEBERAPA INF0RMASI${RRSET} "
sleep 3
phpmyadmin_fqdn
}
phpmyadmin
;;
4Q)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       PROSES UNINSTALL PHPMYADMIN PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 10 "Masukan Subdomain Phpmyadmin"
echo -e "${YELLOW}Masukkan Subdomain Phpmyadmin Anda:${RESET}"
read -p "> " domain
if [[ -z "$domain" ]]; then
error_message "Nama domain tidak boleh kosong! Silakan coba lagi."
fi
sleep 1
show_progress 50 "Menghapus System - System Phpmyadmin"
cd /var/www/ && rm -rf phpmyadmin
rm -r /etc/nginx/sites-enabled/phpmyadmin.conf
show_progress 60 "Menghapus Certbot Pada Domain"
if certbot certificates | grep -q "$domain"; then
sudo certbot delete --cert-name "$domain"
echo -e "${BOLD}${LIGHT_GREEN}CERTIFICATE BERHASIL DI HAPUS${RESET}"
else
echo -e "${BOLD}${RED}CERTIFICATE TIDAK DITEMUKAN${RESET}"
fi
show_progress 100 "Berhasil Menghapus CtrlPanel Pterodactyl"
echo -e "${BOLD}${LIGHT_GREEN}DONE!!${RESET}"
sleep 4
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © PHPMYADMIN CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${YELLOW}Phpmyadminbl berhasil diuninstal pada domain: ${CYAN}https://$domain${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
D)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       VALIDASI DAN PROSES INSTALASI PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
show_progress 30 "Mengupdate Files Pterodactyl"
cd /var/www/pterodactyl && yes | php artisan p:upgrade
sleep 1
show_progress 100 "Restart Nginx dan Proses Selesai"
sudo systemctl restart nginx
sleep 2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © PTERODACTYL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
R)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       VALIDASI DAN PROSES INSTALASI PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
if [ ! -d "/var/www/pterodactyl_backup" ]; then
clear
echo -e "${RED}Direktori pterodactyl_backup tidak ada! Silakan hubungi Dev.${RESET}"
exit 1
else
echo -e "${BLUE}MEMPROSES...${RESET}"
sleep 2
fi
clear
show_progress 20 "Menghapus Direktori Lama"
cd /var/www/ && rm -r pterodactyl
sleep 1
show_progress 40 "Mengembalikan Direktori Backup"
mv pterodactyl_backup pterodactyl
sleep 1
show_progress 60 "Membuat Salinan Backup Baru"
cd /var/www/pterodactyl && rm -r pterodactyl > /dev/null 2>&1
cp -rL /var/www/pterodactyl /var/www/pterodactyl_backup
sleep 1
show_progress 70 "Mengatur Hak Dan Izin"
sudo chown -R www-data:www-data /var/www/pterodactyl
sudo chmod -R 755 /var/www/pterodactyl
sleep 2
show_progress 80 "Menjalankan Composer untuk Optimasi"
composer install --no-dev --optimize-autoloader --no-interaction > /dev/null 2>&1
sleep 1
show_progress 90 "Membersihkan Cache dan Konfigurasi Laravel"
php artisan cache:clear
php artisan config:cache
php artisan view:clear
sleep 1
show_progress 100 "Restart Nginx dan Proses Selesai"
sudo systemctl restart nginx
sleep 2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                   PROSES SELESAI                     ${RESET}"
echo -e "${MAGENTA}               © PTERODACTYL CONFIGURATOR             ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
1)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/stellarrimake.zip" /var/www/
cd /var/www && sudo mv "$TEMP_DIR/autosuspens.zip" /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
unzip -o /var/www/stellarrimake.zip -d /var/www/
unzip -o /var/www/autosuspens.zip -d /var/www/
rm /var/www/stellarrimake.zip
rm /var/www/autosuspens.zip
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
yarn add react-feather
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
yarn add react-feather
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan migrate --force
php artisan view:clear
show_progress 95 "Menginstal Addon Auto Suspend"
cd /var/www/pterodactyl
bash installer.bash
show_progress 100 "Mengunduh File Tambahan dan Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME STELLAR BERHASIL TERINSTAL${RESET}"
echo -e "${GREEN}ADDON AUTO SUSPEND BERHASIL DIINSTALL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
2)
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
clear
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}       INSTALASI BILLING MODULE UNTUK PTERODACTYL      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
clear
echo -e "${RED}��𝗘��𝗘��𝗗 𝗙��𝗟𝗘𝗦 ��𝗘������𝗠 𝗗��𝗜��𝗦𝗧𝗔𝗟${RESET}"
exit 1
fi
show_progress 20 "Memeriksa Node.js dan Yarn"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings > /dev/null 2>&1
echo -e "${BLUE}Direktori /etc/apt/keyrings dibuat.${RESET}"
else
echo -e "${GREEN}Direktori /etc/apt/keyrings sudah ada.${RESET}"
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg > /dev/null 2>&1
echo -e "${BLUE}File nodesource.gpg telah didownload.${RESET}"
else
echo -e "${GREEN}File nodesource.gpg sudah ada.${RESET}"
fi
if dpkg -l | grep -q "nodejs"; then
echo -e "${GREEN}Node.js sudah terinstal.${RESET}"
else
echo -e "${YELLOW}Node.js belum terinstal. Menginstal Node.js...${RESET}"
sudo apt update -y > /dev/null 2>&1 && sudo apt install -y nodejs > /dev/null 2>&1
if [ $? -eq 0 ]; then
echo -e "${GREEN}Node.js berhasil diinstal.${RESET}"
else
echo -e "${RED}Gagal menginstal Node.js.${RESET}"
exit 1
fi
fi
if npm list -g --depth=0 | grep -q "yarn"; then
echo -e "${GREEN}Yarn sudah terinstal.${RESET}"
else
echo -e "${YELLOW}Yarn belum terinstal. Menginstal Yarn...${RESET}"
npm install -g yarn > /dev/null 2>&1
if [ $? -eq 0 ]; then
echo -e "${GREEN}Yarn berhasil diinstal.${RESET}"
else
echo -e "${RED}Gagal menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 40 "Mendownload Billing Module"
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL" > /dev/null 2>&1
cd /var/www && sudo mv "$TEMP_DIR/billmodprem.zip.zip" /var/www/ > /dev/null 2>&1
unzip -o /var/www/billmodprem.zip.zip -d /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" /var/www/billmodprem.zip.zip
show_progress 60 "Mengatur Hak Akses dan Konfigurasi"
cd /var/www/pterodactyl
sudo chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null 2>&1
yarn > /dev/null 2>&1
show_progress 80 "Optimisasi Laravel"
echo "RAIN" | php artisan billing:install stable
sleep 2
show_progress 90 "Membangun Billing Module"
if ! yarn build:production; then
echo -e "${YELLOW}Kelihatannya ada kesalahan. Memulai proses perbaikan...${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn > /dev/null 2>&1
npx update-browserslist-db@latest > /dev/null 2>&1
yarn build:production
fi
sleep 2
show_progress 100 "INSTALASI SELESAI"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}           BILLING MODULE BERHASIL TERINSTAL            ${RESET}"
echo -e "${MAGENTA}               © PTERODACTYL CONFIGURATOR               ${RESET}"
echo -e "${CYAN}============================================================${RESET}";;
A)
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
DESTINATION="/var/www/pterodactyl/installer/logs"
FILE_URL="https://raw.githubusercontent.com/rainmc0123/RainPrem/main/install.sh"
show_progress() {
local percent=$1
local message=$2
local colors=("${CYAN}" "${MAGENTA}" "${YELLOW}" "${GREEN}" "${BLUE}")
local color=${colors[$((percent % ${#colors[@]}))]}
echo -e "${color}============================================================${RESET}"
echo -e "${color}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${color}============================================================${RESET}"
echo -e "${BOLD}${color}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 2
clear
show_progress 10 "Memeriksa Files Depend"
cd /var/www
YARN_JS="/var/www/pterodactyl/blueprint.sh"
if [ -f "$YARN_JS" ]; then
echo -e "${BOLD}${ORANGE}DEPEND BLUEPRINT DI HAPUS${RESET}"
rm -r "$YARN_JS"
else
echo -e "${GREEN}PROSES${RESET}"
fi
show_progress 20 "Mengunduh Repository RainPrem"
cd /var/www/pterodactyl && rm - r installer > /dev/null 2>&1
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/yarn-depend.js" /var/www/pterodactyl
cd /var/www/ && rm -r "$TEMP_DIR"
clear
show_progress 40 "Menginstal Node.js dan Yarn"
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
apt install nodejs -y
npm i -g yarn
clear
show_progress 60 "Menginstal NVM dan Node.js v20.18.1"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
source ~/.bashrc
source ~/.profile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 20.18.1
nvm use 20.18.1
node -v
clear
show_progress 80 "Menjalankan Yarn di Direktori Pterodactyl"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BOLD}${BLUE}ADUH ERROR LAGI, AUTO FIX ACTIVE{{RESET}"
sleep 1
clear
show_progress 85 "Memperbaiki Error pada Build Production"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
echo -e "${BOLD}${GREEN}FIX BERHASIL${RESET}"
fi
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}ERROR! SILAHKAN HUBUBGI RAINSTOEEID${RESET}"
exit 1
fi
clear
show_progress 100 "Proses Instalasi Selesai!"
sleep 2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${MAGENTA}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files Depend"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ -f "$YARN_JS" ]; then
echo -e "${BOLD}${ORANGE}FILE DEPEMD YARN DI HAPUS${RESET}"
rm -r "$YARN_JS"
else
echo -e "${GREEN}PROSES${RESET}"
fi
show_progress 10 "Memulai Instalasi Dependensi"
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
npm i -g yarn
show_progress 50 "Menginstal Dependensi Tambahan"
apt install -y zip unzip git curl wget > /dev/null 2>&1
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
mv release.zip /var/www/pterodactyl/release.zip
cd /var/www/pterodactyl
unzip -o release.zip
yarn add react-feather
yarn add cross-env
show_progress 80 "Melakukan Konfigurasi"
WEBUSER="www-data"
USERSHELL="/bin/bash"
PERMISSIONS="www-data:www-data"
sed -i -E -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"$WEBUSER\" #;|g" -e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"$USERSHELL\" #;|g" -e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"$PERMISSIONS\" #;|g" ./blueprint.sh
chmod +x blueprint.sh
show_progress 99 "Memasang Blueprint"
bash blueprint.sh < <(yes "y")
sleep 3
show_progress 100 "Instalasi Selesai!"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
E)
echo -e "${BOLD}${RED}ANDA TELAH KELUAR DARI INSTALLER${RESET}"
exit 1
;;
1B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
cd /var/www
cd /var/www && rm -r RainPrem > /dev/null 2>&1
BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
if [ ! -f "$BLUEPRINT_FILE" ]; then
echo -e "${BOLD}${LIGHT_GREEN}DEPEND BLUEPRINT BELUM DIINSTAL"
exit 1
fi
show_progress 10 "Mengunduh Repository RainPrem..."
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
git clone "$REPO_URL" > /dev/null 2>&1
sudo mv "$TEMP_DIR/mythical_ui.zip" /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" > /dev/null 2>&1
unzip -o /var/www/mythical_ui.zip -d /var/www/ > /dev/null 2>&1
show_progress 80 "Menginstal Mythical UI"
cd /var/www/pterodactyl && echo -e "y" | blueprint -install mythicalui > /dev/null 2>&1
rm /var/www/mythical_ui.zip /var/www/pterodactyl/
show_progress 100 "Instalasi Selesai!"
cd /var/www/pterodactyl && rm -r mythicalui.blueprint
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
2B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
cd /var/www
cd /var/www && rm -r RainPrem > /dev/null 2>&1
BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
if [ ! -f "$BLUEPRINT_FILE" ]; then
echo -e "${BOLD}${LIGHT_GREEN}DEPEND BLUEPRINT BELUM DIINSTAL"
exit 1
fi
show_progress 10 "Mengunduh Repository RainPrem..."
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
git clone "$REPO_URL" > /dev/null 2>&1
sudo mv "$TEMP_DIR/darknate.zip" /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" > /dev/null 2>&1
unzip -o /var/www/darknate.zip -d /var/www/ > /dev/null 2>&1
show_progress 80 "Menginstal Darknate"
cd /var/www/pterodactyl && echo -e "y" | blueprint -install darknate > /dev/null 2>&1
rm /var/www/darknate.zip /var/www/pterodactyl/
show_progress 100 "Instalasi Selesai!"
cd /var/www/pterodactyl && rm -r mythicalui.blueprint
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
3B)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © BLUEPRINT INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
cd /var/www
cd /var/www && rm -r RainPrem > /dev/null 2>&1
BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
if [ ! -f "$BLUEPRINT_FILE" ]; then
echo -e "${BOLD}${LIGHT_GREEN}DEPEND BLUEPRINT BELUM DIINSTAL"
exit 1
fi
show_progress 10 "Mengunduh Repository RainPrem..."
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
git clone "$REPO_URL" > /dev/null 2>&1
sudo mv "$TEMP_DIR/recolor.zip" /var/www/ > /dev/null 2>&1
rm -r "$TEMP_DIR" > /dev/null 2>&1
unzip -o /var/www/recolor.zip -d /var/www/ > /dev/null 2>&1
show_progress 80 "Menginstal Recolor"
cd /var/www/pterodactyl && echo -e "y" | blueprint -install recolor > /dev/null 2>&1
rm /var/www/recolor.zip /var/www/pterodactyl/
show_progress 100 "Instalasi Selesai!"
cd /var/www/pterodactyl && rm -r recolor.blueprint
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}                      INSTALL SELESAI                    ${RESET}"
echo -e "${GREEN}                      © RAINSTOREID                       ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
3)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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" # Ganti dengan token Githubmu jika perlu
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/enigmarain.zip" /var/www/
cd /var/www && sudo mv "$TEMP_DIR/autosuspens.zip" /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
unzip -o /var/www/enigmarain.zip -d /var/www/
unzip -o /var/www/autosuspens.zip -d /var/www/
rm /var/www/autosuspens.zip
rm /var/www/enigmarain.zip
show_progress 60 "Menanyakan Nomor Whatsapp"
FILE="/var/www/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx"
OLD_NUMBER="6285263390832"
echo -e -n "${BOLD}${LIGHT_GREEN}MASUKAN NOMOR WHATSAPP ANDA ( EXAMPLE 6285263390832 ) : "
read NEW_NUMBER
if [[ -f "$FILE" ]]; then
sed -i "s/$OLD_NUMBER/$NEW_NUMBER/g" "$FILE"
echo -e "${BOLD}${LIGHT_GREEN}NOMOR BERHASIL DITAMBAHKAN${RESET}"
else
echo -e "${BOLD}${RED}FILE TIDK DITEMUKAN!!${RESET}"
fi
sleep 2
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan migrate --force
php artisan view:clear
show_progress 95 "Menginstal Addon Auto Suspend"
cd /var/www/pterodactyl
bash installer.bash
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME ENIGMA BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
4)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 40 "Mematikan Panel sementara"
cd /var/www/pterodactyl
php artisan down
show_progress 50 "Mengunduh Repository dan File Tambahan"
curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
chmod -R 755 storage/* bootstrap/cache
chmod -R 755 storage/* bootstrap/cache
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
composer install --no-dev --optimize-autoloader --no-interaction > /dev/null 2>&1
php artisan view:clear
php artisan config:clear
php artisan migrate --seed --force
chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null 2>&1
chown -R nginx:nginx /var/www/pterodactyl/* > /dev/null 2>&1
chown -R apache:apache /var/www/pterodactyl/* > /dev/null 2>&1
show progress 98 "Restart Queue"
php artisan queue:restart
show progress 99 "Meng Activekan Kembali Panel Pterodactyl"
php artisan up
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME NOOK BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
5)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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" # Ganti dengan token Githubmu jika perlu
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/noobe.zip" /var/www/
unzip -o /var/www/noobe.zip -d /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
rm /var/www/noobe.zip
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan view:clear
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME NOOBE BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
6)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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" # Ganti dengan token Githubmu jika perlu
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/nightcore.zip" /var/www/
unzip -o /var/www/nightcore.zip -d /var/www/
cd /var/www && rm -r RainPrem > /dev/null 2>&1
rm /var/www/nightcore.zip
CSS_FILE="/var/www/pterodactyl/resources/scripts/Pterodactyl_Nightcore_Theme.css"
update_background() {
echo -e -n "${BOLD}${LIGHT_GREEN}LINK BACKROUND: "
read new_background_url
if [[ $new_background_url == https://* ]]; then
sed -i "s|https://raw.githubusercontent.com/NoPro200/Pterodactyl_Nightcore_Theme/main/background.jpg|$new_background_url|g" "$CSS_FILE"
echo -e "${BOLD}${LIGHT_GREEN}BACKROUND TELAH DIUBAH${RESET}"
else
echo -e "${BOLD}${RED}URL YANG DIMASUKAN TIDAK VALID${RESET}"
fi
}
update_logo() {
echo -e -n "${BOLD}${LIGHT_GREEN}LINK LOGO LOGIN: "
read new_logo_url
if [[ $new_logo_url == https://* ]]; then
sed -i "s|https://i.imgur.com/96D5X4d.png|$new_logo_url|g" "$CSS_FILE"
echo -e "${BOLD}${LIGHT_GREEN}LOGO LOGIN TELAH DIUBAH${RESET}"
else
echo -e "${BOLD}${RED}LINK LOGO TIDAK VALID!!${RESET}"
fi
}
show_progress 65 "Backround Dashboard & Login"
echo -e -n "${BOLD}${LIGHT_GREEN}APAKAH ANDA INGIN MENGUBAH BACKROUND? (y/N)${RESET}: "
read change_bg
if [[ $change_bg == "y" || $change_bg == "Y" ]]; then
update_background
else
echo -e "${BOLD}${ORANGE}LOGO BACKROUND TIDAK DIUBAH${RESET}"
fi
show_progress 65 "Logo Login"
echo -e -n "${BOLD}${LIGHT_GREEN}APAKAH ANDA INGIN MENGUBAH LOGO LOGIN (y/N)${RESET}: "
read change_logo
if [[ $change_logo == "y" || $change_logo == "Y" ]]; then
update_logo
else
echo -e "${BOLD}${ORANGE}LOGO LOGIN TIDAK DIUBAH${RESET}"
fi
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 90 "Menjalankan Migrasi dan Membersihkan Cache"
php artisan optimize:clear
show_progress 100 "Menyelesaikan Instalasi"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}THEME NIGHT CORE BERHASIL TERINSTAL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
C)
show_progress() {
local percent=$1
local message=$2
if [ "$percent" -le 40 ]; then
COLOR=$RED
elif [ "$percent" -le 70 ]; then
COLOR=$ORANGE
else
COLOR=$GREEN
fi
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${COLOR}PROSES: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}      © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}          WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}         © CREATE USERS IN INSTALLER BY RAINSTOREID   ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 1 "Memeriksa Files"
PANEL_PATH="/var/www/pterodactyl"
show_progress 50 "Mengisi Data - Data..."
buat_user() {
echo -e "${BOLD}${WHITE}=== CREATE NEW USERS IN PTERODACTYL ===${RESET}"echo -e "${BOLD}${WHITE}SILAHKAN ISI DATA - DATA BERIKUT UNTUK MEMBUAT USERS BARU.${RESET}"
echo -e -n "${BOLD}${LIGHT_GREEN}APAKAH ANDA INGIN USERS INI MENJADI ADMIN? (yes/no) [yes]: "
read is_admin
is_admin=${is_admin:-"yes"}
echo -e -n "${BOLD}${LIGHT_GREEN}EMAIL: "
read email
echo -e -n "${BOLD}${LIGHT_GREEN}NAMA LENGKAP (USERNAME): "
read username
echo -e -n "${BOLD}${LIGHT_GREEN}NAMA DEPAN: "
read first_name
echo -e -n "${BOLD}${LIGHT_GREEN}NAMA BELAKANG: "
read last_name
echo -e -n "${BOLD}${LIGHT_GREEN}PASSWORD: ${RESET}"
read -s password
echo
if [[ "$is_admin" != "yes" ]]; then
is_admin="yes"
fi
show_progress 100 "CREATE SELESAI"
cd "$PANEL_PATH" || { echo -e "${BOLD}${RED}DIREKTORI TIDAK DI TEMUKAN{RESET}"; exit 1; }
echo -e "$is_admin\n$email\n$username\n$first_name\n$last_name\n$password" | php artisan p:user:make > /dev/null 2>&1
echo
echo -e "${BOLD}${LIGHT_GREEN}===NEW USERS BERHASIL DIBUAT===${RESET}"
printf "+-------------------+------+-------------+\n"
printf "| Pertanyaan       | Data                |\n"
printf "+-------------------+------+-------------+\n"
printf "| Admin            | %-18s |\n" "$is_admin"
printf "| Email            | %-18s |\n" "$email"
printf "| Username         | %-18s |\n" "$username"
printf "| Nama Depan       | %-18s |\n" "$first_name"
printf "| Nama Belakang    | %-18s |\n" "$last_name"
printf "| Password         | %-18s |\n" "$password"
printf "+-------------------+--------------------+\n ${RESET}"
sleep 5
exit 1
}
buat_user
;;
1A)
show_progress() {
local percent=$1
local message=$2
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}PROGRESS: ${percent}% - ${message}${RESET}"
echo -e "${GREEN}          © RAINSTOREID${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}》 LOGS INSTALLER${RESET}"
sleep 2
}
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${BOLD}${CYAN}            WELCOME TO RAINSTOREID INSTALLER      ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}            © INSTALLER BY RAINSTOREID           ${RESET}"
echo -e "${CYAN}============================================================${RESET}"
sleep 3
show_progress 10 "Memeriksa File Dependensi"
cd /var/www
YARN_JS="/var/www/pterodactyl/yarn-depend.js"
if [ ! -f "$YARN_JS" ]; then
echo -e "${BOLD}${RED}DEPEND FILES BELUM DIINSTAL${RESET}"
exit 1
fi
show_progress 20 "Menyiapkan Direktori dan File GPG"
if [ ! -d "/etc/apt/keyrings" ]; then
sudo mkdir -p /etc/apt/keyrings
echo "Direktori /etc/apt/keyrings telah dibuat."
else
echo "Direktori /etc/apt/keyrings sudah ada."
fi
if [ ! -f "/etc/apt/keyrings/nodesource.gpg" ]; then
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "File nodesource.gpg telah didownload dan disimpan."
else
echo "File nodesource.gpg sudah ada, skip download."
fi
show_progress 30 "Memeriksa dan Menginstal Node.js"
if dpkg -l | grep -q "nodejs"; then
echo "Node.js sudah terinstal."
else
echo "Node.js belum terinstal. Menginstal Node.js sekarang..."
sudo apt update -y && sudo apt install -y nodejs npm
if [ $? -eq 0 ]; then
echo "Node.js berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Node.js.${RESET}"
exit 1
fi
fi
show_progress 40 "Memeriksa dan Menginstal Yarn"
if npm list -g --depth=0 | grep -q "yarn"; then
echo "Yarn sudah terinstal."
else
echo "Yarn belum terinstal. Menginstal Yarn sekarang..."
npm install -g yarn
if [ $? -eq 0 ]; then
echo "Yarn berhasil diinstal."
else
echo -e "${RED}Terjadi kesalahan saat menginstal Yarn.${RESET}"
exit 1
fi
fi
show_progress 50 "Mengunduh Repository dan File Tambahan"
GITHUB_TOKEN="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"
REPO_URL="https://${GITHUB_TOKEN}@github.com/rainmc01/RainPrem.git"
TEMP_DIR="RainPrem"
cd /var/www && git clone "$REPO_URL"
sudo mv "$TEMP_DIR/display-password.zip" /var/www/  >/dev/null 2>&1
unzip -o /var/www/display-password.zip -d /var/www/
rm -r "$TEMP_DIR"  >/dev/null 2>&1
rm /var/www/display-password.zip
show_progress 70 "Membangun Front-End dan Memperbaiki Jika Error"
cd /var/www/pterodactyl
yarn
if ! yarn build:production; then
echo -e "${BLUE}Kelihatannya ada kesalahan.. Proses fix..${RESET}"
export NODE_OPTIONS=--openssl-legacy-provider
yarn
yarn add react-feather
npx update-browserslist-db@latest
yarn build:production
fi
show_progress 100 "Menyelesaikan"
clear
echo -e "${CYAN}============================================================${RESET}"
echo -e "${GREEN}ADDON DISPLAY PASSWORD BERHASIL DIINSTALL${RESET}"
echo -e "${CYAN}============================================================${RESET}"
;;
esac
echo "Pilih opsi:"
echo "1) Lanjut ke installer"
echo "2) Keluar"
read -p "Masukkan pilihan (1/2): " pilihan
if [ "$pilihan" -eq 1 ]; then
bash <(curl -s https://raw.githubusercontent.com/rainprem/freeshell/refs/heads/main/install.sh)
elif [ "$pilihan" -eq 2 ]; then
echo "Keluar..."
exit 1
else
echo "Pilihan tidak valid, keluar..."
exit 1
fi