#!/bin/bash
PROJECT=$(gcloud config get-value project) && \
gcloud services enable aiplatform.googleapis.com && \
gcloud iam service-accounts create gemini-sa \
  --display-name="Gemini CLI" 2>/dev/null; \
gcloud projects add-iam-policy-binding $PROJECT \
  --member="serviceAccount:gemini-sa@${PROJECT}.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user" --quiet && \
gcloud iam service-accounts keys create ~/.gemini/sa-key.json \
  --iam-account=gemini-sa@${PROJECT}.iam.gserviceaccount.com && \
cat > ~/.gemini/.env << EOF
GOOGLE_APPLICATION_CREDENTIALS=$HOME/.gemini/sa-key.json
GOOGLE_CLOUD_PROJECT=${PROJECT}
GOOGLE_CLOUD_LOCATION=global
EOF
cat > ~/.gemini/settings.json << 'EOF'
{
  "security": {
    "auth": {
      "selectedType": "vertex-ai"
    }
  }
}
EOF
