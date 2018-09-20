# TouchTerrain Docker

This Dockerfile will need to be built by you locally using your Google Earth Engine credentials.

This is using the python paste server, and has not been optimized for security or production scaling.
For local testing only, not for production deployment.

Instructions:

* Obtain Google Earth Engine credentials by requesting access here: https://signup.earthengine.google.com/#!/
* Clone this repo
* Place your private_key.pem file from google into this project directory
* Build the docker image (more details below)
* Run the docker container (more details below)
* Pull open a browser to http://127.0.0.1:8080

### To build:
```
$ docker build --build-arg GOOGLE_EARTH_ENGINE_ACCOUNT=earthengine@youraccounthere.iam.gserviceaccount.com .
```
You'll see a bunch of messages about the container building, then at the end you should have:
```
Successfully built abc123def456
```

### To run:
```
$ docker run -p 8080:8080 abc123def456
```
(substitute the image hash for your actual hash)
