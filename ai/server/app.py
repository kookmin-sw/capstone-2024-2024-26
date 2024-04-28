from flask import Flask, jsonify
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import subprocess

cred = credentials.Certificate('./ai/server/auth/firebase_auth.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

app = Flask(__name__)

@app.route('/')
def index():
    return "서버실행 테스트"


@app.route('/api/information', methods=['POST'])
def class_information():
    try:
        
        result = subprocess.run(['python', './ai/information/information_model.py'], text=True, capture_output=True)
        

        #이런식으로 json 으로 보내줄 예정
        # return jsonify(response)
        return f"Script executed. Output:\n{result.stdout}"
    except Exception as e:
        return str(e)
    

@app.route('/classification')
def image_classification():
    try:
        # subprocess.run을 사용하여 외부 스크립트 실행
        # 예를 들어, 'script.py'가 실행하고자 하는 스크립트라면
        result = subprocess.run(['python', './ai/classification/image_model.py'], text=True, capture_output=True)
        # 실행 결과 반환
        return f"Script executed. Output:\n{result.stdout}"
    except Exception as e:
        return str(e)

if __name__ == '__main__':
    app.run(debug=True)
