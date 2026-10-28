#
# python web app test container
#

ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}

# Stable Chrome 133. Google dropped this .deb; the mirror still has the
# same package we verified against the old image. Not Chrome for Testing.
ARG CHROME_DEB_URL=https://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_133.0.6943.141-1_amd64.deb
# The .deb enables dl.google.com without a key apt can use. Remove that
# source after install so later apt-get update works. Chrome stays pinned.
RUN wget -O /tmp/chrome.deb "${CHROME_DEB_URL}" \
 && (dpkg --force-all -i /tmp/chrome.deb || true) \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -f -y \
 && rm -f /tmp/chrome.deb \
      /etc/apt/sources.list.d/google-chrome.list \
      /etc/apt/sources.list.d/google-chrome.sources \
 && apt-get update -qq \
 && google-chrome --version

# install mariadb
RUN export DEBIAN_FRONTEND=noninteractive
RUN MYSQL_ROOT_PASSWORD=root
RUN apt-get install -y -qqq mariadb-server

# install os packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git vim cron iputils-ping locales locales-all

# update pip
RUN pip install --upgrade pip

# install uwsgi
RUN pip install uwsgi

# install nginx
RUN apt-get install -y nginx
