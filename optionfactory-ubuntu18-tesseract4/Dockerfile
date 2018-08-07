FROM optionfactory/ubuntu18:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
	autoconf \
	autoconf-archive \
	automake \
	build-essential \
	checkinstall \
	cmake \
	g++ \
	git \
	libcairo2-dev \
	libicu-dev \
	libjpeg8-dev \
	libpango1.0-dev \
	libpng-dev \
	libtiff5-dev \
	libtool \
	pkg-config \
	xzgv \
	zlib1g-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
RUN rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/DanBloomberg/leptonica.git /opt/leptonica-src
RUN git clone https://github.com/tesseract-ocr/tesseract.git /opt/tesseract-src
RUN mkdir -p /opt/tesseract-data
RUN curl -# -sSL -k https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata -o /opt/tesseract-data/osd.traineddata
RUN curl -# -sSL -k https://github.com/tesseract-ocr/tessdata/raw/3.04.00/equ.traineddata -o /opt/tesseract-data/equ.traineddata
RUN curl -# -sSL -k https://github.com/tesseract-ocr/tessdata/raw/4.00/eng.traineddata -o /opt/tesseract-data/eng.traineddata
RUN cd /opt/leptonica-src && autoreconf -vi && ./autogen.sh && ./configure && make && make install && ldconfig
RUN cd /opt/tesseract-src && ./autogen.sh && ./configure &&  make && make install && ldconfig && make training && make training-install
