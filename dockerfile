# ===============================
# Base image (small)
# ===============================
FROM python:3.12-slim

# ===============================
# Environment settings
# ===============================
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ===============================
# System dependencies (minimal)
# ===============================
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    python3-dev \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# ===============================
# Working directory
# ===============================
WORKDIR /app

# ===============================
# Install Python dependencies
# ===============================
COPY requirements-ci.txt .

RUN pip install --no-cache-dir -r requirements-ci.txt

# ===============================
# Copy only required files
# ===============================
COPY app.py .
COPY models/preprocessor.joblib models/preprocessor.joblib
COPY scripts/data_clean_utils.py scripts/data_clean_utils.py
COPY run_information.json .

# ===============================
# Expose port
# ===============================
EXPOSE 8000

# ===============================
# Run app
# ===============================
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]

