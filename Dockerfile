FROM centos:7
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

RUN yum -y install epel-release httpd mod_wsgi mod_ssl mod_shib net-tools vim

COPY certificates/hostkey.pem /etc/pki/tls/private/localhost.key
COPY certificates/hostcert.pem /etc/pki/tls/certs/localhost.crt
COPY certificates/igtf-ca-bundle.crt /etc/pki/tls/certs/server-chain.crt
RUN mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.orig && \
    sed 's/#SSLCertificateChainFile/SSLCertificateChainFile/g' /etc/httpd/conf.d/ssl.conf.orig > /etc/httpd/conf.d/ssl.conf && \
    rm -f /etc/httpd/conf.d/ssl.conf.orig &&
    systemctl enable httpd

RUN yum -y install python2-pip && \
    pip install --upgrade pip

CMD ["/usr/sbin/init"]
