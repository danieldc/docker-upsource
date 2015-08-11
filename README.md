# docker-upsource

[![Docker Image][docker-image]][docker-url]
[![Apache License][license-image]][license-url]

Docker image for JetBrains Upsource

## Docker Image

### Pull and run

You can use the Docker image as-is (it will use defaults and will need you to complete the wizard configuration):

```shell
docker run -P frapontillo/upsource
```

### Customized image

You can extend the default image and specify a few environment variables in your own Dockerfile, e.g.:

```dockerfile
FROM    frapontillo/upsource:latest

ENV     UPSOURCE_BASE_URL http://url-to-access/
ENV     UPSOURCE_LOGS_DIR /path/to/upsource/logs
ENV     UPSOURCE_TEMP_DIR /path/to/upsource/temp
ENV     UPSOURCE_DATA_DIR /path/to/upsource/data
ENV     UPSOURCE_BACKUPS_DIR /path/to/upsource/backups
ENV     UPSOURCE_LICENSE_USER_NAME Your upsource user name
ENV     UPSOURCE_LICENSE_KEY yourupsourcelicensekey

# this MUST be run to configure everything, it will use the previous environment variables
RUN     /opt/Upsource/configure.sh
```

Build and run your image: your Upsource instance will then be running on the port 8080 in the docker container.

See the [google-cloud](google-cloud/) directory to know how to extend the image and run the container on the Google Cloud platform.

## License

[JetBrains Upsource](https://www.jetbrains.com/upsource) and [Oracle Java 8](https://www.java.com) are referenced in the Docker container, but are subject to their own licenses.

```
   Copyright 2015 Francesco Pontillo

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

[docker-url]: https://hub.docker.com/r/frapontillo/upsource
[docker-image]: https://img.shields.io/docker/pulls/frapontillo/upsource?style=flat

[license-image]: http://img.shields.io/badge/license-Apache_2.0-blue.svg?style=flat
[license-url]: LICENSE
