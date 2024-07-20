# Use Ruby 3.3 as the base image
FROM ruby:3.3-slim

# Create a non-root user to run the app
RUN useradd -s /bin/bash -m flowbots

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
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

ARG USE_TRF=False
ARG USE_BOOKNLP=False

RUN python3 -m venv .venv && \
    . /app/.venv/bin/activate && \
    echo "[[ -f /app/.venv ]] && cd /app && . /app/.venv/bin/activate" >> /home/flowbots/.bashrc && \
    echo "gem: --user-instal --no-document" >> /home/flowbots/.gemrc && \
    pip3 install -U setuptools wheel && \
    pip3 install -U spacy 'pdfminer.six[image]' && \
    python3 -m spacy download en_core_web_lg && \
    python -c "import sys, importlib.util as util; 1 if util.find_spec('nltk') else sys.exit(); import nltk; nltk.download('punkt')"

RUN if [ "${USE_TRF}" = "True"]; then \
        . /app/.venv/bin/activate && \
        python3 -m spacy download en_core_web_trf \
    ; fi

RUN if [ "${USE_TRF}" = "True"]; then \
        . /app/.venv/bin/activate && \
        pip3 install -U transformers booknlp \
    ; fi

# Copy only the Gemfile and requirements.txt
COPY Gemfile ./

# Copy the rest of the application code
# Copy only the specified directories and files
COPY bin/ ./bin/
COPY examples/ ./examples/
COPY exe/ ./exe/
COPY lib/ ./lib/
COPY nano-bots/ ./nano-bots/
COPY workflows/ ./workflows/

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Create necessary directories
RUN mkdir -p log models workspace

RUN chown -R flowbots:flowbots /app

USER flowbots

ENV PATH="/home/flowbots/.local/share/gem/ruby/3.3.0/bin:$PATH"

RUN bundle lock --add-platform x86_64-linux && \
    bundle config build.redic --with-cxx="clang++" --with-cflags="-std=c++0x" && \
    bundle install

# Set the default command (can be overridden)
CMD ["bash"]
