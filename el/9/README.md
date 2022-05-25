# Where I took the dependencies?

```bash
# powertools are called crb(CodeReady Linux Builder) now
dnf config-manager --set-enabled crb
dnf install perl epel-release epel-next-release -y
#perl-File-ShareDir perl-IO-Tty perl-List-MoreUtils perl-Regexp-Common
dnf install perl-File-ShareDir perl-IO-Tty perl-List-MoreUtils perl-Regexp-Common

# builded
perl-Number-Format # https://koji.fedoraproject.org/koji/packageinfo?packageID=perl-Number-Format
perl-Env-Path      # https://koji.fedoraproject.org/koji/packageinfo?packageID=perl-Env-Path
perl-IO-Stty       # https://koji.fedoraproject.org/koji/packageinfo?packageID=perl-IO-Stty
perl-Regexp-IPv6   # https://koji.fedoraproject.org/koji/packageinfo?packageID=perl-Regexp-IPv6




```


# How it was built?

```bash
# rpmbuild
# https://www.redhat.com/sysadmin/create-rpm-package

dnf group install "Development Tools"
dnf install -y rpmdevtools rpmlint perl-Pod-Coverage perl-Module-Install
useradd copebuilder
su - copebuilder
rpmdev-setuptree

rpm -Uvh perl-Number-Format-1.75-13.el9.noarch.rpm perl-Env-Path-0.19-24.el9.noarch.rpm perl-IO-Stty-0.04-8.el9.noarch.rpm perl-Regexp-IPv6-0.03-32.el9.noarch.rpm

# rpmbuild -bb|-bs|-ba *.spec
# rpmbuild --undefine=_disable_source_fetch -ba /path/to/your.spec

```

`.spec` files added to repo. (s)rpms attached to -el9 release.


# How to lazy install?

Use `cope-el9-dirty-install.sh` or:

```bash
dnf config-manager --set-enabled crb
dnf install perl epel-release epel-next-release -y
dnf install perl-File-ShareDir perl-IO-Tty perl-List-MoreUtils perl-Regexp-Common -y

rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-Number-Format-1.75-13.el9.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-Env-Path-0.19-24.el9.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-IO-Stty-0.04-8.el9.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-Regexp-IPv6-0.03-32.el9.noarch.rpm
rpm -Uvh https://github.com/xvybihal/cope/releases/download/v1.1-el9/perl-App-Cope-1.1-1.el9.noarch.rpm
echo 'PATH=$(cope_path.pl):$PATH' >>~/.bashrc

```

No support, no warranty. You are on your own.