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
from flask_cors import CORS
import base64
import json
from PIL import Image
import io

# 이미지 파일 경로 설정
image_path = "./test_image/1.jpg" #강의실

# 이미지 파일을 열고 Base64로 인코딩
with Image.open(image_path) as image:

    resized_image = image.resize((1600, 1200), Image.Resampling.LANCZOS)

    width, height = resized_image.size
    print(f"이미지의 크기: 너비 {width} 픽셀, 높이 {height} 픽셀")
    
    buffered = io.BytesIO()
    resized_image.save(buffered, format="JPEG")  # 이미지 형식에 맞게 JPEG 또는 PNG 등을 설정
    img_str = base64.b64encode(buffered.getvalue()).decode('utf-8')
    print("인코딩된 이미지 문자열의 길이:", len(img_str))

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

a= "소프트웨어융합대학_Club"
#이게 원래는 테이블 번호 입력받으면 내가 쓴 테이블의 이미지랑 비교하는거
get_doc_ref = db.collection(a).document('미래관 605-5호')
get_doc = get_doc_ref.get()
dd = get_doc.to_dict()
mytable = dd.get('tableList', [])

if isinstance(mytable[0], dict):  # 인덱스 table의 요소가 사전인지 확인
    mytable[0]['image'] = img_str
else:
    # table번 인덱스가 사전이 아니면 새로운 사전을 추가
    mytable[0] = {'image': img_str}


get_doc_ref.update({
    'tableList': mytable
})