from flask import Flask, request, jsonify, render_template
import base64
from PIL import Image
import io
from count import count
from image_class import classification
from waitress import serve
app = Flask(__name__)


@app.route('/')
def gogo():
    return "서버실행 테스트"

@app.route('/test')
def index():
    return "동작완료"


#진짜 라즈베리파이랑 쓸놈
@app.route('/upload', methods=['POST'])
def upload():
    data = request.get_json()
    if data and 'image' in data:
        # Base64 문자열을 바이트로 디코딩
        image_data = base64.b64decode(data['image'])
        # BytesIO를 통해 이미지로 변환
        image = Image.open(io.BytesIO(image_data))
    else:
        #파베에 카메라 작동안한다고 설정
        #이러면 flutter도 알아서 작동안함
        return None

    info = "자주스"
    result = count(image, info)

    #파베에 result값 저장

    # 얘는 테스트요용
    return jsonify(result)



# 공유공간 정보는 계속 받아와서 따로 계속 혼잡도 리스트로 만들어뒀다가 
# 요청들어오면 보내주기 
@app.route('/api/count' , methods=['POST'])  #, methods=['POST']
def handle_request():
    data = request.get_json()
    if not data or 'image' not in data or 'info' not in data:
        return jsonify({"error": "Invalid data"}), 400
    

    # 이미지 데이터와 추가 정보를 추출
    base64_image = data['image']
    info = data['info']

    
    # 이 코드는 진짜 인코딩 된 값 불러 올때 사용
    image_data = base64.b64decode(base64_image)
    image = Image.open(io.BytesIO(image_data)).convert('RGB')
    result = count(image, info)


    # 결과에 따라 firebase에 저장 or flutter에 재요청
    # 웹에도 정보 보내야 될 수도 이;ㅆ음...
    
    # 이건 진짜 사용할때
    return jsonify(result)


    # 이건 테스트용
    # return render_template('display.html', result=result)



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


    result = classification(image, info)
    
    # 이것도 원래는 이미지 넣어줘야됨
    #일단 나중에

    # 여기서 데베 저장까지
    #이 코드는 ㄹㅇ 연동할때
    return jsonify(result)

    #테스트용
    # return render_template('display.html', result=result["score"])

if __name__ == '__main__':
    #기존 코드
    # app.run(host='0.0.0.0', port=5000, debug=True)

    #멀티쓰레드 테스트
    serve(app, host='0.0.0.0', port=5000, threads=2)

    #aws에서는 gunicorn --workers 4 --bind 0.0.0.0:5000 app:app 이거 사용할 예정
    #4개 멀티쓰레드 구성




# 라즈베리파이 코드
#초기화 시간만 바꾸면 됨
# import io
# import time
# import base64
# import requests
# from picamera import PiCamera

# # Flask 서버의 URL
# url = 'http://your-aws-server-ip:5000/upload'

# def capture_and_send():
#     with PiCamera() as camera:
#         camera.resolution = (640, 480)  # 해상도 설정
#         time.sleep(2)  # 카메라 초기화 시간
#         stream = io.BytesIO()
        
#         for _ in camera.capture_continuous(stream, 'jpeg', use_video_port=True):
#             # 스트림 포인터를 처음으로 되돌림
#             stream.seek(0)
#             # Base64로 인코딩
#             image_encoded = base64.b64encode(stream.read()).decode('utf-8')
#             # 데이터 전송
#             response = requests.post(url, json={'image': image_encoded})
#             print('Image sent, server responded:', response.text)

#             # 스트림을 리셋하여 다음 캡처를 준비
#             stream.seek(0)
#             stream.truncate()
            
#             # 이미지를 몇 초마다 캡처할지 설정
#             time.sleep(5)  # 예: 5초마다 이미지 캡처

# if __name__ == '__main__':
#     capture_and_send()