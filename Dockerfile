FROM centos:7
LABEL maintainer="Levi Baber <baber@iastate.edu>"

# These will need set at build time using your credentials
ARG GOOGLE_ANALYTICS_ID=UA-XXXXXXXX
ARG GOOGLE_EARTH_ENGINE_ACCOUNT=test@test.iam.gserviceaccount.com

# prereq
RUN yum -y install epel-release

# system dependencies
RUN yum -y install python numpy python-pillow python-pip git wget unzip gcc python-devel python2-oauth2client python-jinja2 python-crypto python2-google-api-client pyopenssl python-webob python-paste

# google app engine
RUN wget https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.40.zip
RUN unzip google_appengine_1.9.40.zip -d /usr/local/bin

# python dependencies that are not available via yum
COPY requirements.txt /root
RUN pip install -r /root/requirements.txt

# install touchterrain
RUN git clone https://github.com/ChHarding/TouchTerrain_for_CAGEO.git /var/www/touchterrain
WORKDIR /var/www/touchterrain
RUN git checkout v1.20

# update google analytics id
RUN sed -i -e "s|UA-93016136-1|$GOOGLE_ANALYTICS_ID|g" server/index.html

# update google earth engine account
RUN sed -i -e "s|^EE_ACCOUNT.*|EE_ACCOUNT = \'$GOOGLE_EARTH_ENGINE_ACCOUNT\'|g" server/config.py

# update google earth engine private key
RUN sed -i -e "s|^EE_PRIVATE_KEY_FILE.*|EE_PRIVATE_KEY_FILE \= \'/etc/pki/tls/private/tt_private_key.pem\'|g" server/config.py
COPY private_key.pem /etc/pki/tls/private/tt_private_key.pem

# run paste instead of apache for this docker container
RUN sed -i -e 's/SERVER_TYPE \= \"Apache\"/SERVER_TYPE \= \"paste\"/g' server/touchterrain_config.py

# let paste serve to any host
RUN sed -i -e 's/127.0.0.1/0.0.0.0/g' server/TouchTerrain_app.py

# clunky way to handle the static zip files
RUN mkdir server/tmp/tmp
RUN sed -i -e 's/tmp/tmp\/tmp/g' server/touchterrain_config.py
RUN sed -i -e '/from paste import httpserver/ a \ \ \ \ from paste.cascade import Cascade' server/TouchTerrain_app.py
RUN sed -i -e '/from paste import httpserver/ a \ \ \ \ from paste.urlparser import StaticURLParser' server/TouchTerrain_app.py
RUN sed -i -e '/from paste.cascade/ a \ \ \ \ tmp_app = StaticURLParser("/var/www/touchterrain/server/tmp", "/var/www/touchterrain/server/tmp")' server/TouchTerrain_app.py
RUN sed -i -e '/tmp_app/ a \ \ \ \ app = Cascade([tmp_app, app])' server/TouchTerrain_app.py

EXPOSE 8080

CMD ["python", "/var/www/touchterrain/server/TouchTerrain_app.py"]
