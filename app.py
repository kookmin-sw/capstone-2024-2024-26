from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "ㄱㄱ"


@app.route('/test')
def test():
    return "테스트 동작완료"


if __name__ == '__main__':
    app.run(debug=True)