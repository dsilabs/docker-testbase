#
# python web app test container
#

# FROM python:$PYTHON_VERSION
FROM python:3.12

# install stable version of chrome
RUN wget http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_133.0.6943.141-1_amd64.deb
RUN dpkg --force-all -i google-chrome-stable_133.0.6943.141-1_amd64.deb || true
RUN apt-get update -qq
RUN apt-get install -f -y
RUN google-chrome --version

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
