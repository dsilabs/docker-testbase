#
# python web app test container
#

ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}

# Chrome for Testing keeps the pinned build after Google drops the .deb.
ARG CHROME_VERSION=133.0.6943.141
RUN apt-get update -qq \
 && apt-get install -yqq --no-install-recommends \
      unzip \
      fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 \
      libcairo2 libcups2 libdbus-1-3 libdrm2 libgbm1 libgtk-3-0 libnspr4 libnss3 \
      libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 libxdamage1 libxext6 \
      libxfixes3 libxkbcommon0 libxrandr2 \
 && wget -O /tmp/chrome.zip "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chrome-linux64.zip" \
 && unzip -o /tmp/chrome.zip -d /opt \
 && chmod +x /opt/chrome-linux64/chrome \
 && rm -f /usr/local/bin/google-chrome /usr/bin/google-chrome /usr/bin/google-chrome-stable \
 && ln -s /opt/chrome-linux64/chrome /usr/local/bin/google-chrome \
 && ln -s /opt/chrome-linux64/chrome /usr/bin/google-chrome \
 && ln -s /opt/chrome-linux64/chrome /usr/bin/google-chrome-stable \
 && rm /tmp/chrome.zip \
 && google-chrome --version

# install mariadb
RUN export DEBIAN_FRONTEND=noninteractive
RUN MYSQL_ROOT_PASSWORD=root
RUN apt-get install -y -qqq mariadb-server

# install os packages
RUN apt-get install -y git vim cron

# update pip
RUN pip install --upgrade pip

# install uwsgi
RUN pip install uwsgi

# install nginx
RUN apt-get install -y nginx
