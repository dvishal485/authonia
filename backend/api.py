from pymongo import MongoClient, ReturnDocument
from os import environ as env
from bson.dbref import DBRef
from bson.objectid import ObjectId
from dotenv import load_dotenv
load_dotenv()


def mongodb_connect():
    return MongoClient(env['MONGODB_URI'])['authonia']


def add_entry(data_dict: dict):
    try:
        client = mongodb_connect()
        users = client['users']
        auth = client['auth']
        entry = auth.insert_one({
            'user': data_dict.get('user', ''),
            'secret': data_dict.get('secret'),
            'issuer': data_dict.get('issuer', ''),
            'totp': data_dict.get('totp', True),
        })
        document = users.find_one_and_update({
            'username': data_dict.get('username', ''),
            'password': data_dict.get('password', ''),
        },
            {
            "$push": {'auth': entry.inserted_id}
        },
            return_document=ReturnDocument.AFTER
        )
        return document['auth']
    except Exception as e:
        print(e)
        return None


def get_entries(data_dict: dict):
    try:
        client = mongodb_connect()
        users = client['users']
        user = users.find_one({
            'username': data_dict.get('username', ''),
            'password': data_dict.get('password', '')
        })
        if not user:
            return []
        auth_ids = user['auth']
        auth_docs = []
        for auth_id in auth_ids:
            ref = DBRef('auth', auth_id, 'authonia')
            auth_doc: dict = client.dereference(ref)
            auth_doc.pop('_id')
            auth_docs.append(auth_doc)

        return auth_docs
    except Exception as e:
        print(e)
        return []


def register_user(data_dict: dict):
    try:
        client = mongodb_connect()
        users = client['users']
        user = users.find_one({
            'username': data_dict.get('username', ''),
        })
        if user:
            return {
                'error': True,
                'message': 'User already exists'
            }
        users.insert_one({
            'username': data_dict.get('username', ''),
            'password': data_dict.get('password', ''),
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
    try:
        client = mongodb_connect()
        users = client['users']
        auth = client['auth']

        auth_id = data_dict['auth_id']
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
            return_document=ReturnDocument.AFTER
        )
        if not user:
            return {
                'error': True,
                'message': 'Invalid username/password'
            }
        auth_result = auth.delete_one(
            {
                "_id": ObjectId(auth_id)
            }
        )

        if auth_result.deleted_count == 1:
            return {
                'error': False,
                'message': 'Auth removed sucessfully'
            }
        else:
            return {
                'error': True,
                'message': 'Auth not found! Maybe it was already deleted.'
            }
    except Exception as e:
        return {
            'error': True,
            'message': str(e)
        }
