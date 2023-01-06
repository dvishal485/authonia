from fastapi import FastAPI
import json
import api

app = FastAPI(
    title="authonia",
    description="A simple cloud 2FA service",
    version="0.1.0",
    contact={
        "name": "Vishal Das",
        "url": "https://github.com/dvishal485",
        "email": "dvishal485@gmail.com",
    },
    license_info={
        "name": "Apache 2.0",
        "url": "https://www.apache.org/licenses/LICENSE-2.0.html",
    },
)


@app.get('/')
def root():
    return app.openapi()['info']


@app.post('/add_entry')
def add_entry(data: str):
    try:
        data_dict: dict = json.loads(data)
        return api.add_entry(data_dict)
    except json.JSONDecodeError:
        return {'error': 'invalid json'}


@app.post('/get_entries')
def get_entries(data: str):
    try:
        data_dict: dict = json.loads(data)
        return api.get_entries(data_dict)
    except json.JSONDecodeError:
        return {'error': 'invalid json'}


@app.post('/register_user')
def register_user(data: str):
    try:
        data_dict: dict = json.loads(data)
        return api.register_user(data_dict)
    except json.JSONDecodeError:
        return {'error': 'invalid json'}


@app.post('/remove_entry')
def remove_entry(data: str):
    try:
        data_dict: dict = json.loads(data)
        return api.remove_entry(data_dict)
    except json.JSONDecodeError:
        return {'error': 'invalid json'}
