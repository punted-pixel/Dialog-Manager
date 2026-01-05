FROM python:slim

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8080
ENV FLASK_APP=main.py

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "3", "app:create_app()"]