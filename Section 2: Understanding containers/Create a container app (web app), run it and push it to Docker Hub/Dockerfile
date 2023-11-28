# Base image
FROM python:alpine

# Install dnsutils, netcat-openbsd, and curl
RUN apk update && \
    apk add bind-tools netcat-openbsd curl && \
    rm -rf /var/cache/apk/*

#Create a non-root user
RUN adduser -D appuser

# Set the working directory in the container
WORKDIR /app

#Copy the requirements.txt file into the container
COPY requirements.txt /app/requirements.txt

#Install dependencies
RUN pip install -r requirements.txt

# Copy the Flask application code into the container
COPY app.py /app/app.py

# Expose port 8080 for the Flask application
EXPOSE 8080

# Set the container to run as a nonroot user
USER appuser

# Set the command to run the Flask application
CMD ["python3", "app.py"]
