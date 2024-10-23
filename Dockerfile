# Stage 1: Build Dependencies
FROM ruby:3.3-slim AS build

# Install system dependencies
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    apt-transport-https \
    apt-utils \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    dialog \
    exiftool \
    git \
    gnupg \
    gnuplot \
    gpg-agent \
    graphviz \
    libcairo2-dev \
    libczmq-dev \
    libffi-dev \
    libfftw3-dev \
    libgdbm-dev \
    libgmp-dev \
    libgsl-dev \
    liblink-grammar-dev \
    libmagick++-dev \
    libmariadb-dev-compat \
    libmariadb-dev \
    libncurses5-dev \
    libopenblas-dev \
    libplot2c2 \
    libpoppler-glib-dev \
    libpq-dev \
    libreadline-dev \
    libreoffice \
    libsqlite3-dev \
    libssl-dev \
    libtamuanova-0.2 \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    libzmq3-dev \
    link-grammar \
    lsb-release \
    minisat \
    neovim \
    openssl \
    pandoc \
    pdftk \
    pkg-config \
    plotutils \
    poppler-utils \
    postgresql-client \
    python3 \
    python3-link-grammar \
    python3-pip \
    python3.11-venv \
    rsync \
    ruby-psych \
    software-properties-common \
    sqlite3 \
    tesseract-ocr \
    tidy \
    tzdata \
    wget \
    zip \
    zlib1g-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile ./
RUN bundle lock --add-platform x86_64-linux && \
    bundle config build.redic --with-cxx="clang++" --with-cflags="-std=c++0x" && \
    bundle install

# Stage 2: Python Dependencies
FROM python:3.9-slim AS python-env

ARG USE_TRF=False
ARG USE_BOOKNLP=False

WORKDIR /app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app/Gemfile* /app/

RUN pip install -U setuptools wheel && \
    pip install -U spacy 'pdfminer.six[image]' && \
    python3 -m spacy download en_core_web_lg && \
    python -c "import sys, importlib.util as util; 1 if util.find_spec('nltk') else sys.exit(); import nltk; nltk.download('punkt')"

RUN if [ "${USE_TRF}" = "True" ]; then \
        python3 -m spacy download en_core_web_trf; \
    fi

RUN if [ "${USE_BOOKNLP}" = "True" ]; then \
        pip3 install -U transformers booknlp; \
    fi

# Stage 3: Final Image
FROM ruby:3.3-slim

WORKDIR /app

# Copy necessary files and directories from previous stages
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=python-env /app/ /app/

# Copy the rest of the application code
COPY bin/ ./bin/
COPY examples/ ./examples/
COPY exe/ ./exe/
COPY lib/ ./lib/
COPY nano-bots/ ./nano-bots/
COPY flowbots.json .

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8
ENV PATH="/usr/local/bundle/bin:$PATH"

# Create necessary directories
RUN mkdir -p log models workspace

# Set the default command (can be overridden)
CMD ["bash"]
