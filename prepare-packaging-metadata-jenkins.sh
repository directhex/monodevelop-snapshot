#!/bin/bash
# prepare-packaging-metadata-jenkins.sh
# Copyright 2012 Jo Shields
# Copyright 2014 Xamarin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


PACKAGING_ROOT="$( cd "$( dirname "$0" )" && pwd )"
MONO_ROOT=${PACKAGING_ROOT}/../monodevelop-git-latest/
BUILD_ARCH=$(dpkg-architecture -qDEB_BUILD_ARCH)
TIMESTAMP=`echo $BUILD_ID | sed 's/[_-]//g'`
GITSTAMP=`tail -c9 ${MONO_ROOT}/buildinfo`

echo "Building debian/ folder"
rm -rf ${MONO_ROOT}/debian/
cp -r ${PACKAGING_ROOT}/debian ${MONO_ROOT}
cd ${MONO_ROOT}
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/control.in > debian/control
sed -i "s/%GITVER%/$GITSTAMP/g" debian/control
rm -f debian/control.in
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/environment.in > debian/${TIMESTAMP}
rm -f debian/environment.in
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/install.in > debian/monodevelop-snapshot-${TIMESTAMP}.install
rm -f debian/install.in
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/rules.in > debian/rules
chmod a+x debian/rules
echo "3.0 (quilt)" > debian/source/format
rm -f debian/rules.in
DEBEMAIL="Xamarin Public Jenkins <jo.shields@xamarin.com>" \
	dch --create --distribution unstable --package monodevelop-snapshot-${TIMESTAMP} --newversion ${TIMESTAMP}-1 \
	--force-distribution --empty "Git snapshot (commit ID ${GITSTAMP})"
mv ../monodevelop*tar.bz2 ../monodevelop-snapshot-${TIMESTAMP}_${TIMESTAMP}.orig.tar.bz2
