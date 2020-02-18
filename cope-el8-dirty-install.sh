#!/bin/bash
dnf install epel-release -y
yum config-manager --set-enabled PowerTools && dnf update -y
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-Env-Path-0.19-1.el8.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-IO-Stty-0.03-10.el8.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-Number-Format-1.73-14.el8.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-Regexp-IPv6-0.03-11.el8.noarch.rpm
dnf install perl-File-ShareDir perl-IO-Tty perl-List-MoreUtils perl-Regexp-Common -y
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-rc2/perl-App-Cope-1.1-1.el8.noarch.rpm
echo 'PATH=$(cope_path.pl):$PATH' >> ~/.bashrc