#라즈베리파이의 코드
import subprocess
import requests
import time
import logging

server_url = 'http://3.39.102.188:5000/image'
logging.basicConfig(level=logging.INFO)

try:
    while True:
        subprocess.run(["libcamera-still", "-o", "temp.jpg", "-t", "1000", "--nopreview"], check=True)

        with open("temp.jpg", "rb") as img:
            files = {
            'frame': ('temp.jpg', img.read(), 'image/jpeg'),
            'info': ('info.txt', '0')
            }
            
        response = requests.post(server_url, files=files)
        logging.info(f"Server response: {response.text}")

        time.sleep(10)
except Exception as e:
    logging.error(f"An error occurred: {e}")