#!/bin/sh
echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf
apt-get update
apt-get install python-pip -y
apt-get install python-dev -y
pip install pbr -i https://pypi.python.org/simple/
pip install -U setuptools -i https://pypi.python.org/simple/
pip install pytz -i https://pypi.python.org/simple/
pip install python-openstackclient -i https://pypi.python.org/simple/
pip install enum -i https://pypi.python.org/simple/
apt-get install libffi-dev -y
pip install ctutlz -i https://pypi.python.org/simple/
pip install functools32 -i https://pypi.python.org/simple/
