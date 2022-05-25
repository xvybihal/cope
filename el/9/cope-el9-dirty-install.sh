dnf config-manager --set-enabled crb
dnf install perl epel-release epel-next-release -y
dnf install perl-File-ShareDir perl-IO-Tty perl-List-MoreUtils perl-Regexp-Common -y

rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-Number-Format-1.75-13.el9.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-Env-Path-0.19-24.el9.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-IO-Stty-0.04-8.el9.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-Regexp-IPv6-0.03-32.el9.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-App-Cope-1.1-1.el9.noarch.rpm
echo 'PATH=$(cope_path.pl):$PATH' >>~/.bashrc
