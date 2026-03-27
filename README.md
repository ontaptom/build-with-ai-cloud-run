# Build with AI - Cloud Run workshop

Hands-on workshop: deploy your first apps to Google Cloud Run, from a simple hello world to an AI-powered chatbot using Vertex AI and Gemini.

> Materiały w języku angielskim, warsztaty prowadzone po polsku.

## What you'll learn

By the end of this workshop you will have:

- Deployed a pre-built container image to Cloud Run via the console
- Built and deployed your own Flask app using `gcloud` CLI
- Explored Cloud Build and Artifact Registry behind the scenes
- Created a service account with proper IAM roles
- Deployed an AI chatbot powered by Gemini on Vertex AI
- (Bonus) Used Gemini CLI to modify your app directly from Cloud Shell

## Services you'll touch

Cloud Run, Cloud Build, Artifact Registry, Cloud Shell, IAM & Service Accounts, Vertex AI API, (bonus) Gemini CLI.

## Prerequisites

- A Google account
- A modern web browser
- That's it - everything runs in Cloud Shell

## Setup

### 1. Activate your credits

Go to [cloud.google.com/try-gcp](https://cloud.google.com/try-gcp) and apply your trial credits. This may take a few minutes.

### 2. Open Cloud Shell

Navigate to [console.cloud.google.com](https://console.cloud.google.com) and click the Cloud Shell icon in the top-right corner.

### 3. Clone this repo

```bash
git clone https://github.com/ontaptom/build-with-ai-cloud-run.git
cd build-with-ai-cloud-run
```

## Exercises

### Exercise 1 - Deploy a pre-built image from the console

No code needed. Deploy a ready-made container image directly from the Cloud Run console.

1. Go to [Cloud Run](https://console.cloud.google.com/run) in the console
2. Click **Create service**
3. Use the sample container image: `us-docker.pkg.dev/cloudrun/container/hello`
4. Set authentication to **Allow unauthenticated invocations**
5. Click **Create** and wait for the deployment
6. Open the generated URL - you should see a working page

You just deployed your first Cloud Run service.

### Exercise 2 - Build and deploy your own app

Now let's deploy your own Flask app using the `gcloud` CLI.

```bash
cd hello
```

Take a look at the code - `app.py`, `templates/index.html`, `static/style.css`, and the `Dockerfile`.

**Deploy to Cloud Run:**

```bash
gcloud run deploy hello \
  --source . \
  --region europe-west1 \
  --allow-unauthenticated
```

This single command does a lot behind the scenes:
- Sends your code to **Cloud Build** which builds a container image
- Stores the image in **Artifact Registry**
- Deploys the image to **Cloud Run**

Open the URL from the output. You should see a gruvbox-themed hello page.

**Try changing the greeting with an environment variable:**

```bash
gcloud run services update hello \
  --region europe-west1 \
  --set-env-vars NAME=YourName
```

Refresh the page - notice the name changed without a rebuild.

**Explore what happened:**
- Go to [Cloud Build > History](https://console.cloud.google.com/cloud-build/builds) to see your build
- Go to [Artifact Registry](https://console.cloud.google.com/artifacts) to see the container image

### Exercise 3 - Deploy an AI chatbot with Vertex AI

This exercise introduces service accounts, IAM roles, and the Vertex AI API.

```bash
cd ../chatbot
```

**Step 1 - Enable the Vertex AI API:**

```bash
gcloud services enable aiplatform.googleapis.com
```

**Step 2 - Create a service account:**

```bash
gcloud iam service-accounts create chatbot-sa \
  --display-name="Chatbot Service Account"
```

**Step 3 - Grant the Vertex AI User role:**

```bash
gcloud projects add-iam-policy-binding $(gcloud config get project) \
  --member="serviceAccount:chatbot-sa@$(gcloud config get project).iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

**Step 4 - Deploy with the service account:**

```bash
gcloud run deploy chatbot \
  --source . \
  --region europe-west1 \
  --allow-unauthenticated \
  --service-account=chatbot-sa@$(gcloud config get project).iam.gserviceaccount.com
```

Open the URL and start chatting. Your app uses Gemini via Vertex AI - no API keys in the code. The service account's IAM role handles authentication automatically.

**How it works:**
- The code uses `google.auth.default()` to get the project ID from the metadata server
- The `google-genai` SDK connects to Vertex AI using the service account's identity
- Default model is `gemini-3.1-flash-lite-preview` - you can change it with an env var:

```bash
gcloud run services update chatbot \
  --region europe-west1 \
  --set-env-vars MODEL=gemini-2.5-flash
```

### Exercise 4 (bonus) - Modify your app with Gemini CLI

Cloud Shell comes with Gemini CLI pre-installed. Let's use it to modify the chatbot.

Let's set up Gemini CLI with Gemini3:
```bash
. ../gemini-cli/set-gemini.sh
```

This will set up an auth via service account. It will need 2-3 minutes to update permissions.

```bash
cd ../chatbot
gemini
```

Try prompts like:
- "Change the color scheme to a dark blue theme"
- "Add a system prompt that makes the bot respond as a pirate"
- "Add image generation - if the user message starts with 'generate image:' use Imagen to create and display an image"

**Test locally before deploying:**

```bash
# In Cloud Shell, Gemini CLI can help you test too
pip install -r requirements.txt
python app.py
```

Click **Web Preview** (port 8080) in Cloud Shell to see your changes.

When you're happy, deploy:

```bash
gcloud run deploy chatbot \
  --source . \
  --region europe-west1 \
  --allow-unauthenticated \
  --service-account=chatbot-sa@$(gcloud config get project).iam.gserviceaccount.com
```

## Why Cloud Run + Vertex AI instead of AI Studio?

Google AI Studio is great for quick prototyping. But:
- AI Studio free tier has per-user quota limits that can block you mid-hackathon
- Cloud Run + Vertex AI uses your tryGCP credits - much higher limits
- You learn the cloud-native way: your code has no API keys, authentication is handled by IAM
- You get a real deployed app with a URL you can share

If you hit AI Studio quota limits during the hackathon this afternoon, you have a working alternative ready to go.

## Repo structure

```
build-with-ai-cloud-run/
├── README.md
├── hello/          # Exercise 2 - Flask hello world
│   ├── app.py
│   ├── templates/
│   ├── static/
│   ├── requirements.txt
│   └── Dockerfile
├── chatbot/        # Exercise 3 - Gemini chatbot
│   ├── app.py
│   ├── templates/
│   ├── static/
│   ├── requirements.txt
│   └── Dockerfile
└── docs/
    └── cheatsheet.md
```

## Useful links

- [Cloud Run documentation](https://cloud.google.com/run/docs)
- [Google Gen AI SDK](https://googleapis.github.io/python-genai/)
- [Vertex AI pricing](https://cloud.google.com/vertex-ai/pricing)
- [Gemini CLI documentation](https://cloud.google.com/gemini/docs/gemini-cli)
