FROM python:slim

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000
ENV FLASK_APP=main.py

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "3", "main:app"]