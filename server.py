from flask import Flask, request, Response

app = Flask(__name__)

@app.route('/video_feed', methods=['POST'])
def video_feed():
    frame_data = request.files['frame'].read()  # 요청 컨텍스트 내에서 데이터 읽기

    def generate(frame_data):
        while True:
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame_data + b'\r\n')
    
    return Response(generate(frame_data), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/')
def index():
    return """
    <html>
    <head>
        <title>Live Stream</title>
    </head>
    <body>
        <h1>Live Camera Stream</h1>
        <img src="/video_feed">
    </body>
    </html>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)