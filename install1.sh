#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  clear
  echo "���󣺱��ű���Ҫ root Ȩ��ִ�С�" 1>&2
  exit 1
fi

check_sys() {
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif cat /etc/issue | grep -q -E -i "debian"; then
    release="debian"
  elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  elif cat /proc/version | grep -q -E -i "debian"; then
    release="debian"
  elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  fi
}

welcome() {
  echo ""
  echo "��ӭʹ�� efb һ����װ����"
  echo "��װ������ʼ"
  echo "�������ȡ����װ��"
  echo "���� 3 �����ڰ� Ctrl+C ��ֹ�˽ű���"
  echo ""
  sleep 3
}

yum_update() {
  echo "�����Ż� yum . . ."
  echo "�˹������� ��Ϊ��Ҫ����ϵͳ����"
  yum install yum-utils epel-release -y >>/dev/null 2>&1
  yum localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm -y >>/dev/null 2>&1
  yum update -y >>/dev/null 2>&1
}

yum_git_check() {
  echo "���ڼ�� Git ��װ��� . . ."
  if command -v git >>/dev/null 2>&1; then
    echo "Git �ƺ����ڣ���װ���̼��� . . ."
  else
    echo "Git δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    yum install git -y >>/dev/null 2>&1
  fi
}

yum_python_check() {
  echo "���ڼ�� python ��װ��� . . ."
  if command -v python3 >>/dev/null 2>&1; then
    U_V1=$(python3 -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}')
    U_V2=$(python3 -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $2}')
    if [ $U_V1 -gt 3 ]; then
      echo 'Python 3.6+ ���� . . .'
    elif [ $U_V2 -ge 6 ]; then
      echo 'Python 3.6+ ���� . . .'
      PYV=$U_V1.$U_V2
      PYV=$(which python$PYV)
    else
      if command -v python3.6 >>/dev/null 2>&1; then
        echo 'Python 3.6+ ���� . . .'
        PYV=$(which python3.6)
      else
        echo "Python3.6 δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
        yum install python3 -y >>/dev/null 2>&1
        update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 >>/dev/null 2>&1
        PYV=$(which python3.6)
      fi
    fi
  else
    echo "Python3.6 δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    yum install python3 -y >>/dev/null 2>&1
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 >>/dev/null 2>&1
  fi
  if command -v pip3 >>/dev/null 2>&1; then
    echo 'pip ���� . . .'
  else
    echo "pip3 δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    yum install -y python3-pip >>/dev/null 2>&1
  fi
}

yum_screen_check() {
  echo "���ڼ�� Screen ��װ��� . . ."
  if command -v screen >>/dev/null 2>&1; then
    echo "Screen �ƺ�����, ��װ���̼��� . . ."
  else
    echo "Screen δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    yum install screen -y >>/dev/null 2>&1
  fi
}

yum_require_install() {
  echo "���ڰ�װϵͳ����������������Ҫ�����ӵ�ʱ�� . . ."
  yum update -y >>/dev/null 2>&1
  yum install python-devel python3-devel ffmpeg ffmpeg-devel cairo cairo-devel wget -y >>/dev/null 2>&1
  yum list updates >>/dev/null 2>&1
}

apt_update() {
  echo "�����Ż� apt-get . . ."
  apt-get install sudo -y >>/dev/null 2>&1
  apt-get update >>/dev/null 2>&1
}

apt_git_check() {
  echo "���ڼ�� Git ��װ��� . . ."
  if command -v git >>/dev/null 2>&1; then
    echo "Git �ƺ�����, ��װ���̼��� . . ."
  else
    echo "Git δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    apt-get install git -y >>/dev/null 2>&1
  fi
}

