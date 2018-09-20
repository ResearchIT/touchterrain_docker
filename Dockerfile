FROM centos:7
LABEL maintainer="Levi Baber <baber@iastate.edu>"

# These will need set at build time using your credentials
ARG google_analytics_id=UA-XXXXXXXX
ARG google_earth_engine_acct=test@test.iam.gserviceaccount.com

#prereq
RUN yum -y install epel-release

# system dependencies
RUN yum -y install python numpy python-pillow python-pip git wget unzip gcc python-devel python2-oauth2client python-jinja2

# google app engine
RUN wget https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.40.zip
RUN unzip google_appengine_1.9.40.zip -d /usr/local/bin


# python dependencies
COPY requirements.txt /root
RUN pip install -r /root/requirements.txt

# install touchterrain
RUN git clone https://github.com/ChHarding/TouchTerrain_for_CAGEO.git /var/www/touchterrain
WORKDIR /var/www/touchterrain
RUN git checkout v1.20

# update google analytics id
RUN sed -i -e 's|.*UA-93016136-1.*|\"$google_analytics_id\"|g' server/index.html

# update google earth engine account
RUN sed -i -e 's|^EE_ACCOUNT.*|EE_ACCOUNT = \"earthengine@touchterrain.iam.gserviceaccount.com\"|g' server/config.py

# update google earth engine private key
RUN sed -i -e "s|^EE_PRIVATE_KEY_FILE.*|EE_PRIVATE_KEY_FILE \= \'/etc/pki/tls/private/tt_private_key.pem\'|g" server/config.py
COPY private_key.pem /etc/pki/tls/private/tt_private_key.pem

# run paste instead of apache for this docker container
RUN sed -i -e 's/SERVER_TYPE \= \"Apache\"/SERVER_TYPE \= \"paste\"/g' server/touchterrain_config.py

EXPOSE 8080

CMD ["python", "/var/www/touchterrain/server/TouchTerrain_app.py"]

# TODO:
# swap 127.0.0.1 for 0.0.0.0 in Paste
# fix ARG substitution for EE_ACCOUNT
# fix tmp directory for output file
