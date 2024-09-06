FROM python:3.9-alpine as base

RUN apk --update add ffmpeg

FROM base as builder

WORKDIR /install
COPY requirements.txt /requirements.txt
RUN apk add gcc libc-dev zlib zlib-dev jpeg-dev
RUN pip install --prefix="/install" -r /requirements.txt

FROM base

COPY --from=builder /install /usr/local/lib/python3.9/site-packages
RUN mv /usr/local/lib/python3.9/site-packages/lib/python3.9/site-packages/* /usr/local/lib/python3.9/site-packages/
COPY zotify /app/zotify

# Create user
RUN addgroup -g 1000 -S app
RUN adduser -h /app -s /bin/sh -G app -S -u 1000 app

RUN mkdir /music
RUN mkdir /podcasts
RUN chown -R app:app /music
RUN chown -R app:app /podcasts
RUN chown -R app:app /app

USER app

WORKDIR /app
CMD ["python3", "-m", "zotify"]
