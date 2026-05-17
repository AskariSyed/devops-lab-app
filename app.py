import os
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    build_label = os.environ.get("BUILD_NUMBER") or os.environ.get("GIT_COMMIT", "local")
    return render_template("index.html", build_label=build_label)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)