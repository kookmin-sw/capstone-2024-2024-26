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


#카메라 상태 켜져있으면1, 꺼져있으면 0
@app.route('/api/state', methods=['POST'])
def spfolks():
    doc_ref = db.collection("Camera").document('미래관 자율주행스튜디오')
    doc = doc_ref.get()
    dd = doc.to_dict()
    output = {'state' : dd['state']}
    return jsonify(output)


#혼잡도 정보 알려주는곳
@app.route('/api/info', methods=['POST'])
def qffdqgaf():
    
    doc_ref = db.collection("Camera").document('미래관 자율주행스튜디오')
    doc = doc_ref.get()
    dd = doc.to_dict()
    output = {'info' : dd['info']}
    return jsonify(output)


#라즈베리파이에서 이미지 받아서 알아서 파베 수정
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
                doc_ref.update({'info': 4,
                                'state' : 1})
            elif result['score'] >= 55:
                doc_ref.update({'info': 3,
                                'state' : 1})
            elif result['score'] >= 35:
                doc_ref.update({'info': 2,
                                'state' : 1})
            else:
                doc_ref.update({'info': 1,
                                'state' : 1})
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
    if not data or 'image' not in data:
        return jsonify({"error": "Invalid data"}), 400
    
    base64_image = data['image']# 이미지 인코딩된거
    myclass = data['class']  #강의실 0, club 1
    table = int(data['table']) #club일때 테이블 번호(0,1)
    location = data['location'] # 강의실 이름
    date = data['date'] #날짜(2024-05-12)
    time = data['time'] #시간(10-11)
    user = data['user'] #유저(문서 id)
    #여기서 user 문서 아이디 받아오기

    if myclass=='0':
        a = "소프트웨어융합대학_Classroom_queue"
        b = 'conferenceImage'
        c = "소프트웨어융합대학_Classroom"
    else:
        a= "소프트웨어융합대학_Club"
        b = 'clubRoomImage'

    get_doc_ref = db.collection(a).document(location)
    get_doc = get_doc_ref.get()
    dd = get_doc.to_dict()
    de_image = dd[b]

    #2. 입력 이미지디코딩
    #파베에있는 이미지
    default_image = base64.b64decode(de_image)
    image1 = Image.open(io.BytesIO(default_image)).convert('RGB')


    #입력으로 받은 이미지
    image_data = base64.b64decode(base64_image)
    image2 = Image.open(io.BytesIO(image_data)).convert('RGB')
        
        
    #3. classfication에 보내준 뒤 결과 받아오기
    result = classification(image1, image2)

    if result['score']==0:
        #애초에 강의실이든 동방이든 0이면 패널티 줘야됨
        doc_user = db.collection("users").document(user)
        docc = doc_user.get()
        penalty_value = docc.to_dict().get('penalty')
        doc_user.set({
            'penalty': penalty_value + 1,  # 원하는 필드 이름과 값을 설정
        }, merge=True)



    if myclass=='0':
        #여기서는 class에 저장
        doc_ref = db.collection(c).document(location)
        date_doc_ref = doc_ref.collection(date).document(time)
        date_doc_ref.set({
            'image': base64_image,  # 원하는 필드 이름과 값을 설정
        }, merge=True)
    else:
        #여기서는 club에 저장
        doc_ref = db.collection(a).document(location)
        date_doc_ref = doc_ref.collection(date).document(time)
        doc = date_doc_ref.get()
        if doc.exists:
            current_data = doc.to_dict()
            if current_data:
                tableData = current_data.get('tableData', [])


                # 배열의 0번 인덱스가 존재하고 사전 타입이면 이미지 정보 추가

                if len(tableData) > table:
                    if isinstance(tableData[table], dict):  # 인덱스 table의 요소가 사전인지 확인
                        tableData[table]['image'] = base64_image
                    else:
                        # table번 인덱스가 사전이 아니면 새로운 사전을 추가
                        tableData[table] = {'image': base64_image}
                else:
                    # 0번 인덱스가 없으면 새로운 사전을 추가
                    tableData.append({'image': base64_image})

                # 수정된 배열을 다시 Firestore 문서에 저장
                date_doc_ref.update({
                    'tableData': tableData
                })
    #     else:
    #         print("Document does not exist.")


    # return jsonify(result)


if __name__ == '__main__':
    #기존 코드
    # app.run(host='0.0.0.0', port=5000, debug=True)

    #멀티쓰레드 테스트
    serve(app, host='0.0.0.0', port=5000, threads=4)

    #aws에서는 gunicorn --workers 4 --bind 0.0.0.0:5000 app:app 이거 사용할 예정
    #4개 멀티쓰레드 구성



