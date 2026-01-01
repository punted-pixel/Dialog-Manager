from flask import Blueprint

blue_print = Blueprint('main', __name__)
# A simple Hello World Page
@blue_print.route('/')
@blue_print.route('/hello')
def hello():
    return 'Hello, World!'
 