# process_image.py
# 
import base64
from PIL import Image
import io

def process_image(base64_image, info):
    # Base64 문자열을 이미지 데이터로 디코딩
    image_data = base64.b64decode(base64_image)
    image = Image.open(io.BytesIO(image_data))

    # 여기서 이미지를 처리 (예시: 이미지 크기 확인)
    width, height = image.size

    # 처리 결과와 함께 추가 정보 반환
    return {
        "width": width,
        "height": height,
        "info": info
    }