apt_python_check() {
  echo "���ڼ�� python ��װ��� . . ."
  if command -v python3 >>/dev/null 2>&1; then
    U_V1=$(python3 -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}')
    U_V2=$(python3 -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $2}')
    if [ $U_V1 -gt 3 ]; then
      echo 'Python 3.6+ ���� . . .'
    elif [ $U_V2 -ge 6 ]; then
      echo 'Python 3.6+ ���� . . .'
      PYV=$U_V1.$U_V2
      PYV=$(which python$PYV)
    else
      if command -v python3.6 >>/dev/null 2>&1; then
        echo 'Python 3.6+ ���� . . .'
        PYV=$(which python3.6)
      else
        echo "Python3 δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
        add-apt-repository ppa:deadsnakes/ppa -y
        apt-get update >>/dev/null 2>&1
        apt-get install python3 -y >>/dev/null 2>&1
        update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3 1 >>/dev/null 2>&1
        PYV=$(which python3.6)
      fi
    fi
  else
    echo "Python3.6 δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    add-apt-repository ppa:deadsnakes/ppa -y
    apt-get update >>/dev/null 2>&1
    apt-get install python3 -y >>/dev/null 2>&1
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3 1 >>/dev/null 2>&1
  fi
  if command -v pip3 >>/dev/null 2>&1; then
    echo 'pip ���� . . .'
  else
    echo "pip3 δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    apt-get install -y python3-pip >>/dev/null 2>&1
  fi
}

debian_python_check() {
  echo "���ڼ�� python ��װ��� . . ."
  if command -v python3 >>/dev/null 2>&1; then
    U_V1=$(python3 -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}')
    U_V2=$(python3 -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $2}')
    if [ $U_V1 -gt 3 ]; then
      echo 'Python 3.6+ ���� . . .'
    elif [ $U_V2 -ge 6 ]; then
      echo 'Python 3.6+ ���� . . .'
      PYV=$U_V1.$U_V2
      PYV=$(which python$PYV)
    else
      if command -v python3.6 >>/dev/null 2>&1; then
        echo 'Python 3.6+ ���� . . .'
        PYV=$(which python3.6)
      else
        echo "Python3.6 δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
        apt-get update -y >>/dev/null 2>&1
        apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev >>/dev/null 2>&1
        wget https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tgz >>/dev/null 2>&1
        tar -xvf Python-3.8.5.tgz >>/dev/null 2>&1
        chmod -R +x Python-3.8.5 >>/dev/null 2>&1
        cd Python-3.8.5 >>/dev/null 2>&1
        ./configure >>/dev/null 2>&1
        make && make install >>/dev/null 2>&1
        cd .. >>/dev/null 2>&1
        rm -rf Python-3.8.5 Python-3.8.5.tar.gz >>/dev/null 2>&1
        PYP=$(which python3.6)
        update-alternatives --install $PYP python3 $PYV 1 >>/dev/null 2>&1
      fi
    fi
  else
    echo "Python3.6 δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    apt-get update -y >>/dev/null 2>&1
    apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev >>/dev/null 2>&1
    wget https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tgz >>/dev/null 2>&1
    tar -xvf Python-3.8.5.tgz >>/dev/null 2>&1
    chmod -R +x Python-3.8.5 >>/dev/null 2>&1
    cd Python-3.8.5 >>/dev/null 2>&1
    ./configure >>/dev/null 2>&1
    make && make install >>/dev/null 2>&1
    cd .. >>/dev/null 2>&1
    rm -rf Python-3.8.5 Python-3.8.5.tar.gz >>/dev/null 2>&1
    PYP=$(which python3)
    update-alternatives --install $PYP python3 $PYV 1 >>/dev/null 2>&1
  fi
  echo "���ڼ�� pip3 ��װ��� . . ."
  if command -v pip3 >>/dev/null 2>&1; then
    echo 'pip ���� . . .'
  else
    echo "pip3 δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    apt-get install -y python3-pip >>/dev/null 2>&1
  fi
}

apt_screen_check() {
  echo "���ڼ�� Screen ��װ��� . . ."
  if command -v screen >>/dev/null 2>&1; then
    echo "Screen �ƺ�����, ��װ���̼��� . . ."
  else
    echo "Screen δ��װ�ڴ�ϵͳ�ϣ����ڽ��а�װ"
    apt-get install screen -y >>/dev/null 2>&1
  fi
}

