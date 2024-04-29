from flask import Flask, jsonify
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import subprocess
from flask import Flask, request, jsonify
import base64
from PIL import Image
import io
import os
from count import count
from image_class import classification

cred = credentials.Certificate('./ai/server/auth/firebase_auth.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

app = Flask(__name__)

@app.route('/')
def index():
    return "서버실행 테스트"

@app.route('/api/count', methods=['POST'])
def handle_request():
    data = request.get_json()
    if not data or 'image' not in data or 'info' not in data:
        return jsonify({"error": "Invalid data"}), 400
    



    # 이미지 데이터와 추가 정보를 추출
    base64_image = data['image']
    info = data['info']
    

    image_data = base64.b64decode(base64_image)
    image = Image.open(io.BytesIO(image_data)).convert('RGB')


    result = count(image, info)
    # 결과에 따라 firebase에 저장 or flutter에 재요청
    
    return jsonify(result)


@app.route('/api/class', methods=['POST'])
def classi():
    result = classification()
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True)
