import json
import os

import requests

from external_integration.logger import logger


class InergySource:
    token = None
    base_uri = None
    @classmethod
    def authenticate(cls, username, password, base_uri):
        # dev headers = {'Content-Type': 'application/json', 'accept': '*/*'}
        # prod
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded'
        }
        cls.base_uri = base_uri
        res = requests.post(url=f"{base_uri}/account/login",
                            headers=headers,
                            data={"grant_type": 'password', "username": username,
                                  "password": password}, timeout=15)

        if res.ok:
            print(res.json())
            cls.raw_token = res.json()
            cls.token = res.json().get('access_token')
            logger.info("[AUTHENTICATION]: OK")
        else:
            res.raise_for_status()

    @classmethod
    def insert_actions(cls, data, headers, base_uri):
        for action in data:
            res = requests.post(url=f"{base_uri}/action", headers=headers, json=action, timeout=30)
            if res.ok:
                return res.json()
            else:
                res.raise_for_status()

    def update_actions(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}', 'Content-Type': 'application/json'}

        res = requests.post(url=f"{cls.base_uri}/common/update_element", headers=headers, json=data,
                            timeout=15)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def get_elements(cls, uri, token):
        headers = {'Authorization': f'Bearer {token}'}
        print(uri)
        res = requests.get(url=f"{uri}/residentialReports/getElementsByProject/1/856", headers=headers,
                            timeout=15)
        print(res)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def insert_elements(cls, data):
        base_uri = "https://apiv20.inergy.online"
        headers = {'Authorization': f'Bearer {cls.token}'}
        print(cls.base_uri)
        res = requests.post(url=f"{base_uri}/common/insert_element", headers=headers, json=data,
                            timeout=15)

        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def insert_supplies(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}'}

        res = requests.post(url=f"{cls.base_uri}/common/insert_contract", headers=headers, json=data,
                            timeout=300)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def update_elements(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}', 'Content-Type': 'application/json'}

        res = requests.post(url=f"{cls.base_uri}/common/update_element", headers=headers, json=data,
                            timeout=15)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def update_supplies(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}', 'Content-Type': 'application/json'}

        # res = requests.post(url=f"{cls.base_uri}/common/update_contract", headers=headers, json=data, timeout=15)
        res = requests.post(url=f"https://apiv20.inergy.online/common/update_contract", headers=headers, json=data,
                            timeout=15)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def update_hourly_data(cls, data, headers, base_uri):
        # headers = {'Authorization': f'Bearer {cls.token}', 'Content-Type': 'application/json'}
        res = requests.post(url=f"{base_uri}/common/update_hourly_data", headers=headers, json=data,
                            timeout=10)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()
