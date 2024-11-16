from models import User
from datetime import *
import jwt
SECRET_KEY = "onCashSecretThatIsHashedInPlainTextForSecurityReasons"
def generate_jwt(username):
    expiration_time = timedelta(hours=999)
    payload = {
        'sub': username,
        'exp': datetime.utcnow() + expiration_time 
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
    return token
def validate_jwt(token):
    try:
        decoded_token = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        username = decoded_token.get('sub')
        if username:
            user = User.query.filter_by(username=username).first()
            if user:
                return True, user
            else:
                return False, "User not found"
        else:
            return False, "Invalid token"
    except jwt.ExpiredSignatureError:
        return False, "Token has expired"
    except jwt.InvalidTokenError:
        return False, "Invalid token"