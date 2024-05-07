from flask import Flask, jsonify
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import subprocess
from flask import Flask, request, jsonify
import base64
from PIL import Image
import io
from dotenv import load_dotenv
import os
from count import count
from image_class import classification

load_dotenv() 

firebase_config = {
    "type": os.getenv("FIREBASE_TYPE"),
    "project_id": os.getenv("FIREBASE_PROJECT_ID"),
    "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
    "private_key": os.getenv("FIREBASE_PRIVATE_KEY").replace('\\n', '\n'),
    "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
    "client_id": os.getenv("FIREBASE_CLIENT_ID"),
    "auth_uri": os.getenv("FIREBASE_AUTH_URI"),
    "token_uri": os.getenv("FIREBASE_TOKEN_URI"),
    "auth_provider_x509_cert_url": os.getenv("FIREBASE_AUTH_PROVIDER_X509_CERT_URL"),
    "client_x509_cert_url": os.getenv("FIREBASE_CLIENT_X509_CERT_URL")
}

cred = credentials.Certificate(firebase_config)
firebase_admin.initialize_app(cred)
db = firestore.client()

app = Flask(__name__)

@app.route('/')
def gogo():
    return "서버실행 테스트"

@app.route('/test')
def index():
    return "동작완료"

# 공유공간 정보는 계속 받아와서 따로 계속 혼잡도 리스트로 만들어뒀다가 
# 요청들어오면 보내주기 
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



#이미지 청소상태 체크
@app.route('/api/class', methods=['POST'])
def classi():
    result = classification()
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