apt_require_install() {
  echo "���ڰ�װϵͳ����������������Ҫ�����ӵ�ʱ�� . . ."
  apt-get install python3.6-dev python3-dev ffmpeg ffmpeg-devel libcairo2-dev libcairo2 -y >>/dev/null 2>&1
}

debian_require_install() {
  echo "���ڰ�װϵͳ����������������Ҫ�����ӵ�ʱ�� . . ."
  apt-get install python3-dev ffmpeg ffmpeg-devel libcairo2-dev libcairo2 -y >>/dev/null 2>&1
}

download_repo() {
  echo "���� repository �� . . ."
  cd /root >>/dev/null 2>&1
  git clone https://github.com/shzxm/efb-install.git ~/.ehforwarderbot/profiles/default/ >>/dev/null 2>&1
  cd ~/.ehforwarderbot/profiles/default/ >>/dev/null 2>&1
  echo "Hello World!" >~/.ehforwarderbot/profiles/default/.lock
}

pypi_install() {
  echo "���ذ�װ pypi ������ . . ."
  $PYV -m pip install --upgrade pip >>/dev/null 2>&1
  $PYV -m pip install -r requirements.txt >>/dev/null 2>&1
  $PYV -m pip install --upgrade Pillow >>/dev/null 2>&1
  sudo -H $PYV -m pip install --ignore-installed PyYAML >>/dev/null 2>&1
}

configure() {
  cd /root
  echo "�����ļ��� efb-wizard �Զ�����"
  LANG=zh_CN.UTF-8
  echo "���趨�� ʹ��Ĭ�ϼ���"
  sleep 3
  efb-wizard
}

login_screen() {
  cd /root/.ehforwarderbot/profiles/default
  screen -S efb -X quit >>/dev/null 2>&1
  screen -L -dmS efb
  sleep 4
  echo "��� ΢��"
  screen -x -S efb -p 0 -X stuff "/usr/local/bin/ehforwarderbot"
  screen -x -S efb -p 0 -X stuff $'\n'
  sleep 1
  while [ ! -f "/root/.ehforwarderbot/profiles/default/blueset.wechat/wxpy.pkl" ]; do
    echo "�� ɨһɨ ��ά���¼ ΢��"
    cat /root/.ehforwarderbot/profiles/default/screenlog.0
    sleep 5
  done
  sleep 5
  screen -S efb -X quit >>/dev/null 2>&1
  rm -rf /root/.ehforwarderbot/profiles/default/screenlog.0
}

systemctl_reload() {
  echo "����д��ϵͳ�����ػ� . . ."
  echo "[Unit]
    Description=ehforwarderbot
    After=network.target
    [Install]
    WantedBy=multi-user.target
    [Service]
    Type=simple
    WorkingDirectory=/root
    ExecStart=/usr/local/bin/ehforwarderbot
    Restart=always
    " >/etc/systemd/system/efb.service
  chmod 755 efb.service >>/dev/null 2>&1
  systemctl daemon-reload >>/dev/null 2>&1
  systemctl start efb >>/dev/null 2>&1
  systemctl enable efb >>/dev/null 2>&1
}

start_installation() {
  if [ "$release" = "centos" ]; then
    echo "ϵͳ���ͨ����"
    welcome
    yum_update
    yum_git_check
    yum_python_check
    yum_screen_check
    yum_require_install
    download_repo
    pypi_install
    configure
    login_screen
    systemctl_reload
    echo "efb �Ѿ���װ��� ��telegram �� ��bot�Ի� ��ʼʹ��"
  elif [ "$release" = "ubuntu" ]; then
    echo "ϵͳ���ͨ����"
    welcome
    apt_update
    apt_git_check
    apt_python_check
    apt_screen_check
    apt_require_install
    download_repo
    pypi_install
    configure
    login_screen
    systemctl_reload
    echo "efb �Ѿ���װ��� ��telegram �� ��bot�Ի� ��ʼʹ��"
  elif [ "$release" = "debian" ]; then
    echo "ϵͳ���ͨ����"
    welcome
    apt_update
    apt_git_check
    debian_python_check
    apt_screen_check
    debian_require_install
    download_repo
    pypi_install
    configure
    login_screen
    systemctl_reload
    echo "efb �Ѿ���װ��� ��telegram �� ��bot�Ի� ��ʼʹ��"
  else
    echo "Ŀǰ��ʱ��֧�ִ�ϵͳ��"
  fi
  exit 1
}

