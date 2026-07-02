# Deploy MyMoney to Google Cloud

This project should run on:

- Cloud Run: PHP web/API container
- Cloud SQL for MySQL: production database
- Artifact Registry: container image registry
- Secret Manager: app/database secrets

The local `docker-compose.yml` is for local development only. Do not deploy the MySQL container to Cloud Run.

## 1. Set Variables

Run these commands in Google Cloud Shell or another terminal with `gcloud` and Docker configured.
Replace these values before running commands.

```bash
export PROJECT_ID="your-gcp-project-id"
export REGION="asia-southeast1"
export REPOSITORY="mymoney"
export SERVICE="mymoney-api"
export SQL_INSTANCE="mymoney-db"
export DB_NAME="MyMoney_app"
export DB_USER="finance_user"
```

## 2. Enable APIs

```bash
gcloud config set project "$PROJECT_ID"
gcloud services enable \
  run.googleapis.com \
  sqladmin.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  cloudbuild.googleapis.com
```

## 3. Create Cloud SQL

Use stronger passwords than these examples.

```bash
export ROOT_PASSWORD="replace-with-a-strong-root-password"
export DB_PASSWORD="replace-with-a-strong-password"
export APP_SECRET="$(openssl rand -base64 32)"

gcloud sql instances create "$SQL_INSTANCE" \
  --database-version=MYSQL_8_0 \
  --region="$REGION" \
  --tier=db-f1-micro \
  --root-password="$ROOT_PASSWORD"

gcloud sql databases create "$DB_NAME" --instance="$SQL_INSTANCE"

gcloud sql users create "$DB_USER" \
  --instance="$SQL_INSTANCE" \
  --password="$DB_PASSWORD"
```

## 4. Import Schema and Sample Data

Cloud SQL imports SQL files from Cloud Storage. Create a temporary bucket, upload the schema and sample data, then import them in order.

```bash
export BUCKET="${PROJECT_ID}-mymoney-sql"

gcloud storage buckets create "gs://${BUCKET}" --location="$REGION"
gcloud storage cp database/init/001_schema.sql "gs://${BUCKET}/001_schema.sql"
gcloud storage cp database/init/002_subscription.sql "gs://${BUCKET}/002_subscription.sql"
gcloud storage cp database/sample_data.sql "gs://${BUCKET}/sample_data.sql"

gcloud sql import sql "$SQL_INSTANCE" "gs://${BUCKET}/001_schema.sql" --database="$DB_NAME"
gcloud sql import sql "$SQL_INSTANCE" "gs://${BUCKET}/002_subscription.sql" --database="$DB_NAME"
gcloud sql import sql "$SQL_INSTANCE" "gs://${BUCKET}/sample_data.sql" --database="$DB_NAME"
```

Demo login after import:

- Email: `demo@example.com`
- Password: `password123`

## 5. Create Secrets

```bash
printf "%s" "$DB_PASSWORD" | gcloud secrets create mymoney-db-password --data-file=-
printf "%s" "$APP_SECRET" | gcloud secrets create mymoney-app-secret --data-file=-
```

If a secret already exists, add a new version instead:

```bash
printf "%s" "$DB_PASSWORD" | gcloud secrets versions add mymoney-db-password --data-file=-
printf "%s" "$APP_SECRET" | gcloud secrets versions add mymoney-app-secret --data-file=-
```

## 6. Build and Push Image

```bash
gcloud artifacts repositories create "$REPOSITORY" \
  --repository-format=docker \
  --location="$REGION"

gcloud auth configure-docker "${REGION}-docker.pkg.dev"

export IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${SERVICE}:latest"

docker build -t "$IMAGE" .
docker push "$IMAGE"
```

## 7. Deploy to Cloud Run

Get the Cloud SQL connection name:

```bash
export INSTANCE_CONNECTION_NAME="$(gcloud sql instances describe "$SQL_INSTANCE" --format='value(connectionName)')"
```

Deploy the container. This Dockerfile runs Apache on port 80, so pass `--port=80`.

```bash
gcloud run deploy "$SERVICE" \
  --image="$IMAGE" \
  --region="$REGION" \
  --platform=managed \
  --allow-unauthenticated \
  --port=80 \
  --add-cloudsql-instances="$INSTANCE_CONNECTION_NAME" \
  --set-env-vars="APP_ENV=production,DB_DATABASE=${DB_NAME},DB_USERNAME=${DB_USER},DB_SOCKET=/cloudsql/${INSTANCE_CONNECTION_NAME}" \
  --set-secrets="DB_PASSWORD=mymoney-db-password:latest,APP_SECRET=mymoney-app-secret:latest"
```

Open the service URL shown by the deploy command and test:

```text
https://YOUR-CLOUD-RUN-URL/health
https://YOUR-CLOUD-RUN-URL/app.php
```

## 8. Next Production Steps

- Replace demo credentials before real users.
- Use a custom domain and HTTPS from Cloud Run domain mapping.
- Keep Cloud SQL backups enabled.
- Set a Google Cloud budget alert before opening traffic.
- Consider removing public demo sample data for production.
