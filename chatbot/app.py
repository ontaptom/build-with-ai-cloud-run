import os

import google.auth
from google.auth.transport.requests import Request
from flask import Flask, render_template, request, jsonify
from google import genai

app = Flask(__name__)

_, project = google.auth.default(request=Request())

model = os.environ.get("MODEL", "gemini-3.1-flash-lite-preview")
location = os.environ.get("VERTEX_LOCATION", "global")

client = genai.Client(vertexai=True, project=project, location=location)


@app.route("/")
def index():
    return render_template("index.html", model=model)


@app.route("/chat", methods=["POST"])
def chat():
    user_message = request.json.get("message", "")
    if not user_message.strip():
        return jsonify({"error": "Empty message"}), 400

    try:
        response = client.models.generate_content(
            model=model,
            contents=user_message,
        )
        return jsonify({"response": response.text})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
