# Use Alpine-based Python image with a specific version for better reproducibility
FROM --platform=linux/amd64 python:3.9-alpine3.19

# Set timezone
ENV TZ=Europe/Amsterdam
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apk del tzdata

# Set working directory
WORKDIR /app

# Install system dependencies and Python packages
# Combine operations to reduce layers and overall image size
RUN apk add --no-cache bash bc coreutils jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev harfbuzz-dev fribidi-dev pngquant libimagequant-dev && \
    apk add --no-cache --virtual .build-deps build-base gcc musl-dev python3-dev libimagequant libimagequant-dev && \
    pip install --no-cache-dir Pillow==9.5.0 && \
    pip install --no-cache-dir imagequant && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/* /root/.cache

# Copy only the necessary files
COPY run.sh generate-date-image.py generate-swiss-clock.py Arima-VariableFont_wght.ttf ./

# Create output directory
RUN mkdir output

# Make run.sh executable
RUN chmod +x run.sh

# Set the entrypoint to run.sh
ENTRYPOINT ["./run.sh"]