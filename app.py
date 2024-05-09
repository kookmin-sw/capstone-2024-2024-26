from flask import Flask, request, jsonify, render_template
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import base64
from PIL import Image
import io
import os
from count import count
from image_class import classification
from waitress import serve
from dotenv import load_dotenv


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


@app.route('/image', methods=['POST'])
def receive_image():
    if 'frame' in request.files in request.files:
        image_file = request.files['frame']
        image = Image.open(image_file.stream)  # 파일 스트림에서 이미지 로드
        
        info = request.files['info'].read()
        result = count(image)
        #파베에 혼잡도만 변경하면댐
        doc_ref = db.collection("camera").document(info)
        doc = doc_ref.get()
        if doc.exists:
            if result['score'] >=75:
                #제일혼잡
                doc_ref.update({'info': 4})
            elif result['score'] >= 55:
                doc_ref.update({'info': 3})
            elif result['score'] >= 35:
                doc_ref.update({'info': 2})
            else:
                doc_ref.update({'info': 1})
        return result, 200
    else:
        #파베에 상태 flase로 변경
        doc_ref = db.collection("Camera").document('미래관 자율주행스튜디오')
        doc = doc_ref.get()
        if doc.exists:
            doc_ref.update({'state': 0})
            return jsonify({"success": "Document updated successfully"}), 200
        else:
            return jsonify({"error": "No such document!"}), 404



#이미지 청소상태 체크
@app.route('/api/class' , methods=['POST'])
def classi():

    data = request.get_json()
    if not data or 'image' not in data or 'info' not in data:
        return jsonify({"error": "Invalid data"}), 400
    
    base64_image = data['image']
    info = data['info']

    
    # 이 코드는 진짜 인코딩 된 값 불러 올때 사용
    image_data = base64.b64decode(base64_image)
    image = Image.open(io.BytesIO(image_data)).convert('RGB')


    result = classification(image)
    if result['score'] ==1:
        #이미지 인코딩해서 파베에 저장
        # info로 파베 찾으러 가야됨
        #이후 값 잘 왔다는 결과 보내줌
        return 0
    return jsonify(result)


    #테스트용
    # return render_template('display.html', result=result["score"])

if __name__ == '__main__':
    #기존 코드
    # app.run(host='0.0.0.0', port=5000, debug=True)

    #멀티쓰레드 테스트
    serve(app, host='0.0.0.0', port=5000, threads=4)

    #aws에서는 gunicorn --workers 4 --bind 0.0.0.0:5000 app:app 이거 사용할 예정
    #4개 멀티쓰레드 구성



