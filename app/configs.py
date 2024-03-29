import os
from datetime import timedelta


class Config(object):

    # App
    APP_NAME = os.getenv("APP_NAME")
    SECRET_KEY = os.getenv("SECRET_KEY")

    # Session
    # PERMANENT_SESSION_LIFETIME = timedelta(minutes=10)

    # Database
    MYSQL_HOST = os.getenv("MYSQL_HOST")
    MYSQL_USER = os.getenv("MYSQL_USER")
    MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")
    MYSQL_DB = os.getenv("MYSQL_DB")


class DevelopmentConfig(Config):

    # App
    APP_NAME = os.getenv("APP_NAME") or "Atlanta Beltline"

    # Database
    MYSQL_HOST = os.getenv("MYSQL_HOST") or "localhost"
    MYSQL_USER = os.getenv("MYSQL_USER") or "atlbeltline"
    MYSQL_DB = os.getenv("MYSQL_DB") or "atlbeltline"
