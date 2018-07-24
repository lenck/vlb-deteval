#!/bin/bash

PACKAGE_BIN="vlb-deteval-`cat version`-bin.tar.gz"
URL=www.robots.ox.ac.uk/~karel/blobs/${PACKAGE_BIN}
wget ${URL} -O ${PACKAGE_BIN}
tar xzvf ${PACKAGE_BIN}
