FROM alpine
MAINTAINER Gizar Zigangirov 'gizar.zigangirov@gmail.com'
COPY flask_app.py requirements.txt /app
WORKDIR /app
RUN apk add --no-cache python3 && if [ ! -e /usr/bin/python ]; then \ 
    ln -sf python3 /usr/bin/python ; fi && \
    python3 -m ensurepip --upgrade && rm -rf /usr/lib/python*/ensurepip && \
    pip3 install --no-cache setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
    pip3 install --no-cache -r requirements.txt
ENTRYPOINT ["python3"]
CMD ["flask_app.py"] 
