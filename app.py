from flask import Flask, render_template, request

app = Flask(__name__)

# @app.route('/')
# def home():
#     return "ㄱㄱ"


# @app.route('/test')
# def test():
#     return "테스트 동작완료"

@app.route('/')
def home():
    return render_template("index.html")


@app.route('/test', methods=["GET", "POST"])
def test():
    if request.method == "POST":
        try:
            number = int(request.form['number'])
            result = number + 1
            return render_template("result.html", result=result)
        except ValueError:
            return "Invalid input. Please enter a number."
    return render_template("test.html")


if __name__ == '__main__':
    app.run('0.0.0.0', port=5000,debug=True)