FROM thebloke/cuda12.1.1-ubuntu22.04-pytorch:latest

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

RUN ln -s /usr/bin/python3 /usr/bin/python

ADD requirements.txt .

RUN pip3 install -r requirements.txt

ADD . .

CMD ["python", "app.py"]