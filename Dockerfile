FROM python:3.11-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /vividarts_studio

COPY requirements.txt /vividarts_studio/

RUN pip install --upgrade pip \ 
 && pip install -r requirements.txt

COPY . /vividarts_studio/

EXPOSE 5000

CMD [ "python", "-u", "/vividarts_studio/app.py"]


# docker build -t vividarts_studio-1.0.0 .

# docker images

# docker run -p 3306:[containerport] --name [new-name] [containerid/containername]