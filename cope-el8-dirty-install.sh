#!/bin/bash
yum config-manager --set-enabled powertools
dnf install epel-release epel-next-release perl -y
dnf update -y

dnf install perl-Number-Format perl-File-ShareDir perl-IO-Tty perl-List-MoreUtils perl-Regexp-Common -y

rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-Env-Path-0.19-1.el8.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-IO-Stty-0.03-10.el8.noarch.rpm
#rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-Number-Format-1.73-14.el8.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-Regexp-IPv6-0.03-11.el8.noarch.rpm

rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-App-Cope-1.1-1.el8.noarch.rpm

echo 'PATH=$(cope_path.pl):$PATH' >> ~/.bashrc
