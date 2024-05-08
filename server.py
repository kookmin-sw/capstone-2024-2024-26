from flask import Flask, request, Response, render_template_string
import threading

app = Flask(__name__)
frame_data = None
frame_lock = threading.Lock()

@app.route('/video_feed', methods=['POST', 'GET'])
def video_feed():
    global frame_data
    if request.method == 'POST':
        frame_data = request.files['frame'].read()
        return "Frame received", 200
    elif request.method == 'GET':
        def generate():
            while True:
                with frame_lock:
                    if frame_data:
                        yield (b'--frame\r\n'
                               b'Content-Type: image/jpeg\r\n\r\n' + frame_data + b'\r\n')
        return Response(generate(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/')
def index():
    html = """
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
    return render_template_string(html)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, threaded=True)
