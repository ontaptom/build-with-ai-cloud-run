# Cheatsheet

Quick reference for the workshop. Keep this open in a separate tab.

## gcloud basics

```bash
# Check your current project
gcloud config get project

# Set your project (if needed)
gcloud config set project YOUR_PROJECT_ID

# List enabled APIs
gcloud services list --enabled
```

## Cloud Run

```bash
# Deploy from source (builds and deploys in one step)
gcloud run deploy SERVICE_NAME \
  --source . \
  --region europe-west1 \
  --allow-unauthenticated

# Update environment variables (no rebuild)
gcloud run services update SERVICE_NAME \
  --region europe-west1 \
  --set-env-vars KEY=VALUE

# Update with a different service account
gcloud run services update SERVICE_NAME \
  --region europe-west1 \
  --service-account=SA_NAME@PROJECT_ID.iam.gserviceaccount.com

# View service details
gcloud run services describe SERVICE_NAME --region europe-west1

# List all deployed services
gcloud run services list

# View logs
gcloud run services logs read SERVICE_NAME --region europe-west1
```

## Service accounts & IAM

```bash
# Create a service account
gcloud iam service-accounts create SA_NAME \
  --display-name="Display Name"

# Grant a role to a service account
gcloud projects add-iam-policy-binding $(gcloud config get project) \
  --member="serviceAccount:SA_NAME@$(gcloud config get project).iam.gserviceaccount.com" \
  --role="roles/ROLE_NAME"

# List service accounts
gcloud iam service-accounts list
```

### Common roles for this workshop

| Role | What it does |
|------|-------------|
| `roles/aiplatform.user` | Call Vertex AI APIs (Gemini, etc.) |
| `roles/run.invoker` | Invoke a Cloud Run service |
| `roles/storage.objectViewer` | Read from Cloud Storage |

## Enable APIs

```bash
# Vertex AI (required for chatbot exercise)
gcloud services enable aiplatform.googleapis.com

# Cloud Build (usually enabled by default)
gcloud services enable cloudbuild.googleapis.com

# Artifact Registry (usually enabled by default)
gcloud services enable artifactregistry.googleapis.com
```

## Cloud Shell tips

```bash
# Local testing - run your Flask app
pip install -r requirements.txt
python app.py
# Then click "Web Preview" button (port 8080) in Cloud Shell toolbar

# Open the built-in code editor
cloudshell edit app.py
```

## Gemini CLI (bonus exercise)

```bash
# Start Gemini CLI (pre-installed in Cloud Shell)
gemini

# Example prompts to try:
# "Change the color scheme to dark blue"
# "Add a system prompt that makes the bot respond as a pirate"
# "Add a button that clears the chat history"
```

## Useful URLs

| What | Where |
|------|-------|
| Cloud Console | [console.cloud.google.com](https://console.cloud.google.com) |
| Cloud Run services | [console.cloud.google.com/run](https://console.cloud.google.com/run) |
| Cloud Build history | [console.cloud.google.com/cloud-build/builds](https://console.cloud.google.com/cloud-build/builds) |
| Artifact Registry | [console.cloud.google.com/artifacts](https://console.cloud.google.com/artifacts) |
| IAM & Admin | [console.cloud.google.com/iam-admin](https://console.cloud.google.com/iam-admin) |
| Vertex AI | [console.cloud.google.com/vertex-ai](https://console.cloud.google.com/vertex-ai) |

## Troubleshooting

**"Permission denied" or "403" when deploying:**
Check that Cloud Build API is enabled and your account has the Editor role.

**Chatbot returns "Error" on every message:**
- Is the Vertex AI API enabled? `gcloud services enable aiplatform.googleapis.com`
- Does the service account have the right role? Check with `gcloud projects get-iam-policy $(gcloud config get project)`
- Did you deploy with `--service-account`?

**Build takes too long or fails:**
Check the build logs: `gcloud builds list` then `gcloud builds log BUILD_ID`

**"Quota exceeded" on Vertex AI:**
Try switching to a cheaper model: `--set-env-vars MODEL=gemini-2.5-flash-lite`
