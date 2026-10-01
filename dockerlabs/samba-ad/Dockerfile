FROM debian:12-slim
ENV DEBIAN_FRONTEND=noninteractive
ENV LDB_MODULES_PATH=/usr/lib/x86_64-linux-gnu/samba/ldb
RUN apt-get update && apt-get install -y --no-install-recommends \
    samba samba-ad-provision samba-dsdb-modules samba-vfs-modules smbclient krb5-user winbind ldb-tools procps iproute2 \
 && rm -rf /var/lib/apt/lists/* /etc/samba/smb.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 53 88 135 139 389 445 464 636 3268 3269
ENTRYPOINT ["/entrypoint.sh"]