cleanup() {
  if [ ! -x "/root/.ehforwarderbot/profiles" ]; then
    echo "Ŀ¼�����ڲ���Ҫж�ء�"
  else
    echo "���ڹر� efb"
    systemctl disable efb >>/dev/null 2>&1
    systemctl stop efb >>/dev/null 2>&1
    echo "����ж��efb"
    pip3 uninstall -y -r ~/.ehforwarderbot/profiles/defaultrequirements.txt
    echo "����ɾ�� efb �ļ� . . ."
    rm -rf /etc/systemd/system/efb.service >>/dev/null 2>&1
    rm -rf /root/.ehforwarderbot >>/dev/null 2>&1
    echo "ж����� . . ."
  fi
}

reinstall() {
  cleanup
  start_installation
}

cleansession() {
  if [ ! -x "/root/.ehforwarderbot/profiles" ]; then
    echo "Ŀ¼�����������°�װ efb��"
    exit 1
  fi
  echo "���ڹر� efb . . ."
  systemctl stop efb >>/dev/null 2>&1
  echo "����ɾ���˻���Ȩ�ļ� . . ."
  echo "��������µ�½. . ."
  if [ "$release" = "centos" ]; then
    yum_python_check
    yum_screen_check
  elif [ "$release" = "ubuntu" ]; then
    apt_python_check
    apt_screen_check
  elif [ "$release" = "debian" ]; then
    debian_python_check
    apt_screen_check
  else
    echo "Ŀǰ��ʱ��֧�ִ�ϵͳ��"
  fi
  login_screen
  systemctl start efb >>/dev/null 2>&1
}

stop_pager() {
  echo ""
  echo "���ڹر� efb . . ."
  systemctl stop efb >>/dev/null 2>&1
  echo ""
  sleep 3
  shon_online
}

start_pager() {
  echo ""
  echo "�������� efb . . ."
  systemctl start efb >>/dev/null 2>&1
  echo ""
  sleep 3
  shon_online
}

restart_pager() {
  echo ""
  echo "������������ efb . . ."
  systemctl restart efb >>/dev/null 2>&1
  echo ""
  sleep 3
  shon_online
}

install_require() {
  if [ "$release" = "centos" ]; then
    echo "ϵͳ���ͨ����"
    yum_update
    yum_git_check
    yum_python_check
    yum_screen_check
    yum_require_install
    pypi_install
    systemctl_reload
    shon_online
  elif [ "$release" = "ubuntu" ]; then
    echo "ϵͳ���ͨ����"
    apt_update
    apt_git_check
    apt_python_check
    apt_screen_check
    apt_require_install
    pypi_install
    systemctl_reload
    shon_online
  elif [ "$release" = "debian" ]; then
    echo "ϵͳ���ͨ����"
    welcome
    apt_update
    apt_git_check
    debian_python_check
    apt_screen_check
    debian_require_install
    pypi_install
    systemctl_reload
    shon_online
  else
    echo "Ŀǰ��ʱ��֧�ִ�ϵͳ��"
  fi
  exit 1
}

shon_online() {
  echo "��ѡ������Ҫ���еĲ���:"
  echo "  1) ��װ efb"
  echo "  2) ж�� efb"
  echo "  3) ���°�װ efb"
  echo "  4) ���µ�½ efb"
  echo "  5) �ر� efb"
  echo "  6) ���� efb"
  echo "  7) �������� efb"
  echo "  8) ���°�װ efb ����"
  echo "  9) �˳��ű�"
  echo ""
  echo "     Version��0.1"
  echo ""
  echo -n "��������: "
  read N
  case $N in
  1) start_installation ;;
  2) cleanup ;;
  3) reinstall ;;
  4) cleansession ;;
  5) stop_pager ;;
  6) start_pager ;;
  7) restart_pager ;;
  8) install_require ;;
  9) exit ;;
  *) echo "Wrong input!" ;;
  esac
}

check_sys
shon_online