#!/usr/bin/env bash
#
# This script checks if the system is vulnerable to the CVE-2015-7547
# It's initially written for RHEL 6/7 but should at least display
# helpful information for other distributions as well.
# 
# Google Security Blog:
# https://googleonlinesecurity.blogspot.be/2016/02/cve-2015-7547-glibc-getaddrinfo-stack.html
#
# Glibc Bug Report:
# https://sourceware.org/bugzilla/show_bug.cgi?id=18665
#
# Red Hat / CentOS:
# https://access.redhat.com/articles/2161461
# https://access.redhat.com/security/cve/CVE-2015-7547
#
# Debian Squeeze, Wheezy, Jessy & Stretch:
# https://security-tracker.debian.org/tracker/CVE-2015-7547
#
# Ubuntu 12.04 & 14.04:
# http://people.canonical.com/~ubuntu-security/cve/2015/CVE-2015-7547.html
#
# Ing. Orhan Cakan, 2016

echo_interactive() {
  # print formatted if it's an interactive shell
  tty -s && {
    tput $2 $3
    echo "$1"
    tput sgr0
  } || echo "$1"
}

check_rpm_changelogs() {
  if rpm -q --changelog "$glibc_rpm" | grep -q 'CVE-2015-7547'; then
    echo_interactive "not vulnerable" setaf 2
    ret=0
  else
    # all RHEL updates include CVE in rpm %changelog
    echo_interactive "vulnerable to CVE-2015-7547" setaf 1
    ret=1
  fi

  return $ret
}

check_glibc_ver() {
  if [ "$maj" -gt $1 -o \( "$rel_maj"  -ge $2 -a "$rel_min" -ge $3 \) ]; then
    echo_interactive "not vulnerable" setaf 2
    ret=0
  else
    check_rpm_changelogs
    ret=$?
  fi

  return $ret
}

print_information() {
  # print information only if shell is interactive
  tty -s || return

  cat <<-EOF

	$(tput bold)Further information:$(tput sgr0)
	  https://googleonlinesecurity.blogspot.be/2016/02/cve-2015-7547-glibc-getaddrinfo-stack.html
	$(tput bold)Bug Report:$(tput sgr0)
	  https://sourceware.org/bugzilla/show_bug.cgi?id=18665
	EOF

  if [[ "$1" == "not_rhel" ]]; then
    cat <<-EOF
	$(tput bold)Debian Squeeze, Wheezy, Jessy & Stretch:$(tput sgr0)
          https://security-tracker.debian.org/tracker/CVE-2015-7547

	$(tput bold)Ubuntu 12.04 & 14.04:$(tput sgr0)
	  http://people.canonical.com/~ubuntu-security/cve/2015/CVE-2015-7547.html
	EOF
  else
    cat <<-EOF
	$(tput bold)Red Hat:$(tput sgr0)
	  https://access.redhat.com/articles/2161461
	  https://access.redhat.com/security/cve/CVE-2015-7547
	EOF
  fi
}

# exit if rpm is not installed
which rpm >/dev/null 2>&1 || { 
  print_information not_rhel; exit 1 
}

ret=0
echo_interactive "Installed glibc packages:" bold

for glibc_rpm in $( rpm -q --qf '%{name}-%{version}-%{release}\n' glibc ); do
  # glibc-2.12-1.166.el6_7.7
  ver=$( echo "$glibc_rpm" | cut -d- -f2) # 2.12
  maj=$( echo "$ver" | cut -d. -f1) # 2
  min=$( echo "$ver" | cut -d. -f2) # 12
  rel=$( echo "$glibc_rpm" | cut -d- -f3) # 1.166.el6_7.7
  rel_os=$( echo "$rel" | cut -d_ -f1 | cut -d. -f3) # el6
  rel_maj=$( echo "$rel" | cut -d_ -f2 | cut -d. -f1) # 7
  rel_min=$( echo "$rel" | cut -d_ -f2 | cut -d. -f2) # 7

  echo -n "$glibc_rpm: "
  case "$rel_os" in
    el5)
      echo_interactive "RHEL 5 is not affected" setaf 2
      exit 0
    ;;
    el6)
      check_glibc_ver 2 7 7
    ;;
    el7)
      check_glibc_ver 2 2 4
    ;;
    *)
      print_information not_rhel
      exit 1
  esac
done

[ $ret -ge 1 ] && print_information

exit $ret
