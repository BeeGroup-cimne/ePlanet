import json
import os

import requests

from external_integration.logger import logger


class InergySource:
    token = None
    base_uri = None
    @classmethod
    def authenticate(cls, username, password, base_uri):
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
    def insert_actions(cls, data):
        print(data)
        tok = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiSW5lcmd5LkFwaXMuUGxhbm5pbmciXSwiZXhwIjoxNjg4MDM5ODA5LCJpYXQiOjE2ODgwMjkwMDksImlzcyI6IkluZXJneS5JZGVudGl0eS5UZXN0IiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZWlkZW50aWZpZXIiOiJjYWY3NGEwNS1mZDBiLTRhYTMtYmUyNy0xZTM0OGQ1NmQzZjciLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiZ2xhZ3VuYUBjaW1uZS51cGMuZWR1IiwicHJvamVjdHMiOls4NTIsODUzLDg1NCw4NTUsODU2LDg1N10sInJvbGUuSW5lcmd5LkFwaXMuUGxhbm5pbmciOiJSZWFkV3JpdGUiLCJpbnN0YW5jZSI6IlYzIn0.kuLQ_lv4pzPh4x1_bJtqT5OvQsdyAcTns1RMj4iNO0YJ5fpFCW83BpabaHXZr3TDF6eMeqEkdj4wqVx0nFa5CH-df6ib8f3DjRotlKHkFUyv2MjItOeTwd1iE62cliQZVByaLDk3EbFkwqEmdtJIUIVub9TO1PFSXrMPM8ufeR4cHts_PbzbTXze2gMj_c_j7CqlQVBPojeng-w23TUYIQUggDH6Vkwbf5zz8Arbfu-XGviEm_NZ9_Vg-izi-MFnQNJVtWrWRelUPI2v0JhBBAuFjaRMcQQOPSD8QA2FNqdNXQYlSzOUehCacG1LagwuvR7mDsxDZY22LpApfiRZfw"
        headers = {'Authorization': f'Bearer {tok}', 'accept': 'application/json', 'Content-Type': 'application/json'}
        print(headers)
        base_uri = 'https://api-planning-dev.inergy.online'
        print(base_uri)
        for action in data:
            action = json.dumps(action)
            print(action)
            # action = json.dumps(action)
            action = {"idProject": 856, "idActionTypopogy": 285, "idResponsible": 177, "actionDate": "2023-06-28T07:28:27.058Z", "investment": 636011.902, "description": "Konstrukce budovy - okna | Konstrukce budovy - střecha a stropy | Konstrukce budovy - podlaha | Konstrukce budovy - dveře | Konstrukce budovy - zdi | ", "codeElement": "eP-EAZK-003"}
            res = requests.post(url=f"{base_uri}/action", headers=headers, json=json.dumps(action), timeout=30)

            if res.ok:
                print(res.json())
                return res.json()
            else:
                res.raise_for_status()
    #
    # def update_actions(cls, data):
    #     headers = {'Authorization': f'Bearer {cls.token}', 'Content-Type': 'application/json'}
    #
    #     # res = requests.post(url=f"{cls.base_uri}/common/update_element", headers=headers, json=data,
    #     #                     timeout=15)
    #     # if res.ok:
    #     #     return res.json()
    #     # else:
    #     #     res.raise_for_status()

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
        headers = {'Authorization': f'Bearer {cls.token}'}
        print(cls.base_uri)
        res = requests.post(url=f"{cls.base_uri}/common/insert_element", headers=headers, json=data,
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

        res = requests.post(url=f"{cls.base_uri}/common/update_contract", headers=headers, json=data,
                            timeout=15)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()

    @classmethod
    def update_hourly_data(cls, data):
        headers = {'Authorization': f'Bearer {cls.token}', 'Content-Type': 'application/json'}
        res = requests.post(url=f"{cls.base_uri}/common/update_hourly_data", headers=headers, json=data,
                            timeout=10)
        if res.ok:
            return res.json()
        else:
            res.raise_for_status()
