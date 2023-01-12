from pymongo import MongoClient, ReturnDocument
from os import environ as env
from bson.dbref import DBRef
from bson.objectid import ObjectId
from fastapi import HTTPException
from dotenv import load_dotenv
load_dotenv()


def mongoClient():
    try:
        return MongoClient(env['MONGODB_URI'])
    except Exception:
        raise HTTPException(status_code=500,
                            detail='Database connection error')


def add_entry(data_dict: dict):
    client = mongoClient()
    users = client['authonia']['users']
    auth = client['authonia']['auth']
    secret = data_dict.get('secret', '').upper().replace(' ', '')
    if secret == '':
        raise HTTPException(status_code=400,
                            detail='Secret is required')
    with client.start_session() as session:
        session.start_transaction()
        try:
            auth_entry = auth.insert_one({
                'user': data_dict.get('user', ''),
                'secret': secret,
                'issuer': data_dict.get('issuer', ''),
                'totp': data_dict.get('totp', True),
            }, session=session)
            modified = users.find_one_and_update({
                'username': data_dict.get('username', ''),
                'password': data_dict.get('password', '')
            },
                {
                "$push": {'auth': auth_entry.inserted_id}
            },
                return_document=ReturnDocument.AFTER,
                upsert=False,
                session=session
            )
            if modified:
                session.commit_transaction()
                return str(auth_entry.inserted_id)
            else:
                session.abort_transaction()
                raise HTTPException(status_code=401,
                                    detail='Invalid username/password')
        except Exception as e:
            session.abort_transaction()
            raise HTTPException(status_code=500,
                                detail=str(e))


def get_entries(data_dict: dict):
    client = mongoClient()['authonia']
    users = client['users']
    user = users.find_one({
        'username': data_dict.get('username', ''),
        'password': data_dict.get('password', '')
    })
    if user is None:
        print('Invalid username/password')
        raise HTTPException(status_code=401,
                            detail='Invalid username/password')
    auth_ids = user['auth']
    auth_docs = []
    for auth_id in auth_ids:
        try:
            ref = DBRef('auth', auth_id, 'authonia')
            auth_doc: dict = client.dereference(ref)
            auth_doc['_id'] = str(auth_doc['_id'])
            auth_docs.append(auth_doc)
        except Exception:
            pass
    return auth_docs


def register_user(data_dict: dict):
    try:
        if len(data_dict.get('username', '')) < 4 or len(data_dict.get('password', '')) < 4:
            return {
                'error': True,
                'message': 'Username/Password must be atleast 4 characters long'
            }
        client = mongoClient()['authonia']
        users = client['users']
        user = users.find_one({
            'username': data_dict.get('username'),
        })
        if user:
            return {
                'error': True,
                'message': 'User already exists'
            }
        users.insert_one({
            'username': data_dict.get('username'),
            'password': data_dict.get('password'),
            'auth': []
        })
        return {
            'error': False,
            'message': 'User created successfully'
        }
    except Exception as e:
        return {
            'error': True,
            'message': str(e)
        }


def remove_entry(data_dict: dict):
    client = mongoClient()
    users = client['authonia']['users']
    auth = client['authonia']['auth']
    auth_id = data_dict.get('auth_id', '')
    if auth_id == '':
        raise HTTPException(status_code=400,
                            detail='Auth ID is required')
    with client.start_session() as session:
        session.start_transaction()
        try:
            user = users.find_one_and_update(
                {
                    'username': data_dict.get('username', ''),
                    'password': data_dict.get('password', '')
                },
                {"$pull":
                 {
                     "auth": ObjectId(auth_id)
                 }
                 },
                return_document=ReturnDocument.AFTER,
                session=session
            )
            if not user:
                session.abort_transaction()
                raise HTTPException(status_code=401,
                                    detail='Invalid username/password')
            auth_result = auth.delete_one(
                {
                    "_id": ObjectId(auth_id)
                }, session=session
            )

            if auth_result.deleted_count == 1:
                session.commit_transaction()
                return {
                    'error': False,
                    'message': 'Auth removed sucessfully'
                }
            else:
                session.abort_transaction()
                return {
                    'error': True,
                    'message': 'Auth not found! Maybe it was already deleted.'
                }
        except Exception as e:
            session.abort_transaction()
            return {
                'error': True,
                'message': str(e)
            }
