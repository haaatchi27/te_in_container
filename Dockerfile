#FROM --platform=linux/amd64 ubuntu:22.04
FROM ubuntu:22.04

RUN apt -qq update && \
    apt-get -qq --force-yes --yes install apt-transport-https && \
    apt -qq install -y gnupg ca-certificates init systemd

# install repository.
ENV CODENAME jammy
ENv INSTALL_REPOSITORY "https://apt.thousandeyes.com"
RUN echo "deb $INSTALL_REPOSITORY $CODENAME main" > /etc/apt/sources.list.d/thousandeyes.list && \
    chmod 644 /etc/apt/sources.list.d/thousandeyes.list

# install public key of te
ENV PUBLIC_KEY="-----BEGIN PGP PUBLIC KEY BLOCK-----\n\
Version: GnuPG v1.4.11 (GNU/Linux)\n\
\n\
mQENBFApO8oBCACxHESumhIcqUTvpIA+q9yIWQQL2nE1twF1T92xIJ9kgOF/5ali\n\
iEqtNm0Vm2lpZy/LBcTG/UJY5rsKZVVWaepzXsNABeqzEE8t1CMGJ3hqtaZu59nd\n\
VglzwuNuNL+qTjtgX3taPQrO9SQNwMq7lpQeTgBKAM8PjjKMdjezHl2rdtEdG2Km\n\
VtN9qYDmb4ysCwq+ifCwOsZ4AM97r1M1+KwjNIa9EqA86qBixp2WqxaZ0ba4S3TG\n\
wxwEa9Zcm+OXYKcU3TBug+S1OMp14E3PlfSCuS1T7xvbV0KgQRSOsMgPYQLcvw8u\n\
r/uyONvdrx2+/oKrnd/ePZu2ha83msqOR+3vABEBAAG0KVRob3VzYW5kRXllcyA8\n\
YnVpbGR1c2VyQHRob3VzYW5kZXllcy5jb20+iQE4BBMBAgAiBQJQKTvKAhsDBgsJ\n\
CAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRDJmhX1vnGJAKdFB/44WXjZvtirSNzn\n\
Z9vDdxk/zXiWCyR/19znf+piIYCbRBqtoVGRxsxMS0FFHZZ4W6SlieklWJX3WShh\n\
/17EaxC596Aegp4MuwTTQ3hMdEtyB1hDd1e1XQUQULaW/0+4u+dD9n6pHYnKF4Zx\n\
DOQhJ5uXgKTaGZ5Z01JG92R9FxQJMre4j2N4F+EYd6pR9Cr2eBk5CVdnvw8njSak\n\
PhmtmIjhf9faCsWf+mJGQuYggSKk8DJcobIjT3TqLoUlRYwhre1cnB/0mGTph/P1\n\
xFCSpCMGU51jwpyUy1t2bHYeSVAba4PNqOOlITwRfDkKQxB9frI8ycGyx2S+eKFD\n\
Qty56ztU\n\
=p3tN\n\
-----END PGP PUBLIC KEY BLOCK-----"
ENV DEBIAN_PUBLIC_KEY_FILE "thousandeyes-apt-key.pub"
RUN echo "$PUBLIC_KEY" > /root/${DEBIAN_PUBLIC_KEY_FILE} && \
    apt-key --keyring /root/${DEBIAN_PUBLIC_KEY_FILE}.gpg add /root/${DEBIAN_PUBLIC_KEY_FILE} && \
    mv /root/${DEBIAN_PUBLIC_KEY_FILE}.gpg /etc/apt/trusted.gpg.d/${DEBIAN_PUBLIC_KEY_FILE}.gpg && \
    rm /root/${DEBIAN_PUBLIC_KEY_FILE} /root/${DEBIAN_PUBLIC_KEY_FILE}.gpg~

RUN apt -qq update && \
apt -qq install -y te-agent
    # apt -qq install -y te-agent && \
    # apt -qq install -y te-browserbot || true

# RUN  /start_te-a.sh
RUN echo "#!/bin/bash\n\n" > /start_te-a.sh && \
    echo "# account token is 32 letters." >> /start_te-a.sh && \
    echo "# ACCOUNT_TOKEN=0123456789abcdefghijklmnopqrstuv\n" >> /start_te-a.sh && \
    echo "if [[ \${ACCOUNT_TOKEN} =~ ^[0-9a-zA-Z]{32}$ ]]; then" >> /start_te-a.sh && \
    echo "    sed -i s/account-token.*/account-token=\${ACCOUNT_TOKEN}/ /etc/te-agent.cfg\n" >> /start_te-a.sh && \
    echo "    systemctl enable te-agent" >> /start_te-a.sh && \
    echo "    systemctl restart te-agent" >> /start_te-a.sh && \
    echo "else" >> /start_te-a.sh && \
    echo "    echo \"Account Token is invalid.\"" >> /start_te-a.sh && \
    echo "fi" >> /start_te-a.sh && \
    echo "exec \"\$@\"" >> /start_te-a.sh && \
    chmod +x /start_te-a.sh

# RUN locale-gen en_US.UTF-8
# ENV LANG=en_US.UTF-8
# ENV LANGUAGE=en_US:en
# ENV LC_ALL=en_US.UTF-8

# ENTRYPOINT ["/sbin/init"]
ENTRYPOINT ["/start_te-a.sh"]


# # CMD ["/start_te-a.sh >> /start_te-a.log"]
# CMD ["/bin/bash -c /start_te-a.sh"]
CMD ["/sbin/init"]