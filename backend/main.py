from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
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

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://authonia.vercel.app"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get('/')
def root():
    """
    The root endpoint.
    Returns information about the API.
    """
    return app.openapi()['info']


@app.post('/add_entry')
async def add_entry(req: Request):
    """
    Add a new entry to the database.
    """
    try:
        data_dict = await req.json()
        return api.add_entry(data_dict)
    except Exception as e:
        print(e)
        return HTTPException(status_code=500, detail=str(e))


@app.post('/get_entries')
async def get_entries(req: Request):
    """
    Get a list of entries from the database.
    """
    try:
        data_dict = await req.json()
        return api.get_entries(data_dict)
    except Exception as e:
        print(e)
        return HTTPException(status_code=500, detail=str(e))


@app.post('/register_user')
async def register_user(req: Request):
    """
    Register a new user.
    """
    try:
        data_dict = await req.json()
        return api.register_user(data_dict)
    except Exception as e:
        print(e)
        return HTTPException(status_code=500, detail=str(e))


@app.post('/remove_entry')
async def remove_entry(req: Request):
    """
    Remove an entry from the database.
    """
    try:
        data_dict = await req.json()
        return api.remove_entry(data_dict)
    except Exception as e:
        print(e)
        return HTTPException(status_code=500, detail=str(e))
