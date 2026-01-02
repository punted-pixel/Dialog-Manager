FROM python:slim

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY app app
COPY main.py ./

ENV FLASK_APP=main.py

EXPOSE 5000
CMD ["gunicorn", "--bind" "0.0.0.0:5000", "--workers" "3", "app:app"]