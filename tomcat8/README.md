# "opt-tomcat8" Package

This packages the binary [Apache Tomcat8](https://tomcat.apache.org/download-80.cgi)
release as a Debian package located in ``/opt/tomcat8`` using ``fpm``.


## Building the opt-tomcat8 package

Check if the Tomcat version number in ``tomcat8/fpm_debian.sh`` is the one you want to package
(see the [Tomcat8 download page](https://tomcat.apache.org/download-80.cgi) for what's current).
Then call the ``fpm_debian.sh`` in its directory, which will download the binary release tarball
and create the Debian package in the same directory.

```sh
cd tomcat8
./fpm_debian.sh
```

Note that all sample webapps except the Tomcat ``manager`` application are removed.
