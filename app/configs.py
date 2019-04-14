import os


class Config(object):

    APP_NAME = os.getenv("APP_NAME") or "Atlanta Beltline"
    SECRET_KEY = os.getenv("SECRET_KEY") or os.urandom(32)
