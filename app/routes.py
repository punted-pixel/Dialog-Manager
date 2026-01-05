from flask import Blueprint
from flask import render_template

blue_print = Blueprint('main', __name__)
# A simple Hello World Page
@blue_print.route('/')
def index():
    user = {'username': 'sidious'} 
    return render_template('index.html', title='Home', user=user)

@blue_print.route('/health')
def health():
    return 'ok', 200