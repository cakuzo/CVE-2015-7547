# CVE-2015-7547
### glibc vulnerability test script
This provides a shell script for testing the glibc vulnerability CVE-2015-7547. It's written for rpm based systems such as `Red Hat Enterprise Linux / RHEL / CentOS (5/6/7)`. Detection for other distributions may follow.

### Resolution
1. Run `bin/test-glibc.sh` to check if your system is vulnerable
1. Update the glibc packages
1. Reboot the system or restart all affected services
1. Run `bin/test-glibc.sh` again to verify

In case you are unable to restart the entire system after applying the update, execute the following command to list all running processes (not restricted to services) still using the old [in-memory] version of glibc on your system.
```
lsof +c0 -d DEL | awk 'NR==1 || /libc-/ {print $2,$1,$4,$NF}' | column -t
```

### Further information

**Google Security Blog:**

https://googleonlinesecurity.blogspot.be/2016/02/cve-2015-7547-glibc-getaddrinfo-stack.html

**Glibc Bug Report:**

https://sourceware.org/bugzilla/show_bug.cgi?id=18665

**Red Hat / CentOS:**

https://access.redhat.com/articles/2161461

https://access.redhat.com/security/cve/CVE-2015-7547

**Debian Squeeze, Wheezy, Jessy & Stretch:**

https://security-tracker.debian.org/tracker/CVE-2015-7547

**Ubuntu 12.04 & 14.04:**

http://people.canonical.com/~ubuntu-security/cve/2015/CVE-2015-7547.html

On Ubuntu 14.04 LTS make sure you get the following output
```
ldd --version | head -1
ldd (Ubuntu EGLIBC 2.19-0ubuntu6.7) 2.19
```
