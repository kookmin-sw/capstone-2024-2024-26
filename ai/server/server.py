# app.py
from flask import Flask, request, jsonify
import subprocess
import json
from process_image import process_image
from count import count

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def handle_request():
    data = request.get_json()
    if not data or 'image' not in data or 'info' not in data:
        return jsonify({"error": "Invalid data"}), 400
    
    # 이미지 데이터와 추가 정보를 추출
    base64_image = data['image']
    info = data['info']
    
    # 외부 스크립트로 데이터를 처리
    # result = process_image(base64_image, info)
    result = count(base64_image, info)
    # 처리 결과를 JSON 형태로 반환
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True)

