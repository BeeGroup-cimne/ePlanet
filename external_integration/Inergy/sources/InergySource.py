import os

import requests


class InergySource:
    token = None

    @classmethod
    def authenticate(cls):
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded'
        }
        res = requests.post(url=f"{os.getenv('INERGY_BASE_URL')}/account/login",
                            headers=headers,
                            data={"grant_type": 'password', "username": os.getenv('INERGY_USERNAME'),
                                  "password": os.getenv('INERGY_PASSWORD')}, timeout=15)

        if res.ok:
            cls.raw_token = res.json()
            cls.token = res.json().get('access_token')
        else:
            res.raise_for_status()

    @classmethod
    def insert_elements(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}'}
        res = requests.post(url=f"{os.getenv('INERGY_BASE_URL')}/common/insert_element", headers=headers, json=data,
                            timeout=15)

        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def insert_supplies(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}'}

        res = requests.post(url=f"{os.getenv('INERGY_BASE_URL')}/common/insert_contract", headers=headers, json=data,
                            timeout=15)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def update_elements(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}'}

        res = requests.post(url=f"{os.getenv('INERGY_BASE_URL')}/common/update_element", headers=headers, json=data,
                            timeout=15)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def update_supplies(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}'}

        res = requests.post(url=f"{os.getenv('INERGY_BASE_URL')}/common/update_contract", headers=headers, json=data,
                            timeout=15)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def update_hourly_data(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}'}

        res = requests.post(url=f"{os.getenv('INERGY_BASE_URL')}/common/update_hourly_data", headers=headers, json=data,
                            timeout=15)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()
