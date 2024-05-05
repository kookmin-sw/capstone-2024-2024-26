from flask import Flask, request, jsonify, render_template
import base64
from PIL import Image
import io
from count import count
from image_class import classification

app = Flask(__name__)

@app.route('/')
def gogo():
    return "서버실행 테스트"

@app.route('/test')
def index():
    return "동작완료"

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
    app.run(host='0.0.0.0', port=5000, debug=True)