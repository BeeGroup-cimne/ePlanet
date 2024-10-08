from dataclasses import dataclass
from datetime import datetime, date
from typing import Optional

import numpy as np
from dateutil.relativedelta import relativedelta

from external_integration.Inergy.domain.Location import Location
import pandas as pd
import requests

@dataclass
class Action(object):
    idProject: int
    idActionTypopogy: int
    idResponsible: int
    actionDate: str
    investment: float
    description: str
    codeElement: str

    keep_cols = [12, 13]
    df = pd.read_excel(f"data/Czech/building/Building_identification_data_EAZK_v5_CZE.xlsm", sheet_name='Enum EEM Type',
                       usecols=keep_cols)
    df.dropna()
    eem_dict = pd.Series(df['Field name.3'].values, index=df['Field description.1']).to_dict()

    @classmethod
    def create(cls, id_project, action, project_responsible):
        # Description translations
        keep_cols = [12, 13]
        df = pd.read_excel(f"data/Czech/building/Building_identification_data_EAZK_v5_CZE.xlsm", sheet_name='Enum EEM Type', usecols=keep_cols)
        df.dropna()
        eem_dict = pd.Series(df['Field name.3'].values, index=df['Field description.1']).to_dict()

        trans_description = ''
        for description in action['result']['eemNames']:

            #TODO check harmonization
            if description == 'Building dedicated to other uses':
                description = 'Measure that affects the skylights of the building'
            trans_description += eem_dict[description]

            trans_description += ' | '
        #TODO in harmonization 913
        if action['result']['investment'] == '2 785 337,83':
            action['result']['investment'] = action['result']['investment'].replace(' ', '').replace(',', '.')
        if action['result']['investment'] == None:
            action['result']['investment'] = 0.0

        investment = float(action['result']['investment']) * action['result']['ratio']
        return Action(idProject=id_project,
                      idActionTypopogy=285,
                      idResponsible=project_responsible,
                      actionDate=action['result']['operationalDate'],
                      investment=investment,
                      description=trans_description[:-3],
                      codeElement=action['result']['code'])

